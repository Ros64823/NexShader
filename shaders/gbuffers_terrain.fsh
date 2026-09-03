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
        // Simple wind animation for alpha-tested (foliage) materials
        if (albedo.a < 0.99) {
            float windAmp = 0.0012 * (1.0 + float(WATER_QUALITY) * 0.01);
            float phase = texcoord.x * 8.0 + frameTimeCounter * 0.02;
            vec2 offset = vec2(sin(phase), cos(phase * 1.25)) * windAmp;
            albedo = texture2D(texture, nexSafeUv(texcoord + offset)) * color;
        }
        if (albedo.a < 0.10) discard;
        gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(nexEncodeNormal(normalize(normal)), 1.0);
    gl_FragData[2] = vec4(lmcoord, 0.0, 1.0);
}
