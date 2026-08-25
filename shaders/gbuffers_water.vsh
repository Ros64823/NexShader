#version 120
#include "/lib/safety.glsl"
varying vec2 texcoord; varying vec4 color; varying vec3 normal; varying vec3 viewPos;
void main(){texcoord=(gl_TextureMatrix[0]*gl_MultiTexCoord0).xy; color=gl_Color; normal=safeNormalize(gl_NormalMatrix*gl_Normal,vec3(0.0,1.0,0.0)); vec4 v=gl_ModelViewMatrix*gl_Vertex; viewPos=v.xyz; gl_Position=gl_ProjectionMatrix*v;}
