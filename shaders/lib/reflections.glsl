#ifndef NEX_REFLECTIONS_GLSL
#define NEX_REFLECTIONS_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"

vec3 nexScreenReflection(vec2 uv, vec3 base, float strength) {
    #if SSR_ENABLED == 0 || SSR_SAMPLES == 0
        return base;
    #else
        vec2 dir = normalize((uv - 0.5) * vec2(1.0, -1.0) + vec2(0.0001));
        vec3 accum = base;
        float weight = 1.0;
        
        for (int i = 0; i < SSR_SAMPLES; i++) {
            float stepLen = (float(i) + 1.0) * 0.0025 * (1.0 + 0.18 * float(REFLECTION_QUALITY));
            vec2 suv = uv + dir * stepLen;
            
            // Early exit if outside screen bounds
            if (suv.x <= 0.001 || suv.x >= 0.999 || suv.y <= 0.001 || suv.y >= 0.999) {
                break;
            }
            
            accum += texture2D(colortex0, suv).rgb;
            weight += 1.0;
        }
        
        return mix(base, accum / weight, strength * REFLECTION_STRENGTH * saturate(float(REFLECTION_QUALITY) / 6.0));
    #endif
}

#endif
