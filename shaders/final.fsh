#version 120
#include "/lib/uniforms.glsl"
#include "/lib/tonemapping.glsl"
varying vec2 texcoord;
void main(){
    vec3 color = texture2D(colortex0, texcoord).rgb;
    gl_FragColor = vec4(nexTonemap(color), 1.0);
}
