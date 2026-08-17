#ifndef NEX_VOLUMETRICS_GLSL
#define NEX_VOLUMETRICS_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
float nexGodRays(vec2 uv){
    #if VOLUMETRIC_ENABLED == 0 || VOLUMETRIC_STEPS == 0
        return 0.0;
    #else
        vec2 sunUv = normalize(sunPosition.xy + vec2(0.001)) * 0.25 + 0.5;
        float acc = 0.0;
        for (int i = 0; i < VOLUMETRIC_STEPS; i++) {
            float t = float(i) / float(VOLUMETRIC_STEPS);
            vec2 p = mix(uv, sunUv, t * 0.40);
            float d = length(p - sunUv);
            acc += pow(saturate(1.0 - d * 2.15), 2.0);
        }
        return acc / float(VOLUMETRIC_STEPS) * VOLUMETRIC_STRENGTH * saturate(sunPosition.y / 80.0) * (1.0 - rainStrength * 0.65);
    #endif
}
#endif
