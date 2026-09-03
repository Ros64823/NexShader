#ifndef NEX_SHADOWS_GLSL
#define NEX_SHADOWS_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"

float nexShadowDistortFactor(vec2 clipXY) {
    return length(clipXY) * SHADOW_DISTORT + (1.0 - SHADOW_DISTORT);
}

float nexShadowCompare(vec3 shadowPos, float bias) {
    float mapDepth = texture2D(shadowtex0, nexSafeUv(shadowPos.xy)).r;
    return step(shadowPos.z - bias, mapDepth);
}

float nexShadowVisibility(vec3 viewPos, vec3 normal, vec3 lightDir) {
    float ndl = saturate(dot(normal, lightDir));
    vec3 worldNormal = mat3(gbufferModelViewInverse) * normal;
    vec4 worldPos = gbufferModelViewInverse * vec4(viewPos, 1.0);
    worldPos.xyz += worldNormal * (0.03 + 0.06 * (1.0 - ndl));
    
    vec4 shadowClip = shadowProjection * (shadowModelView * worldPos);
    float distortFactor = nexShadowDistortFactor(shadowClip.xy);
    shadowClip.xy /= distortFactor;
    shadowClip.xyz = shadowClip.xyz * 0.5 + 0.5;
    
    // Out of shadow map bounds
    if (shadowClip.x <= 0.0 || shadowClip.x >= 1.0 || shadowClip.y <= 0.0 || shadowClip.y >= 1.0 || shadowClip.z <= 0.0 || shadowClip.z >= 1.0) {
        return 1.0;
    }
    
    float bias = (SHADOW_BIAS + (1.0 - ndl) * SHADOW_BIAS * 2.0) * (0.5 + distortFactor);
    float radius = float(SHADOW_FILTER + 1) * 1.6 / float(shadowMapResolution);
    float sum = 0.0;
    
    #if SHADOW_SAMPLES <= 1
        sum = nexShadowCompare(shadowClip.xyz, bias);
    #else
        float rot = nexHash12(gl_FragCoord.xy) * 6.2831853;
        for (int i = 0; i < SHADOW_SAMPLES; i++) {
            float a = 6.2831853 * (float(i) + 0.5) / float(SHADOW_SAMPLES) + rot;
            float r = radius * sqrt((float(i) + 0.5) / float(SHADOW_SAMPLES));
            vec2 o = vec2(cos(a), sin(a)) * r;
            sum += nexShadowCompare(vec3(shadowClip.xy + o, shadowClip.z), bias);
        }
        sum /= float(SHADOW_SAMPLES);
    #endif
    
    return sum;
}

#endif
