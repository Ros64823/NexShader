#version 120
/* DRAWBUFFERS:0 */
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/lighting.glsl"
#include "/lib/shadows.glsl"
#include "/lib/ssao.glsl"
#include "/lib/fog.glsl"
#include "/lib/reflections.glsl"
#include "/lib/bloom.glsl"
#include "/lib/volumetrics.glsl"
#include "/lib/sky.glsl"
varying vec2 texcoord;
void main(){
    float depth = texture2D(depthtex0, texcoord).r;
    vec3 base = texture2D(colortex0, texcoord).rgb;
    vec4 normalData = texture2D(colortex1, texcoord);
    bool isSky = depth > 0.9999;
    vec3 viewPos = nexScreenToView(texcoord, depth, gbufferProjectionInverse);
    vec3 normal = nexDecodeNormal(normalData.rgb);
    vec3 sky = nexSkyGradient(normalize(vec3(texcoord * 2.0 - 1.0, 1.0)));
    vec3 lit = base;
    if (!isSky) {
        vec3 lightDir = normalize(sunPosition);
        float shadow = nexShadowVisibility(viewPos, normal, lightDir);
        float ao = nexComputeSSAO(texcoord, depth);
        lit = nexApplyLighting(base, normal, viewPos, shadow) * ao;
        if (normalData.a < 0.75) lit = nexScreenReflection(texcoord, lit, 0.6);
    }
    lit += nexBloom(texcoord);
    lit += nexSunColor() * nexGodRays(texcoord);
    lit = nexApplyFog(lit, viewPos, sky);
    gl_FragData[0] = vec4(lit, 1.0);
}
