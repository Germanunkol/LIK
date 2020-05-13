uniform mat4 projMat;
uniform mat4 viewMat;
uniform float scale = 1;

//varying vec3 coord;
//varying float zCoord;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
	vec4 vPos = vertex_position;
	mat4 scaleMat = mat4(scale);
	scaleMat[3][3] = 1;
	return projMat * viewMat * scaleMat * TransformMatrix * vPos;
}

