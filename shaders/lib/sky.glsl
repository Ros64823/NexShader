#ifndef NEX_SKY_GLSL
#define NEX_SKY_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"

vec3 nexSkyGradient(vec3 dir) {
    float h = saturate(dir.y * 0.5 + 0.5);
    float day = saturate(sunPosition.y / 100.0);
    vec3 night = mix(vec3(0.006, 0.009, 0.025), vec3(0.025, 0.040, 0.080), h);
    vec3 daySky = mix(vec3(0.58, 0.72, 0.90), vec3(0.17, 0.34, 0.62), h);
    float sunDot = saturate(dot(dir, normalize(sunPosition)));
    float sunset = pow(saturate(1.0 - abs(sunPosition.y) / 80.0), 2.0) * pow(sunDot, 8.0);
    vec3 color = mix(night, daySky, day) + vec3(1.0, 0.38, 0.12) * sunset * (0.40 + 0.08 * float(SKY_QUALITY));
    return mix(color, fogColor, rainStrength * 0.25);
}

float nexStarField(vec3 dir) {
    float stars = step(0.9965, nexHash12(floor(dir.xz * 900.0)));
    return stars * (1.0 - saturate(sunPosition.y / 30.0));
}

#endif
