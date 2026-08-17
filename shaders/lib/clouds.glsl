#ifndef NEX_CLOUDS_GLSL
#define NEX_CLOUDS_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
uniform float frameTimeCounter;
float cloudLayer(vec3 dir){float q=float(CLOUD_QUALITY); if(q<1.0) return 0.0; vec2 p=dir.xz/max(dir.y+0.25,0.15)*0.06+frameTimeCounter*0.0015; float n=hash12(floor(p*(8.0+q*4.0))); return smoothstep(0.55,0.82,n)*saturate(dir.y*2.0);}
#endif
