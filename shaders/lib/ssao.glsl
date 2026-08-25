#ifndef NEX_SSAO_GLSL
#define NEX_SSAO_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
float computeSSAO(vec2 uv,float depth){
 #if SSAO_ENABLED == 0
 return 1.0;
 #else
 if(!(viewWidth>NEX_EPS && viewHeight>NEX_EPS)) return 1.0;
 float center=linearDepth(depth,near,far); float occ=0.0; vec2 px=vec2(1.0/viewWidth,1.0/viewHeight); float r=(1.5+float(SSAO_SAMPLES)*0.35)*px.y;
 for(int i=0;i<SSAO_SAMPLES;i++){float a=6.2831853*(float(i)+hash12(uv*viewWidth))/float(max(SSAO_SAMPLES,1)); vec2 o=vec2(cos(a),sin(a))*r*(0.5+float(i)/float(max(SSAO_SAMPLES,1))); float d=linearDepth(texture2D(depthtex0,clampScreenUV(uv+o)).r,near,far); occ+=step(0.002,center-d)*smoothstep(0.08,0.0,abs(center-d));}
 return saturate(1.0-occ/float(max(SSAO_SAMPLES,1))*0.75);
 #endif
}
#endif
