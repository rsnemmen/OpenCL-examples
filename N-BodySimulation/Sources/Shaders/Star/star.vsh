/*
 <codex>
 <abstract>
 Vertex shader for stars.
 </abstract>
 </codex>
 */

void main()
{
    gl_FrontColor = gl_Color;
    gl_TexCoord[0] = gl_MultiTexCoord0;
    gl_Position = ftransform();
}
