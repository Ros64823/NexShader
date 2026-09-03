#ifndef NEX_BLOOM_GLSL
#define NEX_BLOOM_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"

vec3 nexBloom(vec2 uv) {
    #if BLOOM_ENABLED == 0 || BLOOM_QUALITY == 0
        return vec3(0.0);
    #else
        vec2 px = vec2(1.0 / viewWidth, 1.0 / viewHeight) * (1.5 + float(BLOOM_QUALITY));
        vec3 b = vec3(0.0);
        
        for (int i = 0; i < 8; i++) {
            float a = 6.2831853 * float(i) / 8.0;
            vec3 c = texture2D(colortex0, nexSafeUv(uv + vec2(cos(a), sin(a)) * px)).rgb;
            b += max(c - BLOOM_THRESHOLD, 0.0);
        }
        
        return b * (BLOOM_STRENGTH / 8.0) * (0.6 + 0.12 * float(BLOOM_QUALITY));
    #endif
}

#endif
