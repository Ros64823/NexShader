#version 120
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/lighting.glsl"
#include "/lib/shadows.glsl"
#include "/lib/ssao.glsl"
#include "/lib/fog.glsl"
#include "/lib/reflections.glsl"
#include "/lib/bloom.glsl"
#include "/lib/volumetrics.glsl"
#include "/lib/sky.glsl"
uniform sampler2D colortex1;
varying vec2 texcoord;
void main(){vec2 uv=clampScreenUV(texcoord); float depth=saturate(texture2D(depthtex0,uv).r); vec3 base=sanitize(texture2D(colortex0,uv).rgb,vec3(0.0)); vec4 nraw=texture2D(colortex1,uv); vec3 viewPos=screenToView(uv,depth,gbufferProjectionInverse); vec3 n=decodeNormal(nraw.rgb); vec3 sky=skyGradient(safeNormalize(vec3(uv*2.0-1.0,1.0),vec3(0.0,1.0,0.0)));
 bool isSky=depth>0.9999; float sh=isSky?1.0:shadowVisibility(viewPos,n,safeNormalize(sunPosition,vec3(0.0,1.0,0.0))); float ao=isSky?1.0:computeSSAO(uv,depth); vec3 lit=isSky?base:applyLighting(base,n,viewPos,sh)*ao;
 if(nraw.a<0.75 && !isSky) lit=screenReflection(uv,lit,0.12+0.06*float(WATER_QUALITY)); lit+=bloom(uv); lit+=sunColor()*sanitize(godRays(uv),0.0); lit=applyNexFog(lit,viewPos,sky);
 // Never hand a non-finite value to final: it would be sampled again and
 // smeared over the screen by tonemapping. Fall back to the raw gbuffer color.
 gl_FragData[0]=vec4(sanitize(lit,base),1.0);}
