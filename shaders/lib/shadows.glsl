#ifndef NEX_SHADOWS_GLSL
#define NEX_SHADOWS_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
float nexShadowCompare(vec3 shadowPos, float bias){float mapDepth = texture2D(shadowtex0, nexSafeUv(shadowPos.xy)).r; return step(shadowPos.z - bias, mapDepth);}
float nexShadowVisibility(vec3 viewPos, vec3 normal, vec3 lightDir){
    vec4 worldPos = gbufferModelViewInverse * vec4(viewPos, 1.0);
    vec4 shadowClip = shadowProjection * (shadowModelView * worldPos);
    shadowClip.xyz = shadowClip.xyz * 0.5 + 0.5;
    if (shadowClip.x <= 0.0 || shadowClip.x >= 1.0 || shadowClip.y <= 0.0 || shadowClip.y >= 1.0 || shadowClip.z <= 0.0 || shadowClip.z >= 1.0) return 1.0;
    float ndl = saturate(dot(normal, lightDir));
    float bias = SHADOW_BIAS + (1.0 - ndl) * SHADOW_BIAS * 2.0;
    float radius = float(SHADOW_FILTER + 1) / float(shadowMapResolution);
    float sum = 0.0;
    #if SHADOW_SAMPLES <= 1
        sum = nexShadowCompare(shadowClip.xyz, bias);
    #else
        for (int i = 0; i < SHADOW_SAMPLES; i++) {
            float a = 6.2831853 * (float(i) + 0.5) / float(SHADOW_SAMPLES);
            vec2 o = vec2(cos(a), sin(a)) * radius;
            sum += nexShadowCompare(vec3(shadowClip.xy + o, shadowClip.z), bias);
        }
        sum /= float(SHADOW_SAMPLES);
    #endif
    return mix(1.0, sum, saturate(ndl * 1.35));
}
#endif
