#ifndef NEX_TONEMAPPING_GLSL
#define NEX_TONEMAPPING_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
vec3 nexTonemap(vec3 color){color *= EXPOSURE; color = (color * (2.51 * color + 0.03)) / max(color * (2.43 * color + 0.59) + 0.14, vec3(0.0001)); float y = nexLuma(color); float satBoost = SATURATION + (1.0 - y) * VIBRANCE; color = mix(vec3(y), color, satBoost); color = (color - 0.5) * CONTRAST + 0.5; color = pow(saturate(color), vec3(1.0 / GAMMA)); return color;}
#endif
