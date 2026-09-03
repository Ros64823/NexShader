#version 120

varying vec3 dir;

void main() {
    vec4 v = gl_ModelViewMatrix * gl_Vertex;
    dir = normalize(v.xyz);
    gl_Position = ftransform();
}
