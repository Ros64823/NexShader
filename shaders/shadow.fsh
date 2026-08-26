#version 120
uniform sampler2D texture;
varying vec2 texcoord;
varying vec4 color;
void main(){
    float alpha = texture2D(texture, texcoord).a * color.a;
    if (alpha < 0.10) discard;
    gl_FragData[0] = vec4(vec3(gl_FragCoord.z), 1.0);
}
