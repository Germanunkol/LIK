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

function angleRange( v )
	while v < -math.pi do
		v = v + math.pi*2
	end
	while v > math.pi do
		v = v - math.pi*2
	end
	return v
end

function Bone:setLocalRot( r )
	if self.constraint ~= nil then
		origAngle, origAxis = cpml.quat.to_angle_axis( r )
		-- Find component which rotates around the self constraint axis (twist)
		swing, twist = swingTwistDecomposition( r, self.constraint.axis )
		-- This is the new rotation:	
		r = twist
		-- Clamp this new rotation:
		tAngle, tAxis = cpml.quat.to_angle_axis( twist )
		-- Ensure that the rotation axis was not flipped:
		if cpml.vec3.dist2( tAxis, self.constraint.axis ) > 0.5 then
			tAxis = -tAxis
			tAngle = -tAngle
		end
		tAngle = angleRange( tAngle )
		tAngleC = math.min(math.max(tAngle,self.constraint.minAng),self.constraint.maxAng)
		r = cpml.quat.from_angle_axis( tAngleC, tAxis )
	end
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

function swingTwistDecomposition( rotation, direction )
	--local rAngle, rAxis = cpml.quat.to_angle_axis( rotation )
	local rAxis = cpml.vec3( rotation.x, rotation.y, rotation.z )
	local proj = direction*cpml.vec3.dot( rAxis, direction )
	local twist = cpml.quat( proj.x, proj.y, proj.z, rotation.w )
	local twist = cpml.quat.normalize( twist )
	local swing = rotation * cpml.quat.conjugate( twist )
	return swing, twist
end

function Bone:setConstraint( axis, minAng, maxAng )
	self.constraint = {
		axis=cpml.vec3.normalize(axis),
		minAng=minAng,
		maxAng=maxAng
	}
end

return Bone
