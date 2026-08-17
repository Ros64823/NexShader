#ifndef NEX_CONFIG_GLSL
#define NEX_CONFIG_GLSL

// Profile selector exposed in Iris/OptiFine shader options.
// 0=PATATA, 1=MUY BAJO, 2=BAJO, 3=MEDIO, 4=NORMAL, 5=ALTO, 6=MUY ALTO
#define QUALITY_PROFILE 4 // [0 1 2 3 4 5 6]

#define SHADOW_RESOLUTION 2048 // [512 768 1024 1536 2048 3072 4096]
#define SHADOW_SAMPLES 6 // [1 2 3 4 6 8 12 16]
#define SHADOW_FILTER 2 // [0 1 2 3]
#define SSAO_ENABLED 1 // [0 1]
#define SSAO_SAMPLES 6 // [0 2 4 6 8 10 12]
#define SSR_ENABLED 1 // [0 1]
#define SSR_SAMPLES 10 // [0 4 6 8 10 14 18]
#define VOLUMETRIC_ENABLED 1 // [0 1]
#define VOLUMETRIC_STEPS 6 // [0 2 4 6 8 10 12]
#define BLOOM_ENABLED 1 // [0 1]
#define BLOOM_QUALITY 3 // [0 1 2 3 4 5 6]
#define WATER_QUALITY 4 // [0 1 2 3 4 5 6]
#define REFLECTION_QUALITY 4 // [0 1 2 3 4 5 6]
#define CLOUD_QUALITY 4 // [0 1 2 3 4 5 6]
#define FOG_QUALITY 4 // [0 1 2 3 4 5 6]
#define SKY_QUALITY 4 // [0 1 2 3 4 5 6]
#define LIGHTING_QUALITY 4 // [0 1 2 3 4 5 6]
#define POST_PROCESSING_QUALITY 4 // [0 1 2 3 4 5 6]
#define RENDER_SCALE 1.00 // [0.65 0.70 0.75 0.80 0.85 0.90 1.00]
#define EXPOSURE 1.00 // [0.70 0.80 0.90 1.00 1.10 1.20 1.35]
#define CONTRAST 1.05 // [0.85 0.95 1.00 1.05 1.10 1.20 1.30]
#define SATURATION 1.06 // [0.80 0.90 1.00 1.06 1.12 1.20 1.30]

const int shadowMapResolution = SHADOW_RESOLUTION;
const float sunPathRotation = -35.0;
const float ambientOcclusionLevel = 0.85;
const float wetnessHalflife = 300.0;
const float drynessHalflife = 80.0;

#endif
