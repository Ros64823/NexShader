#ifndef NEX_LIGHTING_GLSL
#define NEX_LIGHTING_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
float nexDayFactor(){return saturate(sunPosition.y / 100.0);}
float nexSunsetFactor(){float t = abs(float(worldTime) - 12000.0) / 12000.0; return pow(saturate(1.0 - t), 2.0) * (1.0 - nexDayFactor());}
vec3 nexSunColor(){vec3 noon = vec3(1.00, 0.92, 0.78); vec3 low = vec3(1.00, 0.52, 0.28); return mix(low, noon, nexDayFactor()) * (1.0 - rainStrength * 0.35);}
vec3 nexAmbientColor(vec3 normal){float skyLight = float(eyeBrightnessSmooth.y) / 240.0; vec3 night = vec3(0.025, 0.033, 0.055); vec3 day = mix(vec3(0.16, 0.20, 0.25), vec3(0.24, 0.30, 0.38), skyLight); float hemi = 0.55 + 0.45 * saturate(normal.y * 0.5 + 0.5); return mix(night, day, max(nexDayFactor(), skyLight * 0.65)) * hemi * (1.0 - rainStrength * 0.20);}
vec3 nexApplyLighting(vec3 albedo, vec3 normal, vec3 viewPos, float shadow){vec3 lightDir = normalize(sunPosition); float ndl = saturate(dot(normal, lightDir)); float wrap = saturate((dot(normal, lightDir) + 0.32) / 1.32); vec3 ambient = nexAmbientColor(normal); vec3 direct = nexSunColor() * (ndl * mix(1.0, shadow, SHADOW_STRENGTH) + 0.12 * wrap); float qualityBoost = 0.86 + 0.035 * float(LIGHTING_QUALITY); return albedo * (ambient + direct) * qualityBoost;}
#endif
