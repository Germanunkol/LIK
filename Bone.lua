local class = require("lib/middleclass/middleclass")
local cpml = require("lib.cpml")

local Bone = class("Bone")

function Bone:initialize( skeleton, parent, baseRot, length )
	self.skeleton = skeleton
	self.parent = parent or nil
	self.pos = basePos or cpml.vec3(0,0,0)
	self:setRot( baseRot or cpml.quat(0,0,0,1) )
	self.len = length or 0
	self.skeleton:addBone( self )
end

function Bone:getPos()
	return self.pos
end
function Bone:getEndPos()
	print( cpml.vec3( self.len,0,0 ) )
	return self:toGlobal( cpml.vec3( self.len,0,0 ) )
end
function Bone:setRot( r )
	self.rot = r
end
function Bone:getRot()
	return self.rot
end
function Bone:toGlobal( vec )
	p = self:getPos()
	r = self:getRot()
	rotated = cpml.quat.mul_vec3( r, vec )
	return p + rotated
end

return Bone
