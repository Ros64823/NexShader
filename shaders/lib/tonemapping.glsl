#ifndef NEX_TONEMAPPING_GLSL
#define NEX_TONEMAPPING_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
vec3 tonemapNex(vec3 c){c*=EXPOSURE; c=(c*(2.51*c+0.03))/(c*(2.43*c+0.59)+0.14); float y=luma(c); c=mix(vec3(y),c,SATURATION); return saturate((c-0.5)*CONTRAST+0.5);}
#endif
