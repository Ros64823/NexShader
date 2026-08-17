#version 120
#include "/lib/sky.glsl"
#include "/lib/clouds.glsl"
varying vec3 dir;
void main(){vec3 d=normalize(dir); vec3 c=skyGradient(d); c=mix(c,vec3(0.82,0.88,0.95),cloudLayer(d)*0.45); c+=starField(d)*vec3(0.7,0.8,1.0); gl_FragData[0]=vec4(c,1.0); gl_FragData[1]=vec4(0.5,1.0,0.5,1.0);}
