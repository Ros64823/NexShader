#ifndef NEX_FOG_GLSL
#define NEX_FOG_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
vec3 applyNexFog(vec3 color, vec3 viewPos, vec3 sky){float dist=sanitize(length(viewPos),0.0); if(!(far>NEX_EPS)) return color; float f=smoothstep(far*(0.25+0.04*float(FOG_QUALITY)),far,dist); f*=0.45+0.07*float(FOG_QUALITY)+rainStrength*0.35; if(isEyeInWater==1) f=max(f,smoothstep(2.0,18.0,dist)*0.75); return mix(color,mix(fogColor,sky,0.45),saturate(f));}
#endif
