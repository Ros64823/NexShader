#version 120
/* DRAWBUFFERS:012 */
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 color;
varying vec3 normal;
void main(){
    vec4 albedo = texture2D(texture, texcoord) * color;
    if (albedo.a < 0.10) discard;
    gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(nexEncodeNormal(normalize(normal)), 1.0);
    gl_FragData[2] = vec4(lmcoord, 0.0, 1.0);
}
