#ifndef NEX_SAFETY_GLSL
#define NEX_SAFETY_GLSL

// Numeric guards. A shader has no way to raise an error: a division by zero or
// a normalize() of a zero-length vector produces NaN/Inf that is blended into
// every later stage until the whole frame turns black or white. These helpers
// replace those undefined results with an explicit, visible fallback instead of
// letting them travel silently through the pipeline.

#define NEX_EPS 1.0e-8
#define NEX_FLOAT_MAX 3.402823e38

// GLSL 120 has no isnan(); NaN fails every comparison, so both tests are false.
bool nexIsNan(float x){return !(x<=0.0 || x>=0.0);}
bool nexIsFinite(float x){return (x<=0.0 || x>=0.0) && abs(x)<=NEX_FLOAT_MAX;}
bool nexIsFinite(vec3 v){return nexIsFinite(v.x) && nexIsFinite(v.y) && nexIsFinite(v.z);}

float safeDiv(float a, float b, float fallback){return abs(b)<NEX_EPS ? fallback : a/b;}

// Keeps the sign of the divisor: clamping a negative denominator to a small
// positive value flips the result instead of just bounding it.
float nexGuardDenom(float b){
 if(nexIsNan(b) || abs(b)<NEX_EPS) return NEX_EPS;
 return b<0.0 ? min(b,-NEX_EPS) : max(b,NEX_EPS);
}

vec2 safeNormalize(vec2 v, vec2 fallback){float l2=dot(v,v); return (l2>NEX_EPS && nexIsFinite(l2)) ? v*inversesqrt(l2) : fallback;}
vec3 safeNormalize(vec3 v, vec3 fallback){float l2=dot(v,v); return (l2>NEX_EPS && nexIsFinite(l2)) ? v*inversesqrt(l2) : fallback;}

// Last line of defence before writing to a render target: one bad component
// would otherwise be sampled by the next pass and spread across the screen.
vec3 sanitize(vec3 c, vec3 fallback){return nexIsFinite(c) ? c : fallback;}
float sanitize(float x, float fallback){return nexIsFinite(x) ? x : fallback;}

// Sampling outside [0,1] relies on the buffer wrap mode and silently returns
// data from the opposite edge, so screen-space lookups are clamped explicitly.
vec2 clampScreenUV(vec2 uv){return clamp(uv, vec2(0.0), vec2(1.0));}

#endif
