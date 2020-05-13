//varying vec3 coord;

vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 col = color*Texel(tex,texcoord);

	if( col.a == 0 )
		discard;

	return col;
}
