#ifndef NEX_SSAO_GLSL
#define NEX_SSAO_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
float nexComputeSSAO(vec2 uv, float depth){
    #if SSAO_ENABLED == 0 || SSAO_SAMPLES == 0
        return 1.0;
    #else
        float center = nexLinearDepth(depth, near, far);
        vec2 pixel = vec2(1.0 / viewWidth, 1.0 / viewHeight);
        float radius = (1.25 + float(SSAO_SAMPLES) * 0.22) * SSAO_RADIUS;
        float occ = 0.0;
        for (int i = 0; i < SSAO_SAMPLES; i++) {
            float fi = float(i);
            float a = 6.2831853 * (fi + nexHash12(uv * viewWidth)) / float(SSAO_SAMPLES);
            vec2 o = vec2(cos(a), sin(a)) * pixel * radius * (1.0 + fi * 0.35);
            float sampleDepth = nexLinearDepth(texture2D(depthtex0, nexSafeUv(uv + o)).r, near, far);
            float delta = center - sampleDepth;
            occ += step(0.0015, delta) * smoothstep(0.06, 0.0, abs(delta));
        }
        return saturate(1.0 - (occ / float(SSAO_SAMPLES)) * SSAO_STRENGTH);
    #endif
}
#endif
