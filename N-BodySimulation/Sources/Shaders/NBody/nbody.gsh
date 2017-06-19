/*
 <codex>
 <abstract>
 Geometry shader for N-Body billboard.
 </abstract>
 </codex>
 */

#extension GL_EXT_geometry_shader4:require

vec4 billboard(vec4 p, vec2 delta)
{
    return vec4(
               dot(delta, gl_ModelViewMatrix[0].st) + p.x,
               dot(delta, gl_ModelViewMatrix[1].st) + p.y,
               dot(delta, gl_ModelViewMatrix[2].st) + p.z,
               1.0);
}

void main()
{
    float s = 0.5 * gl_PointSizeIn[0];
    vec4 p = gl_PositionIn[0];

    gl_Position = gl_ModelViewProjectionMatrix * billboard(p, vec2(s, -s));
    gl_TexCoord[0] = vec4(1, 0, 0, 1);
    gl_FrontColor = gl_FrontColorIn[0];
    EmitVertex();

    gl_Position = gl_ModelViewProjectionMatrix * billboard(p, vec2(-s, -s));
    gl_TexCoord[0] = vec4(0, 0, 0, 1);
    gl_FrontColor = gl_FrontColorIn[0];
    EmitVertex();

    gl_Position = gl_ModelViewProjectionMatrix * billboard(p, vec2(s, s));
    gl_TexCoord[0] = vec4(1, 1, 0, 1);
    gl_FrontColor = gl_FrontColorIn[0];
    EmitVertex();

    gl_Position = gl_ModelViewProjectionMatrix * billboard(p, vec2(-s, s));
    gl_TexCoord[0] = vec4(0, 1, 0, 1);
    gl_FrontColor = gl_FrontColorIn[0];
    EmitVertex();

    EndPrimitive();
}
