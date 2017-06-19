/*
 <codex>
 <abstract>
 N-Body vertex shader.
 </abstract>
 </codex>
 */

uniform sampler2D splatTexture;
uniform float pointSize;

void main()
{
    gl_Position = gl_Vertex;
    gl_PointSize = 0.05 * pointSize;
    gl_FrontColor = gl_Color;
}
