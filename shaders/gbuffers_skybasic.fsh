#version 120
/* DRAWBUFFERS:01 */
#include "/lib/sky.glsl"
#include "/lib/clouds.glsl"
varying vec3 dir;
void main(){
    vec3 d = normalize(dir);
    vec3 color = nexSkyGradient(d);
    color = mix(color, vec3(0.82, 0.88, 0.95), nexCloudLayer(d));
    color += nexStarField(d) * vec3(0.70, 0.80, 1.00);
    gl_FragData[0] = vec4(color, 1.0);
    gl_FragData[1] = vec4(0.5, 1.0, 0.5, 1.0);
}
