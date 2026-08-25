#version 120
/* DRAWBUFFERS:0 */
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/lighting.glsl"
#include "/lib/shadows.glsl"
#include "/lib/ssao.glsl"
#include "/lib/fog.glsl"
#include "/lib/sky.glsl"
varying vec2 texcoord;
void main(){
    float depth = texture2D(depthtex0, texcoord).r;
    vec3 base = texture2D(colortex0, texcoord).rgb;
    bool isSky = depth > 0.9999;
    vec3 viewPos = nexScreenToView(texcoord, depth, gbufferProjectionInverse);
    vec3 lit = base;
    if (!isSky) {
        vec4 normalData = texture2D(colortex1, texcoord);
        vec2 lm = texture2D(colortex2, texcoord).rg;
        vec3 normal = nexDecodeNormal(normalData.rgb);
        vec3 lightDir = normalize(sunPosition);
        float shadow = nexShadowVisibility(viewPos, normal, lightDir);
        float ao = nexComputeSSAO(texcoord, depth);
        lit = nexApplyLighting(base, normal, shadow, lm) * ao;
        vec3 worldDir = normalize(mat3(gbufferModelViewInverse) * viewPos);
        vec3 sky = nexSkyGradient(worldDir);
        lit = nexApplyFog(lit, viewPos, sky);
    }
    gl_FragData[0] = vec4(lit, 1.0);
}
