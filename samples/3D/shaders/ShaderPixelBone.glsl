//varying vec3 coord;
varying vec4 debugCol;

vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
{
    return color*Texel(tex,texcoord);
    //return vec4(debugCol.xyz, 1);
}
