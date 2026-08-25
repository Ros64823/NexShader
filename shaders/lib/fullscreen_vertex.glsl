#ifndef NEX_FULLSCREEN_VERTEX_GLSL
#define NEX_FULLSCREEN_VERTEX_GLSL
varying vec2 texcoord;
void setupFullscreenVertex(){texcoord=gl_MultiTexCoord0.xy; gl_Position=ftransform();}
#endif
