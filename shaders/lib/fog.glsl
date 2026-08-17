#ifndef NEX_FOG_GLSL
#define NEX_FOG_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
vec3 nexApplyFog(vec3 color, vec3 viewPos, vec3 sky){float dist = length(viewPos); float start = far * (0.30 + 0.035 * float(FOG_QUALITY)); float fogAmount = smoothstep(start, far, dist) * FOG_DENSITY; fogAmount += rainStrength * smoothstep(far * 0.18, far * 0.70, dist) * 0.35; if (isEyeInWater == 1) fogAmount = max(fogAmount, smoothstep(2.0, 18.0, dist) * 0.75); vec3 fogMix = mix(fogColor, sky, 0.35 + 0.05 * float(SKY_QUALITY)); return mix(color, fogMix, saturate(fogAmount));}
#endif
