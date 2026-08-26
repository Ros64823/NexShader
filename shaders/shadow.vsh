#version 120
#include "/lib/config.glsl"
varying vec2 texcoord;
varying vec4 color;
void main(){
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    color = gl_Color;
    vec4 pos = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
    float distortFactor = length(pos.xy) * SHADOW_DISTORT + (1.0 - SHADOW_DISTORT);
    pos.xy /= distortFactor;
    gl_Position = pos;
}
