#ifndef NEX_CONFIG_GLSL
#define NEX_CONFIG_GLSL

// 0=PATATA, 1=MUY_BAJO, 2=BAJO, 3=MEDIO, 4=NORMAL, 5=ALTO, 6=MUY_ALTO
#define QUALITY_PROFILE 4 // [0 1 2 3 4 5 6]

#define SHADOW_RESOLUTION 2048 // [512 768 1024 1536 2048 3072 4096]
#define SHADOW_SAMPLES 6 // [1 2 3 4 6 8 12]
#define SHADOW_FILTER 2 // [0 1 2 3]
#define SHADOW_STRENGTH 0.78 // [0.35 0.50 0.65 0.78 0.90 1.00]
#define SHADOW_BIAS 0.0012 // [0.0006 0.0008 0.0010 0.0012 0.0018 0.0025]

#define SSAO_ENABLED 1 // [0 1]
#define SSAO_SAMPLES 6 // [0 2 4 6 8 10 12]
#define SSAO_STRENGTH 0.70 // [0.20 0.35 0.50 0.70 0.85 1.00]
#define SSAO_RADIUS 1.00 // [0.50 0.75 1.00 1.25 1.50]

#define SSR_ENABLED 1 // [0 1]
#define SSR_SAMPLES 10 // [0 4 6 8 10 14 18]
#define REFLECTION_STRENGTH 0.28 // [0.00 0.10 0.18 0.28 0.40 0.55]

#define VOLUMETRIC_ENABLED 1 // [0 1]
#define VOLUMETRIC_STEPS 6 // [0 2 4 6 8 10 12]
#define VOLUMETRIC_STRENGTH 0.28 // [0.00 0.10 0.18 0.28 0.40 0.55]

#define BLOOM_ENABLED 1 // [0 1]
#define BLOOM_QUALITY 3 // [0 1 2 3 4 5 6]
#define BLOOM_STRENGTH 0.22 // [0.00 0.08 0.14 0.22 0.32 0.45]
#define BLOOM_THRESHOLD 0.72 // [0.55 0.65 0.72 0.80 0.90]

#define WATER_QUALITY 4 // [0 1 2 3 4 5 6]
#define WATER_OPACITY 0.68 // [0.45 0.55 0.68 0.80 0.90]
#define WATER_WAVE_STRENGTH 0.22 // [0.00 0.08 0.14 0.22 0.32 0.45]
#define WATER_TINT_STRENGTH 0.65 // [0.25 0.45 0.65 0.80 1.00]

#define REFLECTION_QUALITY 4 // [0 1 2 3 4 5 6]
#define CLOUD_QUALITY 4 // [0 1 2 3 4 5 6]
#define CLOUD_STRENGTH 0.45 // [0.00 0.20 0.35 0.45 0.60 0.75]
#define FOG_QUALITY 4 // [0 1 2 3 4 5 6]
#define FOG_DENSITY 0.55 // [0.20 0.35 0.55 0.75 1.00]
#define SKY_QUALITY 4 // [0 1 2 3 4 5 6]
#define LIGHTING_QUALITY 4 // [0 1 2 3 4 5 6]
#define POST_PROCESSING_QUALITY 4 // [0 1 2 3 4 5 6]

#define RENDER_SCALE 1.00 // [0.65 0.70 0.75 0.80 0.85 0.90 1.00]
#define EXPOSURE 1.00 // [0.70 0.80 0.90 1.00 1.10 1.20 1.35]
#define CONTRAST 1.05 // [0.85 0.95 1.00 1.05 1.10 1.20 1.30]
#define SATURATION 1.06 // [0.80 0.90 1.00 1.06 1.12 1.20 1.30]
#define VIBRANCE 0.05 // [0.00 0.03 0.05 0.08 0.12]
#define GAMMA 1.00 // [0.85 0.95 1.00 1.05 1.15]

const int shadowMapResolution = SHADOW_RESOLUTION;
const float sunPathRotation = -35.0;
const float ambientOcclusionLevel = 0.85;
const float wetnessHalflife = 300.0;
const float drynessHalflife = 80.0;

#endif
