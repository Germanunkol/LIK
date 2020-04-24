local class = require("lib/middleclass/middleclass")
local cpml = require("lib.cpml")

local Skeleton = class("Skeleton")

function Skeleton:initialize( pos, rot )
	self.pos = pos or cpml.vec3()
	self.rot = rot or cpml.quat()
	self.bones = {}
end

function Skeleton:addBone( b )
	if self.bones[b] == nil then
		self.bones[b] = true
	end
end

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
	for b,t in pairs(self.bones) do
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
