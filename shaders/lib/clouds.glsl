#ifndef NEX_CLOUDS_GLSL
#define NEX_CLOUDS_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
float nexCloudLayer(vec3 dir){float q = float(CLOUD_QUALITY); if (q < 1.0) return 0.0; vec2 p = dir.xz / max(dir.y + 0.25, 0.15) * 0.06 + frameTimeCounter * 0.0015; float cells = 8.0 + q * 4.0; float n = nexHash12(floor(p * cells)); float soft = smoothstep(0.50, 0.84, n); return soft * saturate(dir.y * 2.0) * CLOUD_STRENGTH * (1.0 - rainStrength * 0.45);}
#endif
