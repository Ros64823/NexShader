#ifndef NEX_BLOOM_GLSL
#define NEX_BLOOM_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
vec3 bloom(vec2 uv){
 #if BLOOM_ENABLED == 0
 return vec3(0.0);
 #else
 vec2 px=vec2(safeDiv(1.0,viewWidth,0.0),safeDiv(1.0,viewHeight,0.0))*(2.0+float(BLOOM_QUALITY)); vec3 b=vec3(0.0); for(int i=0;i<8;i++){float a=6.2831853*float(i)/8.0; vec3 c=sanitize(texture2D(colortex0,clampScreenUV(uv+vec2(cos(a),sin(a))*px)).rgb,vec3(0.0)); b+=max(c-0.72,0.0);} return b*(0.018+0.006*float(BLOOM_QUALITY));
 #endif
}
#endif
