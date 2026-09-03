#ifndef NEX_COMMON_GLSL
#define NEX_COMMON_GLSL

#define saturate(x) clamp(x, 0.0, 1.0)

float nexLuma(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

float nexHash12(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec3 nexDecodeNormal(vec3 n) {
    return normalize(n * 2.0 - 1.0);
}

vec3 nexEncodeNormal(vec3 n) {
    return n * 0.5 + 0.5;
}

vec3 nexScreenToView(vec2 uv, float depth, mat4 invProj) {
    vec4 p = vec4(uv * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    p = invProj * p;
    float w = p.w;
    if (abs(w) < 0.00001) w = w < 0.0 ? -0.00001 : 0.00001;
    return p.xyz / w;
}

float nexLinearDepth(float d, float n, float f) {
    return (2.0 * n) / max(f + n - d * (f - n), 0.00001);
}

vec2 nexSafeUv(vec2 uv) {
    return clamp(uv, vec2(0.001), vec2(0.999));
}

#endif
