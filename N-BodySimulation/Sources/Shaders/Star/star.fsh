/*
 <codex>
 <abstract>
 Fragment shader for stars.
 </abstract>
 </codex>
 */

void main()
{
    float d = distance(vec2(0.5, 0.5), gl_TexCoord[0].st);
    float s = clamp(1.0 - 2.0 * d, 0.0, 1.0);
    float t = cos(0.5 * 3.1415 * s);
    float c = 1.0 - pow(t, 0.25);
    
    gl_FragColor = vec4(c, c, c, 1.0) * gl_Color;
}
