local class = require("lib/middleclass/middleclass")
local cpml = require("lib.cpml")
local util = require("util")

local Bone = class("Bone")

function Bone:initialize( skeleton, parent, basePos, baseRot, length )
	self.skeleton = skeleton
	self.parent = parent or nil
	self.basePos = basePos or cpml.vec3(0,0,0)
	self.baseRot = baseRot or cpml.quat(0,0,0,1)
	self:setLocalPos( self.basePos )
	self:setLocalRot( self.baseRot )
	self.len = length or 0
	if self.skeleton then
		self.skeleton:addBone( self )
	end
end

-- Set local pos, i.e. pos in the parent's space:
function Bone:setLocalPos( p )
	self.lPos = p
end

function Bone:setPos( p )
	if self.parent then
		lp = self.parent:toLocal( p )
		self:setLocalPos( lp )
	else
		self:setLocalPos( p )
	end
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
	return self:toGlobalPos( cpml.vec3( self.len,0,0 ) )
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
function Bone:toGlobalPos( pos )
	p = self:getPos()
	r = self:getRot()
	rotated = cpml.quat.mul_vec3( r, pos )
	return p + rotated
end
function Bone:toLocalPos( pos )
	p = self:getPos()
	r = self:getRot()
	diff = pos - p
	rInv = cpml.quat.inverse( r )
	lPos = cpml.quat.mul_vec3( rInv, diff )
	return lPos
end

function Bone:setConstraint( axis, minAng, maxAng )
	assert( minAng <= maxAng,
		"Can't set constraint: Minimum angle must be smaller than maximum angle")
	assert( minAng >= -math.pi,
		"Can't set constraint: Minimum angle must be greater than -pi")
	assert( maxAng <= math.pi,
		"Can't set constraint: Maximum angle must be smaller than pi")
	self.constraint = {
		axis=cpml.vec3.normalize(axis),
		minAng=minAng,
		maxAng=maxAng
	}
end

function Bone:getDebugData()
	local data = {}

	local pS = self:getPos()
	local pE = self:getEndPos()
	local len = cpml.vec3.len( pS - pE )
	--r = b:getRot()
	--tmp = cpml.vec3( 1,0,0 )
	local w = 0.15
	local pO0 = self:toGlobalPos( cpml.vec3( len*0.05, len*w, 0 ) )
	local pO1 = self:toGlobalPos( cpml.vec3( len*0.05, -len*w, 0 ) )

	-- Insert a triangle:
	local d = { col={0.25,0.25,0.5, 0.9},
		drawType="tri",
		p0=pS,
		p1=pO0,
		p2=pE,
		p3=pO1,
	}
	table.insert( data, d )

	-- Insert a line:
	local d = { col={0.9,0.9,0.9, 0.9},
		drawType="line",
		p0=pS,
		p1=pE
	}
	table.insert( data, d )

	-- Draw constraint, if any:
	if self.constraint then
		local minRot = cpml.quat.from_angle_axis( self.constraint.minAng,
				self.constraint.axis )
		local maxRot = cpml.quat.from_angle_axis( self.constraint.maxAng,
				self.constraint.axis )

		-- My end pos in local coordinates...
		local lEndPos = cpml.vec3( self.len,0,0 )
		-- ... rotated by the constraints:
		local lEndPosRotMin = cpml.quat.mul_vec3( minRot, lEndPos )
		local lEndPosRotMax = cpml.quat.mul_vec3( maxRot, lEndPos )

		local pMin, pMax = lEndPosRotMin, lEndPosRotMax
		if self.parent then
			endPosRotMinParent = cpml.quat.mul_vec3( self.parent:getRot(), lEndPosRotMin )
			pMin = self.parent:getEndPos() + endPosRotMinParent
			
			endPosRotMaxParent = cpml.quat.mul_vec3( self.parent:getRot(), lEndPosRotMax )
			pMax = self.parent:getEndPos() + endPosRotMaxParent
		end
		
		local d = { col={0.9,0.2,0.2,0.9},
			drawType="line",
			p0=pS,
			p1=pMin
		}
		table.insert( data, d )
		local d = { col={0.9,0.2,0.2,0.9},
			drawType="line",
			p0=pS,
			p1=pMax
		}
		table.insert( data, d )
	end
	return data
end

function test()
	math.randomseed(123)
	local pos = cpml.vec3(math.random(), math.random(), math.random())
	local rot = cpml.quat.from_angle_axis( math.random(), cpml.vec3(0,0,1) )
	local b1 = Bone:new( nil, nil, pos, rot, math.random() )

	local pos = cpml.vec3(math.random(), math.random(), math.random())
	local rot = cpml.quat.from_angle_axis( math.random(), cpml.vec3(0,0,1) )
	local b2 = Bone:new( nil, b1, pos, rot, math.random() )

	local pos = cpml.vec3(math.random(), math.random(), math.random())
	local rot = cpml.quat.from_angle_axis( math.random(), cpml.vec3(0,0,1) )
	local b3 = Bone:new( nil, b2, pos, rot, math.random() )

	print("Testing Bone 1:")
	local globalPos = cpml.vec3(math.random(), math.random(), math.random())
	local localPos = b1:toLocalPos( globalPos )
	local globalPosRecon = b1:toGlobalPos( localPos )
	print("Global pos", globalPos)
	print("Local pos", localPos)
	print("Global pos recon", globalPosRecon)

	print("Testing Bone 2:")
	local globalPos = cpml.vec3(math.random(), math.random(), math.random())
	local localPos = b2:toLocalPos( globalPos )
	local globalPosRecon = b2:toGlobalPos( localPos )
	print("Global pos", globalPos)
	print("Local pos", localPos)
	print("Global pos recon", globalPosRecon)
	
	print("Testing Bone 3:")
	local globalPos = cpml.vec3(math.random(), math.random(), math.random())
	local localPos = b3:toLocalPos( globalPos )
	local globalPosRecon = b3:toGlobalPos( localPos )
	print("Global pos", globalPos)
	print("Local pos", localPos)
	print("Global pos recon", globalPosRecon)
end

test()

return Bone
