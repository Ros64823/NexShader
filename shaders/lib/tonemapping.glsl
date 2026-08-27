#ifndef NEX_TONEMAPPING_GLSL
#define NEX_TONEMAPPING_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
// Input: linear HDR. Output: display-ready sRGB.
vec3 nexTonemap(vec3 color, float exposureScale){
    color = max(color, vec3(0.0)) * EXPOSURE * exposureScale;
    color = (color * (2.51 * color + 0.03)) / max(color * (2.43 * color + 0.59) + 0.14, vec3(0.0001));
    color = nexLinearToSrgb(color);
    float y = nexLuma(color);
    float satBoost = SATURATION + (1.0 - y) * VIBRANCE;
    color = mix(vec3(y), color, satBoost);
    float shadowProtect = smoothstep(0.0, 0.30, y);
    float effContrast = mix(1.0, CONTRAST, shadowProtect);
    color = saturate((color - 0.45) * effContrast + 0.45);
    color = pow(color, vec3(1.0 / GAMMA));
    return color;
}
vec3 nexTonemap(vec3 color){return nexTonemap(color, 1.0);}
#endif
