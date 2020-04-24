local class = require("lib/middleclass/middleclass")
local cpml = require("lib.cpml")
local util = require("util")
local Skeleton = require("Skeleton")

local Bone = class("Bone")

function Bone:initialize( skeleton, parent, basePos, baseRot, length )
	self.skeleton = skeleton
	self.parent = parent or nil
	basePos = basePos or cpml.vec3(0,0,0)
	baseRot = baseRot or cpml.quat(1,0,0,0)
	self:setLocalPos( basePos )
	self:setLocalRot( baseRot )
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
		lp = self.parent:toLocalPos( p )
		self:setLocalPos( lp )
	else
		--lp = self.skeleton:toLocalPos( p )
		self:setLocalPos( p )
	end
end

-- Move a bone while keeping its child fixed (all other children are moved)
function Bone:setPosFixedChild( p, child )
	origChildPos = child:getPos()
	self:setPos( p )
	child:setPos( origChildPos )
end

function Bone:setRotFixedChild( r, child )
	origChildPos = child:getPos()
	origChildRot = child:getRot()
	self:setRot( r, true )
	child:setPos( origChildPos )
	child:setRot( origChildRot, true )
end

--[[function Bone:rotateTo( pos )
	rot = cpml.quat.from_direction( pos - self:getPos(), cpml.vec3(0,0,1) )
	self:setRot( rot )
end

function Bone:rotateToFixedChild( pos )
	
end

]]
function Bone:validatePosWRTChild( child )
	-- Get rotation between my direction and the child direction:
	local dir = self:getDir()
	local childDir = child:getDir()
	local rot = rotBetweenVecs( dir, childDir )
	-- Find component which rotates around the constraint axis (twist)
	swing, twist = swingTwistDecomposition( rot, child.constraint.axis )
	-- TODO: "Undo" any swing rotation here
	tAngle, tAxis = toAngleAxis( twist )
	if cpml.vec3.dist2( tAxis, child.constraint.axis ) > 0.5 then
		tAxis = -tAxis
		tAngle = -tAngle
	end
	if tAngle < child.constraint.minAng then
		--print(tAngle, "min")
		local correctionRot = cpml.quat.from_angle_axis( tAngle-child.constraint.minAng,
				child.constraint.axis ) 
		self:setRotFixedChild( self:getRot()*correctionRot, child )
		-- Move the bone so that it is facing the child:
		--local dir = self:getDir()
		--local dist = cpml.vec3.dist( self:getPos(), child:getPos() )
		--local newPos = child:getPos() - dir*dist
		--self:setPosFixedChild( newPos, child )
	elseif tAngle > child.constraint.maxAng then
		--print(tAngle, "max")
		local correctionRot = cpml.quat.from_angle_axis( tAngle-child.constraint.maxAng,
				child.constraint.axis ) 
		self:setRotFixedChild( self:getRot()*correctionRot, child )
		--self:setPosFixedChild( newPos, child )
	end
	
	-- Move the bone so that it is facing the child:
	local dir = self:getDir()
	local dist = cpml.vec3.dist( self:getPos(), child:getPos() )
	local newPos = child:getPos() - dir*dist
	self:setPosFixedChild( newPos, child )
end

function Bone:validatePosWRTParent( child )
	if not self.parent then
		return
	end
	assert(self.parent.constraint ~= nil, "Parent must have a constraint for validatePosWRTParent to work!")
	-- Get rotation between my direction and the child direction:
	local parent = self.parent
	local dir = cpml.vec3.normalize( self:getPos() - parent:getPos() )
	local parentDir = parent:getBaseDir()
	local rot = rotBetweenVecs( parentDir, dir )
	-- Find component which rotates around the constraint axis (twist)
	swing, twist = swingTwistDecomposition( rot, parent.constraint.axis )
	-- TODO: "Undo" any swing rotation here
	tAngle, tAxis = toAngleAxis( twist )
	if cpml.vec3.dist2( tAxis, parent.constraint.axis ) > 0.5 then
		tAxis = -tAxis
		tAngle = -tAngle
	end
	if tAngle < parent.constraint.minAng then
		-- Project myself into the constraint bounds:
		local minRot = cpml.quat.from_angle_axis( parent.constraint.minAng,
				parent.constraint.axis )
		local minDir = cpml.vec3.normalize( cpml.quat.mul_vec3( minRot, parent:getBaseDir() ) )
		local dist = cpml.vec3.dist( parent:getPos(), self:getPos() )
		local newPos = parent:getPos() + minDir*dist
		if child then
			self:setPosFixedChild( newPos, child )
		else
			self:setPos( newPos )
		end
	elseif tAngle > parent.constraint.maxAng then
		-- Project myself into the constraint bounds:
		local maxRot = cpml.quat.from_angle_axis( parent.constraint.maxAng,
				parent.constraint.axis )
		local maxDir = cpml.vec3.normalize( cpml.quat.mul_vec3( maxRot, parent:getBaseDir() ) )
		local dist = cpml.vec3.dist( parent:getPos(), self:getPos() )
		local newPos = parent:getPos() + maxDir*dist
		if child then
			self:setPosFixedChild( newPos, child )
		else
			self:setPos( newPos )
		end
	end
