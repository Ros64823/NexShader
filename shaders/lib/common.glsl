#ifndef NEX_COMMON_GLSL
#define NEX_COMMON_GLSL
#include "/lib/uniforms.glsl"
#define saturate(x) clamp(x, 0.0, 1.0)
float luma(vec3 c){return dot(c, vec3(0.2126,0.7152,0.0722));}
float hash12(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
vec3 decodeNormal(vec3 n){return normalize(n*2.0-1.0);}
vec3 encodeNormal(vec3 n){return n*0.5+0.5;}
vec3 screenToView(vec2 uv,float depth,mat4 invProj){vec4 p=vec4(uv*2.0-1.0,depth*2.0-1.0,1.0);p=invProj*p;return p.xyz/max(p.w,0.00001);}
float linearDepth(float d,float near,float far){return (2.0*near)/(far+near-d*(far-near));}
#endif
