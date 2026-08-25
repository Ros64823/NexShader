#version 120
#include "/lib/common.glsl"
#include "/lib/water.glsl"
uniform sampler2D texture;
varying vec2 texcoord; varying vec4 color; varying vec3 normal; varying vec3 viewPos;
void main(){vec4 a=texture2D(texture,texcoord)*color; vec3 n=waterNormal(safeNormalize(normal,vec3(0.0,1.0,0.0)),texcoord); vec3 c=waterColor(a.rgb,n,safeNormalize(viewPos,vec3(0.0,0.0,-1.0)),saturate(length(viewPos)/64.0)); gl_FragData[0]=vec4(sanitize(mix(a.rgb,c,0.65),a.rgb),max(a.a,0.55)); gl_FragData[1]=vec4(encodeNormal(n),0.55);}
