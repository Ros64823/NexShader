#version 120
/* DRAWBUFFERS:0 */
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/lighting.glsl"
#include "/lib/reflections.glsl"
#include "/lib/bloom.glsl"
#include "/lib/volumetrics.glsl"

varying vec2 texcoord;

void main() {
    vec3 lit = texture2D(colortex0, texcoord).rgb;
    vec4 normalData = texture2D(colortex1, texcoord);
    
    // Apply screen-space reflections for water (alpha < 0.75 indicates water with alpha=0.50)
    if (normalData.a < 0.75) {
        lit = nexScreenReflection(texcoord, lit, 0.6);
    }
    
    // Add bloom pass
    lit += nexBloom(texcoord);
    
    // Add volumetric lighting (god rays)
    lit += nexSunColor() * nexGodRays(texcoord);
    
    gl_FragData[0] = vec4(lit, 1.0);
}
