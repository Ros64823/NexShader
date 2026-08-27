#ifndef NEX_SKY_GLSL
#define NEX_SKY_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/lighting.glsl"
// dir must be a WORLD-space direction. Colors are linear light.
vec3 nexSkyGradient(vec3 dir){
    float h = saturate(dir.y * 0.5 + 0.5);
    float day = nexDayFactor();
    vec3 sunDirW = normalize(mat3(gbufferModelViewInverse) * sunPosition);
    vec3 night = mix(vec3(0.0035, 0.0050, 0.0110), vec3(0.0012, 0.0020, 0.0055), h);
    vec3 daySky = mix(vec3(0.28, 0.44, 0.72), vec3(0.035, 0.11, 0.34), h);
    float sunDot = saturate(dot(dir, sunDirW));
    float elev = nexSunElevation();
    float sunset = pow(saturate(1.0 - abs(elev) / 0.55), 2.0) * pow(sunDot, 8.0);
    vec3 color = mix(night, daySky, day) + vec3(1.0, 0.16, 0.02) * sunset * (0.35 + 0.07 * float(SKY_QUALITY));
    return mix(color, nexSrgbToLinear(fogColor), rainStrength * 0.25);
}
float nexStarField(vec3 dir){
    float stars = step(0.9965, nexHash12(floor(dir.xz * 900.0)));
    return stars * (1.0 - saturate(nexSunElevation() / 0.20));
}
#endif
