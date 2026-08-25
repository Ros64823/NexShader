#version 120
#include "/lib/safety.glsl"
varying vec3 dir;
void main(){vec4 v=gl_ModelViewMatrix*gl_Vertex; dir=safeNormalize(v.xyz,vec3(0.0,1.0,0.0)); gl_Position=ftransform();}
