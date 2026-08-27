#ifndef NEX_LIGHTING_GLSL
#define NEX_LIGHTING_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"

// Sun elevation in WORLD space (-1..1). sunPosition is a view-space vector,
// so it must be rotated back to world space before reading its height —
// otherwise lighting would change with camera orientation.
float nexSunElevation(){
    vec3 w = mat3(gbufferModelViewInverse) * sunPosition;
    return w.y / max(length(w), 0.0001);
}
float nexDayFactor(){return smoothstep(0.02, 0.30, nexSunElevation());}
float nexSunUpFactor(){return smoothstep(-0.02, 0.10, nexSunElevation());}

// Linear-light sun radiance.
vec3 nexSunColor(){
    vec3 noon = vec3(1.00, 0.95, 0.87) * 3.0;
    vec3 low = vec3(1.00, 0.40, 0.15) * 1.5;
    return mix(low, noon, nexDayFactor()) * (1.0 - rainStrength * 0.55);
}
vec3 nexTorchColor(float blockLight){
    float b = blockLight * blockLight;
    return vec3(1.00, 0.46, 0.15) * b * b * 1.80;
}
// Linear-light indirect (sky + torch) lighting. Deep shade stays dark but
// keeps color/texture information; it never reaches absolute black outdoors.
vec3 nexAmbientColor(vec3 normal, vec2 lm){
    float skyAccess = pow(saturate(lm.y), 1.5);
    vec3 night = vec3(0.012, 0.016, 0.030);
    vec3 day = vec3(0.155, 0.190, 0.250);
    vec3 skyAmbient = mix(night, day, nexDayFactor()) * (0.10 + 0.90 * skyAccess);
    float hemi = 0.78 + 0.22 * saturate(normal.y * 0.5 + 0.5);
    return skyAmbient * hemi * (1.0 - rainStrength * 0.25) + nexTorchColor(lm.x);
}
vec3 nexDirectLight(vec3 normal, float shadow, vec2 lm){
    vec3 lightDir = normalize(sunPosition);
    float ndl = saturate(dot(normal, lightDir));
    float skyGate = smoothstep(0.05, 0.55, lm.y);
    float gate = skyGate * nexSunUpFactor();
    float shadowTerm = mix(1.0, shadow, SHADOW_STRENGTH);
    vec3 sun = nexSunColor();
    float wrap = saturate((dot(normal, lightDir) + 0.40) / 1.40);
    vec3 direct = sun * ndl * shadowTerm * gate;
    vec3 bounce = sun * 0.045 * wrap * gate * mix(0.55, 1.0, shadow);
    return direct + bounce;
}
// finalLighting = ambient*aoTerm + direct*shadowTerm : AO only dims the
// indirect component; sun visibility only dims the direct component.
vec3 nexApplyLighting(vec3 albedoLin, vec3 normal, float shadow, float ao, vec2 lm){
    vec3 ambient = nexAmbientColor(normal, lm) * mix(1.0, ao, 0.85);
    return albedoLin * (ambient + nexDirectLight(normal, shadow, lm));
}
#endif
