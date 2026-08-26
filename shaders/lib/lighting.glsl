#ifndef NEX_LIGHTING_GLSL
#define NEX_LIGHTING_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
float nexDayFactor(){return saturate(sunPosition.y / 100.0);}
vec3 nexSunColor(){vec3 noon = vec3(1.00, 0.92, 0.78); vec3 low = vec3(1.00, 0.52, 0.28); return mix(low, noon, nexDayFactor()) * (1.0 - rainStrength * 0.35);}
vec3 nexTorchColor(float blockLight){return vec3(1.00, 0.58, 0.28) * pow(blockLight, 2.0) * 1.35;}
vec3 nexAmbientColor(vec3 normal, vec2 lm){float skyLight = lm.y; vec3 night = vec3(0.025, 0.033, 0.055); vec3 day = vec3(0.24, 0.30, 0.38); vec3 skyAmbient = mix(night, day, nexDayFactor()) * (0.15 + 0.85 * skyLight); float hemi = 0.55 + 0.45 * saturate(normal.y * 0.5 + 0.5); return skyAmbient * hemi * (1.0 - rainStrength * 0.20) + nexTorchColor(lm.x);}
vec3 nexApplyLighting(vec3 albedo, vec3 normal, float shadow, vec2 lm){vec3 lightDir = normalize(sunPosition); float ndl = saturate(dot(normal, lightDir)); float wrap = saturate((dot(normal, lightDir) + 0.32) / 1.32); vec3 ambient = nexAmbientColor(normal, lm); float skyGate = smoothstep(0.10, 0.90, lm.y); float sunUp = saturate(sunPosition.y / 20.0); vec3 direct = nexSunColor() * (ndl * mix(1.0, shadow, SHADOW_STRENGTH) + 0.12 * wrap) * skyGate * sunUp; float qualityBoost = 0.86 + 0.035 * float(LIGHTING_QUALITY); return albedo * (ambient + direct) * qualityBoost;}
#endif
