
package.path = "../../?.lua;" .. package.path
package.path = "../../?/init.lua;" .. package.path

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")
local Skeleton = require("Skeleton")
local Bone = require("Bone")
local Vertex = require("Vertex")

local Arm = class("Arm")

function Arm:initialize()
	self.skel = Skeleton:new()

	self.scale = 300

	local b1_0 = Bone:new( self.skel, nil, vZero, noRot, 0.1 )
	local b1_1 = Bone:new( self.skel, b1_0, cpml.vec3(0.1,0,0), noRot, 0.2 )
	local b1_2 = Bone:new( self.skel, b1_1, cpml.vec3(0.2,0,0), noRot, 0.3 )

	b1_0:setConstraint( cpml.vec3(0,0,1), math.pi*0.5, math.pi*0.5 )
	b1_1:setConstraint( cpml.vec3(0,0,1), -math.pi*0.5, math.pi*0.5 )
	b1_2:setConstraint( cpml.vec3(0,0,1), -math.pi*0.25, math.pi*0.25 )

	self.skel:finalize()

	self:createMesh()

	self.shader = love.graphics.newShader( "shaders/ShaderPixelBone.glsl",
		"shaders/ShaderVertexBone.glsl" )
end

function Arm:createMesh()
	local vertexformat= {{"VertexPosition", "float", 3},
	{"VertexTexCoord", "float",2},
	{"VertexColor", "float", 3},
	{"BoneIndices", "float", 4},
	{"BoneWeights", "float", 4}}

	local function insertFace( v1,v2,v3,v4 )
		table.insert(v,v1) table.insert(v,v2) table.insert(v,v3)
		table.insert(v,v1) table.insert(v,v3) table.insert(v,v4)
	end

	local vList = {}
	local vMap = {}
	print("bones", self.skel.bones, #self.skel.bones)
	for i,b in ipairs( self.skel.bones ) do
		boneID = i
		print("Bone", boneID)
		v1 = Vertex:new( cpml.vec3(), #vList+1, boneID )

		v2 = Vertex:new( cpml.vec3(b.len*0.25, b.len*0.25, 0), #vList+2, boneID )
		v3 = Vertex:new( cpml.vec3(b.len*0.25, 0, b.len*0.25), #vList+3, boneID )
		v4 = Vertex:new( cpml.vec3(b.len*0.25, -b.len*0.25, 0), #vList+4, boneID )
		v5 = Vertex:new( cpml.vec3(b.len*0.25, 0, -b.len*0.25), #vList+5, boneID )

		v6 = Vertex:new( cpml.vec3(b.len, 0, 0), #vList+6, boneID )

		-- Insert vertices:
		table.insert( vList, v1 )
		table.insert( vList, v2 )
		table.insert( vList, v3 )
		table.insert( vList, v4 )
		table.insert( vList, v5 )
		table.insert( vList, v6 )

		-- Insert triangles:
		table.insert( vMap, v1.ID) table.insert( vMap, v2.ID ) table.insert( vMap, v3.ID )
		table.insert( vMap, v1.ID) table.insert( vMap, v3.ID ) table.insert( vMap, v4.ID )
		table.insert( vMap, v1.ID) table.insert( vMap, v4.ID ) table.insert( vMap, v5.ID )
		table.insert( vMap, v1.ID) table.insert( vMap, v5.ID ) table.insert( vMap, v2.ID )

		table.insert( vMap, v2.ID) table.insert( vMap, v3.ID ) table.insert( vMap, v6.ID )
		table.insert( vMap, v3.ID) table.insert( vMap, v4.ID ) table.insert( vMap, v6.ID )
		table.insert( vMap, v4.ID) table.insert( vMap, v5.ID ) table.insert( vMap, v6.ID )
		table.insert( vMap, v5.ID) table.insert( vMap, v2.ID ) table.insert( vMap, v6.ID )
	end

	self.skel:bindVertices( vList )

	local vListFinal = {}
	for i,v in ipairs(vList) do
		print(i, v)
		table.insert( vListFinal, v:toTable() )
	end

	for i, v in ipairs(vListFinal) do
		print(i,v)
		for j, d in ipairs(v) do
			print("  ", j, d)
		end
	end

	self.mesh = love.graphics.newMesh( vertexformat, vListFinal, "triangles" )
	self.mesh:setVertexMap( vMap )
end

function Arm:draw( projMat, viewMat )
	local bones = {}
	for i,b in ipairs(self.skel.bones) do
		local bone = {}
		local mat = b:getLocalMat()
		for x=1,4 do
			for y=1,4 do
				table.insert( bone, mat[(y-1)*4+x] )
			end
		end
		table.insert(bones, bone)
	end
	self.shader:send("bones", unpack(bones))
	self.shader:send("projMat", projMat)
	self.shader:send("viewMat", viewMat)
	self.shader:send("modelScale", self.scale)
	love.graphics.setShader( self.shader )
	love.graphics.setColor( 1,1,1 )
	love.graphics.draw( self.mesh )
end

return Arm
