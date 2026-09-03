#version 120
/* DRAWBUFFERS:012 */
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/water.glsl"
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 color;
varying vec3 normal;
varying vec3 viewPos;
void main(){
    vec4 base = texture2D(texture, texcoord) * color;
    vec3 n = nexWaterNormal(normalize(normal), texcoord);
    // viewDir should point from surface to camera: -viewPos in view space
    vec3 viewDir = normalize(-viewPos);
    vec3 water = nexWaterColor(base.rgb, n, viewDir, saturate(length(viewPos) / 64.0));
    gl_FragData[0] = vec4(water, max(base.a, WATER_OPACITY));
    gl_FragData[1] = vec4(nexEncodeNormal(n), 0.50);
    gl_FragData[2] = vec4(lmcoord, 0.0, 1.0);
}
