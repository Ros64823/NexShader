#ifndef NEX_LIGHTING_GLSL
#define NEX_LIGHTING_GLSL
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
vec3 sunColor(){float t=saturate(sunPosition.y/100.0); float dusk=smoothstep(0.0,0.28,1.0-abs(float(worldTime)-12000.0)/12000.0); return mix(vec3(1.0,0.52,0.28),vec3(1.0,0.92,0.78),t)*(1.0-rainStrength*0.35)+dusk*vec3(0.10,0.03,0.01);}
vec3 ambientColor(){float day=saturate(sunPosition.y/100.0); float sky=float(eyeBrightnessSmooth.y)/240.0; return mix(vec3(0.025,0.035,0.06),vec3(0.23,0.30,0.38),max(day,sky*0.6))*(1.0-rainStrength*0.25);}
vec3 applyLighting(vec3 albedo, vec3 normal, vec3 viewPos, float shadow){vec3 l=normalize(sunPosition); float ndl=saturate(dot(normal,l)); float wrap=saturate((dot(normal,l)+0.35)/1.35); vec3 amb=ambientColor()*(0.55+0.45*normal.y); vec3 sun=sunColor()*(ndl*shadow+0.18*wrap); return albedo*(amb+sun);}
#endif
