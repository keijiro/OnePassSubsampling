OnePassSubsampling
------------------

This is an example of single-pass chroma subsampling shader for Unity.

[Chroma subsampling][Wikipedia1] is a lossy compression technique that reduces
image data size by cutting down the number of chrominance samples. This shader
converts a RGB source image into two R8 (8 bits per pixel) textures with the
[4:2:2 YCbCr][Wikipedia2] scheme.

Original image (32 bits per pixel)

![image](http://66.media.tumblr.com/b13090e4ee4ba5dc0f491a765070ef66/tumblr_oa90jl0BBi1qio469o1_540.png)

4:2:2 encoded image (16 bits per pixel)

![image](http://66.media.tumblr.com/ae3d926f0a69242eab52124aa832c975/tumblr_oa90jl0BBi1qio469o2_540.png)

The differences are not noticeable at a glance, but if you look into it very
carefully, you may find some color banding in the dark area and ringing
artifacts on the red sphere.

![image](https://65.media.tumblr.com/8dbe81f94c924c65d64e026a2d27af4b/tumblr_oa90jl0BBi1qio469o3_540.png)

This shader uses MRT (multiple render targets) to output luma and chrominance
in a single pass, and thus requires MRT support on the platform.

[Wikipedia1]: https://en.wikipedia.org/wiki/Chroma_subsampling
[Wikipedia2]: https://en.wikipedia.org/wiki/Chroma_subsampling#Sampling_systems_and_ratios
