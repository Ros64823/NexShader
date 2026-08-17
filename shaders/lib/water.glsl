#ifndef NEX_WATER_GLSL
#define NEX_WATER_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
vec3 nexWaterNormal(vec3 n, vec2 uv){float q = max(float(WATER_QUALITY), 1.0); float waveA = sin((uv.x + frameTimeCounter * 0.025) * 72.0); float waveB = cos((uv.y - frameTimeCounter * 0.018) * 54.0); return normalize(n + vec3(waveA, 0.0, waveB) * WATER_WAVE_STRENGTH * 0.18 * q);}
vec3 nexWaterColor(vec3 base, vec3 normal, vec3 viewDir, float depth01){float fresnel = pow(1.0 - saturate(dot(normal, -viewDir)), 3.0); vec3 shallow = vec3(0.18, 0.55, 0.62); vec3 deep = vec3(0.03, 0.15, 0.28); vec3 tint = mix(shallow, deep, saturate(depth01 * (1.2 + 0.18 * float(WATER_QUALITY)))); vec3 skyReflect = vec3(0.62, 0.82, 1.0) * fresnel * (0.18 + 0.04 * float(REFLECTION_QUALITY)); return mix(base, tint + skyReflect, WATER_TINT_STRENGTH);}
#endif
