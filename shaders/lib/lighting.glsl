#ifndef NEX_LIGHTING_GLSL
#define NEX_LIGHTING_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"

float nexDayFactor() {
    return saturate(sunPosition.y / 100.0);
}

vec3 nexSunColor() {
    vec3 noon = vec3(1.10, 1.00, 0.84);
    vec3 low = vec3(1.00, 0.54, 0.30);
    return mix(low, noon, nexDayFactor()) * (1.0 - rainStrength * 0.35);
}

vec3 nexTorchColor(float blockLight) {
    return vec3(1.00, 0.60, 0.30) * (blockLight * blockLight) * 1.10;
}

vec3 nexAmbientColor(vec3 normal, vec2 lm) {
    float skyLight = lm.y;
    vec3 night = vec3(0.035, 0.045, 0.070);
    vec3 day = vec3(0.34, 0.40, 0.48);
    vec3 skyAmbient = mix(night, day, nexDayFactor()) * (0.30 + 0.70 * skyLight);
    float hemi = 0.72 + 0.28 * saturate(normal.y * 0.5 + 0.5);
    return skyAmbient * hemi * (1.0 - rainStrength * 0.18) + nexTorchColor(lm.x);
}

vec3 nexApplyLighting(vec3 albedo, vec3 normal, float shadow, float ao, vec2 lm) {
    vec3 lightDir = normalize(sunPosition);
    float ndl = saturate(dot(normal, lightDir));
    float wrap = saturate((dot(normal, lightDir) + 0.40) / 1.40);
    float skyGate = smoothstep(0.05, 0.55, lm.y);
    float sunUp = saturate(sunPosition.y / 20.0);
    float shadowTerm = mix(1.0, shadow, SHADOW_STRENGTH);
    
    vec3 sun = nexSunColor();
    vec3 direct = sun * ndl * shadowTerm * skyGate * sunUp;
    vec3 bounce = sun * 0.10 * wrap * skyGate * sunUp * mix(0.55, 1.0, shadow);
    vec3 ambient = nexAmbientColor(normal, lm) * mix(1.0, ao, 0.80);
    
    return albedo * (ambient + bounce + direct);
}

#endif
