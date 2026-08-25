#ifndef NEX_SKY_GLSL
#define NEX_SKY_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
vec3 skyGradient(vec3 dir){float h=saturate(dir.y*0.5+0.5); float day=saturate(sunPosition.y/100.0); vec3 night=mix(vec3(0.006,0.009,0.025),vec3(0.025,0.04,0.08),h); vec3 dayc=mix(vec3(0.55,0.72,0.95),vec3(0.08,0.30,0.70),h); float s=saturate(dot(dir,normalize(sunPosition))); vec3 sunset=vec3(1.0,0.38,0.12)*pow(saturate(1.0-abs(sunPosition.y)/80.0),2.0)*pow(saturate(s),8.0); return mix(night,dayc,day)+sunset*(0.4+0.1*float(SKY_QUALITY))*(1.0-rainStrength);}
float starField(vec3 d){return step(0.996,hash12(floor(d.xz*900.0)))*(1.0-saturate(sunPosition.y/30.0));}
#endif
