#ifndef NEX_TONEMAPPING_GLSL
#define NEX_TONEMAPPING_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
vec3 nexTonemap(vec3 color){
    color *= EXPOSURE;
    color = (color * (2.51 * color + 0.03)) / max(color * (2.43 * color + 0.59) + 0.14, vec3(0.0001));
    float y = nexLuma(color);
    float satBoost = SATURATION + (1.0 - y) * VIBRANCE;
    color = mix(vec3(y), color, satBoost);
    float shadowProtect = smoothstep(0.0, 0.28, y);
    float effContrast = mix(1.0, CONTRAST, shadowProtect);
    color = saturate((color - 0.42) * effContrast + 0.42);
    color = pow(color, vec3(1.0 / GAMMA));
    return color;
}
#endif
