
local vFormatPlain= {{"VertexPosition", "float", 3},
	{"VertexTexCoord", "float",2},
	{"VertexColor", "float", 3}}
local vFormatBone= {{"VertexPosition", "float", 3},
	{"VertexTexCoord", "float",2},
	{"VertexColor", "float", 3},
	{"BoneIndices", "float", 4},
	{"BoneWeights", "float", 4}}

local meters2Pixels = 50

local const = {
	vFormatPlain = vFormatPlain,
	vFormatBone = vFormatBone,
	meters2Pixels = meters2Pixels,
	pixels2Meters = 1/meters2Pixels
}

return const
