#ifndef NEX_VOLUMETRICS_GLSL
#define NEX_VOLUMETRICS_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
uniform vec3 sunPosition;
float godRays(vec2 uv){
 #if VOLUMETRIC_ENABLED == 0
 return 0.0;
 #else
 vec2 sunUv=normalize(sunPosition.xy)*0.25+0.5; float acc=0.0; for(int i=0;i<VOLUMETRIC_STEPS;i++){float t=float(i)/float(max(VOLUMETRIC_STEPS,1)); vec2 p=mix(uv,sunUv,t*0.35); acc+=pow(saturate(1.0-length(p-sunUv)*2.2),2.0);} return acc/float(max(VOLUMETRIC_STEPS,1))*0.08*float(VOLUMETRIC_STEPS);
 #endif
}
#endif
