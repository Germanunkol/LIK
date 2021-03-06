local class = require("lib/middleclass/middleclass")
local cpml = require("lib.cpml")

local Skeleton = class("Skeleton")

function Skeleton:initialize( pos, rot )
	self.pos = pos or cpml.vec3()
	self.rot = rot or cpml.quat()
	self.bones = {}
	self.roots = {}
end

function Skeleton:addBone( b )
	table.insert( self.bones, b )
	if not b.parent then
		table.insert( self.roots, b )
	end
end

--[[function Skeleton:finalize()
	for i,r in ipairs( self.roots ) do
		self:calcBindPose( r )
	end
end]]

--[[function Skeleton:calcBindPose( bone )
	local bindPose = cpml.mat4()
	cpml.mat4.translate( bindPose, bindPose, bone.lPos )
	local rot = cpml.mat4.from_quaternion( bone.lRot )
	cpml.mat4.mul( bindPose, bindPose, rot )
	if bone.parent then
		cpml.mat4.mul( bindPose, bindPose, bone.parent.bindPose )
	end
	bone.bindPose = bindPose
	print("bindPose", bindPose)
	bone.invBindPose = cpml.mat4()
	cpml.mat4.invert( bone.invBindPose, bindPose )

	for i,c in ipairs( bone.children ) do
		self:calcBindPose( c )
	end
end]]

--[[function Skeleton:bindVertices( verts )
	for i, v in pairs( verts ) do
		local bone = self.bones[ v.boneIDs[1] ]
		if not bone.bindPose then
			error("You must call Skeleton:finalize() before calling bindVertices!" )
		end
		pos = {v.lPos.x, v.lPos.y, v.lPos.z, 1 }
		if v.boneIDs[1] == 2 then
			print(bone.bindPose)
			print(v.lPos)
		end
		cpml.mat4.mul_vec4( pos, bone.bindPose, pos )
		v.pos = cpml.vec3(pos[1],pos[2],pos[3])
	end
end]]


function Skeleton:toLocalPos( pos )
	local p = self.pos
	local r = self.rot
	local diff = pos - p
	local rInv = cpml.quat.inverse( r )
	local lPos = cpml.quat.mul_vec3( rInv, diff )
	return lPos
end
function Skeleton:toGlobalPos( pos )
	local p = self.pos
	local r = self.rot
	local rotated = cpml.quat.mul_vec3( r, pos )
	return p + rotated
end
function Skeleton:toGlobalDir( vec )
	local rotated = cpml.quat.mul_vec3( self.rot, vec )
	return rotated
end
function Skeleton:toLocalDir( vec )
	local invRot = cpml.quat.inverse( self.rot )
	local rotated = cpml.quat.mul_vec3( invRot, vec )
	return rotated
end

function Skeleton:getDebugData( drawConstraints )
	local data = {}
	if self.debugChain then
		for i,b in ipairs(self.debugChain) do
			local boneData = b:getDebugData( drawConstraints )
			for key, elem in pairs(boneData) do
				elem.col[1] = elem.col[1]*0.5
				elem.col[2] = elem.col[2]*2
				elem.col[3] = elem.col[3]*0.5
				table.insert( data, elem )
			end
		end
	end
	for i,b in ipairs(self.bones) do
		local boneData = b:getDebugData( drawConstraints )
		for key, elem in pairs(boneData) do
			table.insert( data, elem )
		end
	end
	return data
end

function Skeleton:setDebugChain( chain )
	self.debugChain = {}
	for i,b in ipairs(chain) do
		local bNew = b:clone()
		local parent = self.debugChain[#self.debugChain]
		table.insert( self.debugChain, bNew )
	end
end



function test()
	print("Testing Skeleton functions")
	local skel = Skeleton:new()
	skel.pos = cpml.vec3( math.random(), math.random(), math.random() )
	skel.rot = cpml.quat.from_angle_axis( math.random(), cpml.vec3(0,0,1) )

	local pos = cpml.vec3(math.random(), math.random(), math.random())
	local lPos = skel:toLocalPos( pos )
	local posRecon = skel:toGlobalPos( lPos )

	print("Pos", pos)
	print("local pos", lPos)
	print("reconstructed pos", posRecon )
end
test()

return Skeleton
