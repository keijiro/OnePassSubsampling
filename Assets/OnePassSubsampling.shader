﻿Shader "Hidden/OnePassSubsampling"
{
    Properties
    {
        _MainTex("", 2D) = "black" {}
        _LumaTex("", 2D) = "black" {}
        _ChromaTex("", 2D) = "black" {}
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    sampler2D _LumaTex;
    sampler2D _ChromaTex;

    struct EncoderOutput
    {
        half4 luma : SV_Target0;
        half4 chroma : SV_Target1;
    };

    EncoderOutput frag_encode(v2f_img i)
    {
        float sw = _ScreenParams.x;     // Screen width
        float pw = _ScreenParams.z - 1; // Pixel wdith

        // RGB to YCbCr convertion matrix
        const half3 kY  = half3( 0.299   ,  0.587   ,  0.114   );
        const half3 kCB = half3(-0.168736, -0.331264,  0.5     );
        const half3 kCR = half3( 0.5     , -0.418688, -0.081312);

        // 0: even column, 1: odd column
        half odd = frac(i.uv.x * sw * 0.5) > 0.5;

        // Calculate UV for chroma componetns.
        // It's between the even and odd columns.
        float2 uv_c = i.uv.xy;
        uv_c.x = (floor(uv_c.x * sw * 0.5) * 2 + 1) * pw;

        // Sample the source texture.
        half3 rgb_y = tex2D(_MainTex, i.uv).rgb;
        half3 rgb_c = tex2D(_MainTex, uv_c).rgb;

        #if !UNITY_COLORSPACE_GAMMA
        rgb_y = LinearToGammaSpace(rgb_y);
        rgb_c = LinearToGammaSpace(rgb_c);
        #endif

        // Convertion and subsampling
        EncoderOutput o;
        o.luma = dot(kY, rgb_y);
        o.chroma = dot(lerp(kCB, kCR, odd), rgb_c) + 0.5;
        return o;
    }

    half4 frag_decode(v2f_img i) : SV_Target
    {
        float sw = _ScreenParams.x;     // Screen width
        float pw = _ScreenParams.z - 1; // Pixel wdith

        // Calculate UV for Cb. It's on the even columns.
        float2 uv_cb = i.uv.xy;
        uv_cb.x = (floor(uv_cb.x * sw * 0.5) * 2 + 0.5) * pw;

        // Calculate UV for Cr. It's on the odd columns.
        float2 uv_cr = uv_cb;
        uv_cr.x += pw;

        // Sample Y, Cb and Cr.
        half y = tex2D(_LumaTex, i.uv).r;
        half cb = tex2D(_ChromaTex, uv_cb).r - 0.5;
        half cr = tex2D(_ChromaTex, uv_cr).r - 0.5;

        // Convert to RGB.
        half3 rgb = half3(
            y                + 1.402   * cr,
            y - 0.34414 * cb - 0.71414 * cr,
            y + 1.772   * cb
        );

        #if !UNITY_COLORSPACE_GAMMA
        rgb = GammaToLinearSpace(rgb);
        #endif

        return half4(rgb, 1);
    }

    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            CGPROGRAM
            #pragma multi_compile _ UNITY_COLORSPACE_GAMMA
            #pragma vertex vert_img
            #pragma fragment frag_encode
            #pragma target 3.0
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma multi_compile _ UNITY_COLORSPACE_GAMMA
            #pragma vertex vert_img
            #pragma fragment frag_decode
            #pragma target 3.0
            ENDCG
        }
    }
}
