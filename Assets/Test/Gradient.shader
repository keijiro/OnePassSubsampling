Shader "Unlit/Gradient"
{
    Properties
    {
        _Saturation("Saturation", Range(0,1)) = 1
        _Brightness("Brightness", Range(0,1)) = 1
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    half _Saturation;
    half _Brightness;

    half3 HueToRGB(half h)
    {
        half r = abs(h * 6 - 3) - 1;
        half g = 2 - abs(h * 6 - 2);
        half b = 2 - abs(h * 6 - 4);
        return saturate(half3(r, g, b));
    }

    struct v2f
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
    };

    v2f vert(appdata_base v)
    {
        v2f o;
        o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
        o.uv = v.texcoord;
        return o;
    }

    half4 frag (v2f i) : SV_Target
    {
        half3 rgb = lerp(1, HueToRGB(i.uv.x), _Saturation) * _Brightness;
        return half4(rgb, 1);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
