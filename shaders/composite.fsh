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
void main(){float depth=texture2D(depthtex0,texcoord).r; vec3 base=texture2D(colortex0,texcoord).rgb; vec4 nraw=texture2D(colortex1,texcoord); vec3 viewPos=screenToView(texcoord,depth,gbufferProjectionInverse); vec3 n=decodeNormal(nraw.rgb); vec3 sky=skyGradient(normalize(vec3(texcoord*2.0-1.0,1.0)));
 bool isSky=depth>0.9999; float sh=isSky?1.0:shadowVisibility(viewPos,n,normalize(sunPosition)); float ao=isSky?1.0:computeSSAO(texcoord,depth); vec3 lit=isSky?base:applyLighting(base,n,viewPos,sh)*ao;
 if(nraw.a<0.75 && !isSky) lit=screenReflection(texcoord,lit,0.12+0.06*float(WATER_QUALITY)); lit+=bloom(texcoord); lit+=sunColor()*godRays(texcoord); lit=applyNexFog(lit,viewPos,sky); gl_FragData[0]=vec4(lit,1.0);}
