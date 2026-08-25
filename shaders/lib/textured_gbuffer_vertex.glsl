#ifndef NEX_TEXTURED_GBUFFER_VERTEX_GLSL
#define NEX_TEXTURED_GBUFFER_VERTEX_GLSL
varying vec2 texcoord; varying vec4 color; varying vec3 normal; varying vec3 viewPos;
void setupTexturedGbufferVertex(){texcoord=(gl_TextureMatrix[0]*gl_MultiTexCoord0).xy; color=gl_Color; normal=normalize(gl_NormalMatrix*gl_Normal); vec4 v=gl_ModelViewMatrix*gl_Vertex; viewPos=v.xyz; gl_Position=gl_ProjectionMatrix*v;}
#endif
