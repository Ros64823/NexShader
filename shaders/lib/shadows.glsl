#ifndef NEX_SHADOWS_GLSL
#define NEX_SHADOWS_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
uniform sampler2DShadow shadowtex0;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
float shadowVisibility(vec3 viewPos, vec3 normal, vec3 lightDir){
 if(!nexIsFinite(viewPos)) return 1.0;
 vec4 wp=gbufferModelViewInverse*vec4(viewPos,1.0); vec4 sp=shadowProjection*(shadowModelView*wp); sp.xyz=(sp.xyz/nexGuardDenom(sp.w))*0.5+0.5;
 if(sp.x<0.0||sp.x>1.0||sp.y<0.0||sp.y>1.0||sp.z<0.0||sp.z>1.0) return 1.0;
 float ndl=saturate(dot(normal,lightDir)); float bias=max(0.0006,0.003*(1.0-ndl)); float sum=0.0; float radius=safeDiv(float(SHADOW_FILTER+1),float(shadowMapResolution),0.0);
 #if SHADOW_SAMPLES <= 1
  sum=shadow2D(shadowtex0,vec3(sp.xy,sp.z-bias)).r;
 #else
  for(int i=0;i<SHADOW_SAMPLES;i++){float a=6.2831853*(float(i)/float(SHADOW_SAMPLES)); vec2 o=vec2(cos(a),sin(a))*radius; sum+=shadow2D(shadowtex0,vec3(sp.xy+o,sp.z-bias)).r;}
  sum/=float(SHADOW_SAMPLES);
 #endif
 return mix(1.0,sum,saturate(ndl*1.25));
}
#endif
