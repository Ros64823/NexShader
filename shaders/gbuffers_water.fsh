#version 120
/* DRAWBUFFERS:01 */
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/water.glsl"
varying vec2 texcoord;
varying vec4 color;
varying vec3 normal;
varying vec3 viewPos;
void main(){
    vec4 base = texture2D(texture, texcoord) * color;
    vec3 n = nexWaterNormal(normalize(normal), texcoord);
    vec3 water = nexWaterColor(base.rgb, n, normalize(viewPos), saturate(length(viewPos) / 64.0));
    gl_FragData[0] = vec4(mix(base.rgb, water, WATER_TINT_STRENGTH), max(base.a, WATER_OPACITY));
    gl_FragData[1] = vec4(nexEncodeNormal(n), 0.50);
}
