#version 120
/* DRAWBUFFERS:0 */
/*
const int colortex0Format = RGBA16F;
*/
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
    // Sky pixels are authored in linear light by gbuffers_skybasic; terrain
    // albedo comes from sRGB textures and is linearized before lighting.
    vec3 lit = base;
    if (!isSky) {
        vec3 albedoLin = nexSrgbToLinear(base);
        vec4 normalData = texture2D(colortex1, texcoord);
        vec2 lm = texture2D(colortex2, texcoord).rg;
        vec3 normal = nexDecodeNormal(normalData.rgb);
        vec3 lightDir = normalize(sunPosition);
        float shadow = nexShadowVisibility(viewPos, normal, lightDir);
        float ao = nexComputeSSAO(texcoord, depth);
        lit = nexApplyLighting(albedoLin, normal, shadow, ao, lm);
        vec3 worldDir = normalize(mat3(gbufferModelViewInverse) * viewPos);
        vec3 sky = nexSkyGradient(worldDir);
        lit = nexApplyFog(lit, viewPos, sky);
        #if NEX_DEBUG == 1
            lit = vec3(shadow);
        #elif NEX_DEBUG == 2
            lit = nexDirectLight(normal, shadow, lm);
        #elif NEX_DEBUG == 3
            lit = nexAmbientColor(normal, lm);
        #elif NEX_DEBUG == 4
            lit = vec3(ao);
        #elif NEX_DEBUG == 5
            lit = nexEncodeNormal(normal);
        #elif NEX_DEBUG == 6
            lit = vec3(nexLinearDepth(depth, near, far));
        #elif NEX_DEBUG == 7
            lit = vec3(lm, 0.0);
        #elif NEX_DEBUG == 8
            lit = nexApplyLighting(albedoLin, normal, shadow, ao, lm);
        #endif
    }
    gl_FragData[0] = vec4(lit, 1.0);
}
