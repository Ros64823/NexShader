#version 120
/* DRAWBUFFERS:01 */
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
varying vec2 texcoord;
varying vec4 color;
varying vec3 normal;
void main(){
    vec4 albedo = texture2D(texture, texcoord) * color;
    if (albedo.a < 0.10) discard;
    gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(nexEncodeNormal(normalize(normal)), 1.0);
}
