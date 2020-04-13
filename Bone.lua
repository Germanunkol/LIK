local class = require("lib/middleclass/middleclass")
local cpml = require("lib.cpml")

local Bone = class("Bone")

function Bone:initialize( skeleton, parent, baseRot, length )
	self.skeleton = skeleton
	self.parent = parent or nil
	self.basePos = basePos or cpml.vec3(0,0,0)
	self.baseRot = baseRot or cpml.quat(0,0,0,1)
	self.len = len or 0
	self.skeleton:addBone( self )
end

function Bone:getPos()
	return cpml.vec3( 0,0,0 )
end
function Bone:getEndPos()
	return cpml.vec3( 1,0,0 )
end
function Bone:getRot()
	return cpml.quat( 0,0,0,1 )
end
function Bone:toGlobal( vec )
	p = self:getPos()
	r = self:getRot()
	rotated = cpml.quat.mul_vec3( r, vec )
	return p + rotated
end

return Bone
