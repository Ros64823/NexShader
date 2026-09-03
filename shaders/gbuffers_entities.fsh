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
        // Wind offset for alpha-tested entity textures (leaves, banners, etc.)
        if (albedo.a < 0.99) {
            float windAmp = 0.004 * (1.0 + float(WATER_QUALITY) * 0.02);
            float phase = texcoord.x * 12.0 + frameTimeCounter * 0.03;
            vec2 offset = vec2(sin(phase), cos(phase * 1.2)) * windAmp;
            albedo = texture2D(texture, nexSafeUv(texcoord + offset)) * color;
        }
        if (albedo.a < 0.10) discard;
        gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(nexEncodeNormal(normalize(normal)), 1.0);
    gl_FragData[2] = vec4(lmcoord, 0.0, 1.0);
}
