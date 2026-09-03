#ifndef NEX_VOLUMETRICS_GLSL
#define NEX_VOLUMETRICS_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"

float nexGodRays(vec2 uv) {
    #if VOLUMETRIC_ENABLED == 0 || VOLUMETRIC_STEPS == 0
        return 0.0;
    #else
        vec4 sunClip = gbufferProjection * vec4(sunPosition, 1.0);
        
        // Sun is behind camera, no god rays
        if (sunClip.w <= 0.0) return 0.0;
        
        vec2 sunUv = sunClip.xy / sunClip.w * 0.5 + 0.5;
        vec2 fromCenter = sunUv - vec2(0.5);
        float edgeFade = saturate(1.6 - 2.0 * max(abs(fromCenter.x), abs(fromCenter.y)));
        
        // Sun is off-screen, no god rays
        if (edgeFade <= 0.0) return 0.0;
        
        float acc = 0.0;
        for (int i = 0; i < VOLUMETRIC_STEPS; i++) {
            float t = float(i) / float(VOLUMETRIC_STEPS);
            vec2 p = mix(uv, sunUv, t * 0.40);
            float d = length(p - sunUv);
            acc += pow(saturate(1.0 - d * 2.15), 2.0);
        }
        
        return acc / float(VOLUMETRIC_STEPS) * VOLUMETRIC_STRENGTH * edgeFade * saturate(sunPosition.y / 80.0) * (1.0 - rainStrength * 0.65);
    #endif
}

#endif
