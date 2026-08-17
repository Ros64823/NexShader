#version 120
#include "/lib/common.glsl"
uniform sampler2D texture;
varying vec2 texcoord; varying vec4 color; varying vec3 normal; varying vec3 viewPos;
void main(){vec4 albedo=texture2D(texture,texcoord)*color; if(albedo.a<0.1) discard; gl_FragData[0]=albedo; gl_FragData[1]=vec4(encodeNormal(normalize(normal)),1.0);}
