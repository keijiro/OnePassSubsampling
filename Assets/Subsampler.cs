using UnityEngine;

[ExecuteInEditMode]
public class Subsampler : MonoBehaviour
{
    [SerializeField] Shader _shader;
    Material _material;
    RenderBuffer[] _mrt;

    void OnEnable()
    {
        _material = new Material(Shader.Find("Hidden/OnePassSubsampling"));
        _material.hideFlags = HideFlags.DontSave;
        _mrt = new RenderBuffer[2];
    }

    void OnDisable()
    {
        DestroyImmediate(_material);
        _material = null;
        _mrt = null;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        var format = RenderTextureFormat.R8;
        var width = source.width;
        var height = source.height;

        var rt_luma = RenderTexture.GetTemporary(width, height, 0, format);
        var rt_chroma = RenderTexture.GetTemporary(width, height, 0, format);

        rt_luma.filterMode = FilterMode.Point;
        rt_chroma.filterMode = FilterMode.Point;

        _mrt[0] = rt_luma.colorBuffer;
        _mrt[1] = rt_chroma.colorBuffer;

        Graphics.SetRenderTarget(_mrt, rt_luma.depthBuffer);
        Graphics.Blit(source, _material, 0);

        _material.SetTexture("_LumaTex", rt_luma);
        _material.SetTexture("_ChromaTex", rt_chroma);
        Graphics.Blit(null, destination, _material, 1);

        RenderTexture.ReleaseTemporary(rt_luma);
        RenderTexture.ReleaseTemporary(rt_chroma);
    }
}
