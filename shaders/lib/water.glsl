#ifndef NEX_WATER_GLSL
#define NEX_WATER_GLSL
#include "/lib/config.glsl"
#include "/lib/common.glsl"
uniform float frameTimeCounter;
vec3 waterColor(vec3 base, vec3 normal, vec3 viewDir, float depth){float fres=pow(1.0-saturate(dot(normal,-viewDir)),3.0); vec3 shallow=vec3(0.18,0.55,0.62), deep=vec3(0.03,0.16,0.28); return mix(mix(shallow,deep,saturate(depth*2.0)),vec3(0.65,0.86,1.0),fres*0.35)*mix(0.75,1.0,float(WATER_QUALITY)/6.0);}
vec3 waterNormal(vec3 n, vec2 uv){float w=sin((uv.x+frameTimeCounter*0.025)*80.0)+cos((uv.y-frameTimeCounter*0.018)*64.0); return normalize(n+vec3(w*0.035*float(WATER_QUALITY),0.0,w*0.025*float(WATER_QUALITY)));}
#endif
