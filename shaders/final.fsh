#version 120
#include "/lib/tonemapping.glsl"
varying vec2 texcoord;
void main(){vec3 c=texture2D(colortex0,texcoord).rgb; gl_FragColor=vec4(tonemapNex(c),1.0);}
