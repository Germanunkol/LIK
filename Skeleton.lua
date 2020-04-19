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

function Skeleton:getDebugData()
	local data = {}
	for b,t in pairs(self.bones) do
		local boneData = b:getDebugData()
		for key, elem in pairs(boneData) do
			table.insert( data, elem )
		end
	end
	return data
end

return Skeleton