end


function Bone:setLocalRot( r, ignoreConstraint )
	local ang, axis = toAngleAxis( r )
	local l = cpml.vec3.len( axis )
	assert( l > 0.0001, "Rotation axis invalid" )
	if not ignoreConstraint and self.constraint ~= nil then
		origAngle, origAxis = toAngleAxis( r )
		-- Find component which rotates around the self constraint axis (twist)
		swing, twist = swingTwistDecomposition( r, self.constraint.axis )
		-- This is the new rotation:	
		r = twist
		-- Clamp this new rotation:
		tAngle, tAxis = toAngleAxis( twist, self.constraint.axis )
		-- Ensure that the rotation axis was not flipped:
		if cpml.vec3.dist2( tAxis, self.constraint.axis ) > 0.5 then
			tAxis = -tAxis
			tAngle = -tAngle
		end
		tAngle = angleRange( tAngle )
		tAngleC = math.min(math.max(tAngle,self.constraint.minAng),self.constraint.maxAng)
		r = cpml.quat.from_angle_axis( tAngleC, tAxis )
	end
	--print(toAngleAxis(r))
	local l = cpml.quat.len(r)
	assert( l > 0.999 and l < 1.0001, "Computed rotation not 1!")
	self.lRot = r
end

function Bone:setLocalRotFixedChild( r, child )
	origChildPos = child:getPos()
	origChildRot = child:getRot()
	self:setLocalRot( r )
	--self.lRot = r 
	child:setPos( origChildPos )
	child:setRot( origChildRot, true )
end

function Bone:getPos()
	if self.parent then
		pPos = self.parent:getPos()
		pRot = self.parent:getRot()
		--r = self.lRot*pRot
		self.pos = pPos + cpml.quat.mul_vec3( pRot, self.lPos )
	else
		--self.pos = self.skeleton:toGlobalPos( self.lPos )
		--self.pos = self.skeleton.pos + self.lPos
		self.pos = self.lPos
	end
	return self.pos
end
function Bone:getEndPos()
	return self:toGlobalPos( cpml.vec3( self.len,0,0 ) )
end
function Bone:getRot()
	if self.parent then
		local pRot = self.parent:getRot()
		self.rot = self.lRot*pRot
	else
		--local sRot = self.skeleton.rot
		--self.rot = self.lRot*sRot
		self.rot = self.lRot
	end
	return self.rot
end
function Bone:setRot( r, ignoreConstraint )
	if self.parent then
		local pRot = self.parent:getRot()
		local lRot = r*cpml.quat.inverse( pRot )
		self:setLocalRot( lRot, ignoreConstraint )
	else
		--local sRot = self.skeleton.rot
		--local lRot = r*cpml.quat.inverse( sRot )
		--self:setLocalRot( lRot, ignoreConstraint )
		self:setLocalRot( r )
	end
end
function Bone:toGlobalPos( pos )
	p = self:getPos()
	r = self:getRot()
	rotated = cpml.quat.mul_vec3( r, pos )
	return p + rotated
end
function Bone:toLocalPos( pos )
	local p = self:getPos()
	local r = self:getRot()
	local diff = pos - p
	local rInv = cpml.quat.inverse( r )
	local lPos = cpml.quat.mul_vec3( rInv, diff )
	return lPos
end

function Bone:projectToConstraintPlane( pos )
	-- TODO: self.constraint.axis must be rotated by parent rotation!
	assert( self.constraint ~= nil, "Cannot project pos to constraint plane, bone has no constraint!")
	local diff = pos - self:getPos()
	local dist = cpml.vec3.dot( diff, self.constraint.axis )
	local projection = pos - self.constraint.axis*dist
	return projection
end

