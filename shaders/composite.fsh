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

void main() {
    float depth = texture2D(depthtex0, texcoord).r;
    vec3 base = texture2D(colortex0, texcoord).rgb;
    bool isSky = depth > 0.9999;
    
    vec3 viewPos = nexScreenToView(texcoord, depth, gbufferProjectionInverse);
    vec3 lit = base;
    
    if (!isSky) {
        // Sample normal and lightmap data
        vec4 normalData = texture2D(colortex1, texcoord);
        vec2 lm = texture2D(colortex2, texcoord).rg;
        vec3 normal = nexDecodeNormal(normalData.rgb);
        
        // Calculate direct lighting with shadows
        vec3 lightDir = normalize(sunPosition);
        float shadow = nexShadowVisibility(viewPos, normal, lightDir);
        float ao = nexComputeSSAO(texcoord, depth);
        
        // Apply full lighting model
        lit = nexApplyLighting(base, normal, shadow, ao, lm);
        
        // Apply fog and sky ambient
        vec3 worldDir = normalize(mat3(gbufferModelViewInverse) * viewPos);
        vec3 sky = nexSkyGradient(worldDir);
        lit = nexApplyFog(lit, viewPos, sky);
        
        // Debug modes
        #if NEX_DEBUG == 1
            lit = vec3(shadow);
        #elif NEX_DEBUG == 2
            lit = vec3(ao);
        #elif NEX_DEBUG == 3
            lit = vec3(lm, 0.0);
        #elif NEX_DEBUG == 4
            lit = nexAmbientColor(normal, lm);
        #endif
    }
    
    gl_FragData[0] = vec4(lit, 1.0);
}
