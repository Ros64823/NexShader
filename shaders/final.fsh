#version 120
#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/tonemapping.glsl"
#include "/lib/lighting.glsl"
varying vec2 texcoord;
void main(){
    vec3 color = texture2D(colortex0, texcoord).rgb;
    #if NEX_DEBUG == 9
        // Luminance heatmap of the pre-tonemap linear buffer:
        // black->blue (<0.01), blue->green (0.01..0.10), green->red (0.10..1.0), white (>1.0)
        float y = nexLuma(color);
        vec3 heat = vec3(0.0, 0.0, saturate(y / 0.01));
        if (y > 0.01) heat = mix(vec3(0.0, 0.0, 1.0), vec3(0.0, 1.0, 0.0), saturate((y - 0.01) / 0.09));
        if (y > 0.10) heat = mix(vec3(0.0, 1.0, 0.0), vec3(1.0, 0.0, 0.0), saturate((y - 0.10) / 0.90));
        if (y > 1.00) heat = vec3(1.0);
        gl_FragColor = vec4(heat, 1.0);
    #elif NEX_DEBUG != 0
        // Debug views bypass tonemapping so raw component values are visible.
        gl_FragColor = vec4(color, 1.0);
    #else
        // Gentle eye adaptation: fixed boost driven only by world-space sun
        // elevation (time of day), never by screen content or camera direction.
        float nightBoost = mix(3.0, 1.0, nexDayFactor());
        gl_FragColor = vec4(nexTonemap(color, nightBoost), 1.0);
    #endif
}