-- Get vec pointing in the direction I'm currently facing
function Bone:getDir()
	local rot = self:getRot()
	return cpml.quat.mul_vec3( rot, cpml.vec3(1,0,0) )
end
-- Get vec pointing in the direction I would be facing if I had no (local) rotation.
function Bone:getBaseDir()
	if self.parent then
		local rot = self.parent:getRot()
		return cpml.quat.mul_vec3( rot, cpml.vec3(1,0,0) )
	else
		return cpml.vec3(1,0,0)
	end
end

function Bone:getParentDir()
	if self.parent then
		local rot = self.parent:getRot()
		return cpml.quat.mul_vec3( rot, cpml.vec3(1,0,0) )
	else
		return cpml.vec3(1,0,0)
	end
end
function Bone:clone()
	local bNew = Bone:new( nil, self.parent, self.lPos, self.lRot, self.len )
	if self.constraint then
		bNew.constraint = deepcopy( self.constraint )
	end
	return bNew
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

function Bone:getDebugData( drawConstraints )
	local data = {}

	local pS = self:getPos()
	local pE = self:getEndPos()
	local len = cpml.vec3.len( pS - pE )
	--r = b:getRot()
	--tmp = cpml.vec3( 1,0,0 )
	local w = 0.03
	local pO0 = self:toGlobalPos( cpml.vec3( len*0.05, w, 0 ) )
	local pO1 = self:toGlobalPos( cpml.vec3( len*0.05, -w, 0 ) )

	-- Insert a quad:
	local d = { col={0.25,0.25,0.5,0.6},
		drawType="poly",
		points = {pS.x,pS.y,pO0.x,pO0.y,pE.x,pE.y,pO1.x,pO1.y},
	}
	table.insert( data, d )

	-- Insert a line:
	local d = { col={0.9,0.9,0.9, 0.3},
		drawType="line",
		points = {pS.x,pS.y,pE.x,pE.y},
	}
	table.insert( data, d )

	-- Draw constraint, if any:
	if drawConstraints and self.constraint then
		local minRot = cpml.quat.from_angle_axis( self.constraint.minAng,
				self.constraint.axis )
		local maxRot = cpml.quat.from_angle_axis( self.constraint.maxAng,
				self.constraint.axis )

		-- My end pos in local coordinates...
		local lEndPos = cpml.vec3( 0.5*self.len,0,0 )
		-- ... rotated by the constraints:
		local d = { col={0.9,0.2,0.2,0.4},
			drawType="poly",
			points = {pS.x, pS.y}
		}

		if self.parent then
			for i=0,10 do
				local curRot = cpml.quat.slerp( minRot, maxRot, i/10 )
				local lCurPos = cpml.quat.mul_vec3( curRot, lEndPos )
				local curPos = self.parent:toGlobalPos( self.lPos + lCurPos )
				table.insert( d.points, curPos.x )
				table.insert( d.points, curPos.y )
			end
			table.insert( data, d )
		else

		end
		
	end
	-- If I am connected to a parent, draw a transparent line connecting me to it:
	--[[if self.parent then
		parentS = self.parent:getPos()
		myS = self:getPos()
		-- Insert a line:
		local d = { col={0.9,0.9,0.9, 0.3},
			drawType="line",
			points = {parentS.x,parentS.y,myS.x,myS.y},
		}
		table.insert( data, d )
	end]]

	return data
end

function test()
	print("Testing Bone functions")
	local skel = Skeleton:new()
	math.randomseed(123)
	local pos = cpml.vec3(math.random(), math.random(), math.random())
	local rot = cpml.quat.from_angle_axis( math.random(), cpml.vec3(0,0,1) )
	local b1 = Bone:new( skel, nil, pos, rot, math.random() )

	local pos = cpml.vec3(math.random(), math.random(), math.random())
	local rot = cpml.quat.from_angle_axis( math.random(), cpml.vec3(0,0,1) )
	local b2 = Bone:new( skel, b1, pos, rot, math.random() )

	local pos = cpml.vec3(math.random(), math.random(), math.random())
	local rot = cpml.quat.from_angle_axis( math.random(), cpml.vec3(0,0,1) )
	local b3 = Bone:new( skel, b2, pos, rot, math.random() )

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

	print("Setting:", globalPos)
	b1:setPos( globalPos )
	setPos = b1:getPos()
	print("Set to:", setPos )
	print("End test")

	print("ANGLE AXIS")
	print( toAngleAxis( cpml.quat() ) )
end

test()

return Bone
