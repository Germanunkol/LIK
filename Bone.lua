local class = require("lib/middleclass/middleclass")
local cpml = require("lib.cpml")

local Bone = class("Bone")

function Bone:initialize( skeleton, parent, basePos, baseRot, length )
	self.skeleton = skeleton
	self.parent = parent or nil
	self:setLocalPos( basePos or cpml.vec3(0,0,0) )
	self:setLocalRot( baseRot or cpml.quat(0,0,0,1) )
	self.len = length or 0
	self.skeleton:addBone( self )
end

function Bone:setLocalPos( p )
	self.lPos = p
end
function Bone:setLocalRot( r )
	self.lRot = r
end
function Bone:getPos()
	if self.parent then
		pPos = self.parent:getEndPos()
		pRot = self.parent:getRot()
		--r = self.lRot*pRot
		self.pos = pPos + cpml.quat.mul_vec3( pRot, self.lPos )
	else
		self.pos = self.lPos
	end
	return self.pos
end
function Bone:getEndPos()
	return self:toGlobal( cpml.vec3( self.len,0,0 ) )
end
function Bone:getRot()
	if self.parent then
		pRot = self.parent:getRot()
		self.rot = self.lRot*pRot
	else
		self.rot = self.lRot
	end
	return self.rot
end
function Bone:toGlobal( vec )
	p = self:getPos()
	r = self:getRot()
	rotated = cpml.quat.mul_vec3( r, vec )
	return p + rotated
end

return Bone
