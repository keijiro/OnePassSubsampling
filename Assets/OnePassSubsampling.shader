Shader "Hidden/OnePassSubsampling"
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
        // RGB to YCbCr convertion matrix
        const half3 kY  = half3( 0.299   ,  0.587   ,  0.114   );
        const half3 kCB = half3(-0.168736, -0.331264,  0.5     );
        const half3 kCR = half3( 0.5     , -0.418688, -0.081312);

        // 0: even column, 1: odd column
        half odd = frac(i.uv.x * _ScreenParams.x * 0.5) > 0.5;

        // Sample the source.
        half3 rgb = tex2D(_MainTex, i.uv).rgb;

        // Convertion and subsampling
        EncoderOutput o;
        o.luma = dot(kY, rgb);
        o.chroma = dot(lerp(kCB, kCR, odd), rgb) + 0.5;
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
        half r = y                + 1.402   * cr;
        half g = y - 0.34414 * cb - 0.71414 * cr;
        half b = y + 1.772   * cb;

        return half4(r, g, b, 1);
    }

    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_encode
            #pragma target 3.0
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_decode
            #pragma target 3.0
            ENDCG
        }
    }
}
