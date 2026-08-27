#version 120
#include "/lib/uniforms.glsl"
varying vec3 dir;
void main(){
    vec4 v = gl_ModelViewMatrix * gl_Vertex;
    // World-space direction: the sky gradient must not rotate with the camera.
    dir = normalize(mat3(gbufferModelViewInverse) * v.xyz);
    gl_Position = ftransform();
}
