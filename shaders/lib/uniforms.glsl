#ifndef NEX_UNIFORMS_GLSL
#define NEX_UNIFORMS_GLSL
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform ivec2 eyeBrightnessSmooth;
uniform float rainStrength;
uniform int worldTime;
uniform float frameTimeCounter;
uniform vec3 fogColor;
uniform float far;
uniform float near;
uniform int isEyeInWater;
uniform float viewWidth;
uniform float viewHeight;
uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2DShadow shadowtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
#endif
