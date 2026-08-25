#ifndef NEX_UNIFORMS_GLSL
#define NEX_UNIFORMS_GLSL

// Single declaration point for every uniform shared by more than one lib.
// Declaring the same uniform in two included libs is a GLSL redefinition
// error, so each one lives here exactly once.
uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 fogColor;
uniform ivec2 eyeBrightnessSmooth;
uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;
uniform float rainStrength;
uniform float frameTimeCounter;
uniform int worldTime;
uniform int isEyeInWater;

#endif
