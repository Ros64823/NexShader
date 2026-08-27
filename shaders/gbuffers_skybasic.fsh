#version 120
/* DRAWBUFFERS:01 */
#include "/lib/sky.glsl"
#include "/lib/clouds.glsl"
varying vec3 dir;
void main(){
    vec3 d = normalize(dir);
    vec3 color = nexSkyGradient(d);
    color = mix(color, vec3(0.62, 0.72, 0.86), nexCloudLayer(d));
    color += nexStarField(d) * vec3(0.45, 0.55, 0.90);
    gl_FragData[0] = vec4(color, 1.0);
    gl_FragData[1] = vec4(0.5, 1.0, 0.5, 1.0);
}
