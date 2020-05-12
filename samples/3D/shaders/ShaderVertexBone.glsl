attribute vec4 BoneIndices;
attribute vec4 BoneWeights;

uniform mat4 projMat;
uniform mat4 viewMat;
uniform mat4 bones[64];
uniform float modelScale;

varying vec4 debugCol;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
	debugCol = vec4( BoneIndices.x/4*vertex_position.z, BoneIndices.y/4*vertex_position.z, 0, 1 );


	vec4 vert = (bones[int(BoneIndices[0])]*vertex_position);
	//vert = (bones[int(BoneIndices[1])]*vertex_position)*BoneWeights[1] + vert;

	mat4 scaleMat = mat4(modelScale);
	scaleMat[3][3] = 1;

	//return projMat * viewMat * TransformMatrix * vec4( vert.xyz, 1.0 );
	//return projMat * viewMat * TransformMatrix * scaleMat * vertex_position + 0.000001*vert;
	return projMat * viewMat * TransformMatrix * scaleMat * vec4( vert.xyz, 1.0 );
}

