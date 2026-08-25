#ifndef NEX_REFLECTIONS_GLSL
#define NEX_REFLECTIONS_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
vec3 screenReflection(vec2 uv, vec3 base, float strength){
 #if SSR_ENABLED == 0
 return base;
 #else
 vec2 dir=normalize(uv-0.5)*vec2(1.0,-1.0); vec3 r=base; float w=0.0; for(int i=0;i<SSR_SAMPLES;i++){vec2 suv=uv+dir*(float(i)+1.0)*0.003*float(REFLECTION_QUALITY); if(suv.x<0.0||suv.x>1.0||suv.y<0.0||suv.y>1.0) break; r+=texture2D(colortex0,suv).rgb; w+=1.0;} return mix(base,r/max(w+1.0,1.0),strength*saturate(float(REFLECTION_QUALITY)/6.0));
 #endif
}
#endif
