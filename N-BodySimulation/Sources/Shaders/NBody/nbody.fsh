/*
 <codex>
 <abstract>
 Fragment shader for display splat texture.
 </abstract>
 </codex>
 */

uniform sampler2D splatTexture;

void main()
{
    gl_FragColor = texture2D(splatTexture, gl_TexCoord[0].st) * gl_Color;
}
