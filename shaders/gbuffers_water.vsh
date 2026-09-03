#version 120

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 color;
varying vec3 normal;
varying vec3 viewPos;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    color = gl_Color;
    normal = normalize(gl_NormalMatrix * gl_Normal);
    vec4 v = gl_ModelViewMatrix * gl_Vertex;
    viewPos = v.xyz;
    gl_Position = gl_ProjectionMatrix * v;
}
