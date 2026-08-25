#version 120
/* DRAWBUFFERS:0 */
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/lighting.glsl"
#include "/lib/reflections.glsl"
#include "/lib/bloom.glsl"
#include "/lib/volumetrics.glsl"
varying vec2 texcoord;
void main(){
    vec3 lit = texture2D(colortex0, texcoord).rgb;
    vec4 normalData = texture2D(colortex1, texcoord);
    if (normalData.a < 0.75) lit = nexScreenReflection(texcoord, lit, 0.6);
    lit += nexBloom(texcoord);
    lit += nexSunColor() * nexGodRays(texcoord);
    gl_FragData[0] = vec4(lit, 1.0);
}
