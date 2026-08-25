#version 120
#include "/lib/tonemapping.glsl"
#include "/lib/uniforms.glsl"
varying vec2 texcoord;
void main(){vec3 c=sanitize(texture2D(colortex0,clampScreenUV(texcoord)).rgb,vec3(0.0)); gl_FragColor=vec4(sanitize(tonemapNex(c),vec3(0.0)),1.0);}
