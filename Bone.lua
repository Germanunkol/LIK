local class = require("lib/middleclass/middleclass")
local cpml = require("lib.cpml")
local util = require("util")
local Skeleton = require("Skeleton")

local Bone = class("Bone")

local eps = 1e-10

-- TODO: getDebugData drawing constraints from -math.pi*0.9 to math.pi*0.9 fails

function Bone:initialize( skeleton, parent, lPos, lRot, length )
	self.skeleton = skeleton
	self.parent = parent or nil
	self.lPos = lPos or cpml.vec3()
	self.lRot = lRot or cpml.quat()
	self.len = length or 0
	if self.skeleton then
		self.skeleton:addBone( self )
	end
end

function Bone:setLocalPos( p )
	self.lPos = p
end
function Bone:setLocalPosFixedChild( p, child )
	local origChildPos = child:getPos()
	self.lPos = p
	child:setPos( origChildPos )
end
function Bone:setLocalRot( r )
	r = r:normalize()
	self.lRot = r
end

function Bone:setPos( p )
	if self.parent then
		local lp = self.parent:toLocalPos( p )
		self:setLocalPos( lp )
	else
		self:setLocalPos( p )
	end
end

-- Move a bone while keeping its child fixed (all other children are moved)
function Bone:setPosFixedChild( p, child )
	local origChildPos = child:getPos()
	self:setPos( p )
	child:setPos( origChildPos )
end

function Bone:setRotFixedChild( r, child, ignoreConstraint )
	local origChildPos = child:getPos()
	local origChildRot = child:getRot()
	self:setRot( r, ignoreConstraint )
	child:setPos( origChildPos )
	child:setRot( origChildRot, true )
end

function Bone:setLocalRotFixedChild( r, child )
	local origChildPos = child:getPos()
	local origChildRot = child:getRot()
	self:setLocalRot( r )
	child:setPos( origChildPos )
	child:setRot( origChildRot, true )
end

function Bone:getPos()
	local pos
	if self.parent then
		local pPos = self.parent:getPos()
		local pRot = self.parent:getRot()
		pos = pPos + cpml.quat.mul_vec3( pRot, self.lPos )
	else
		pos = self.lPos
	end
	return pos
end
function Bone:getEndPos()
	return self:toGlobalPos( cpml.vec3( self.len,0,0 ) )
end
function Bone:getRot()
	local rot
	if self.parent then
		local pRot = self.parent:getRot()
		rot = self.lRot*pRot
	else
		rot = self.lRot
	end
	return rot
end

function Bone:rotateAroundPoint( point, rot )
	self:setPos( self:getPos() - point )
	local p = self:getPos()
	local pRot = rot:mul_vec3( p )
	self:setPos( pRot + point )
	self:setRot( self:getRot()*rot )
end

function Bone:setRot( r, ignoreConstraint )
	if self.parent then
		local pRot = self.parent:getRot()
		local lRot = r*cpml.quat.inverse( pRot )
		self:setLocalRot( lRot, ignoreConstraint )
	else
		self:setLocalRot( r, ignoreConstraint )
	end
end
function Bone:toGlobalPos( pos )
	local p = self:getPos()
	local r = self:getRot()
	local rotated = cpml.quat.mul_vec3( r, pos )
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
function Bone:toLocalRot( rot )
	local r = self:getRot()
	local rInv = cpml.quat.inverse( r )
	return rInv*rot
end
function Bone:toGlobalRot( rot )
	local r = self:getRot()
	return rot*r
end
-- Get vec pointing in the direction I'm currently facing
function Bone:getDir()
	local rot = self:getRot()
	return cpml.quat.mul_vec3( rot, cpml.vec3(1,0,0) )
end
function Bone:clone()
	local bNew = Bone:new( nil, self.parent, self.lPos, self.lRot, self.len )
	if self.constraint then
		bNew.constraint = deepcopy( self.constraint )
	end
	return bNew
end

function Bone:correctRot( fixedChild )
	if self.constraint then
		-- Get component of local rotation around my constraint axis (twist).
		-- Ignore the rest (swing).
		local oAng, oAx = self.lRot:to_angle_axis()
		local tAng, tAx = getTwist( self.lRot, self.constraint.axis )
		local newRot
		if tAng < self.constraint.minAng - eps then
			--self:setLocalRot( self.constraint.minRot )
			newRot = self.constraint.minRot
		elseif tAng > self.constraint.maxAng + eps then
			--self:setLocalRot( self.constraint.maxRot )
			newRot = self.constraint.maxRot
		else
			--self:setLocalRot( cpml.quat.from_angle_axis( tAng, self.constraint.axis ) )
			newRot = cpml.quat.from_angle_axis( tAng, self.constraint.axis )
		end
		if fixedChild then
			self:setLocalRotFixedChild( newRot, fixedChild )
		else
			self:setLocalRot( newRot )
		end
	end
end

function Bone:correctPos( fixedChild )
	-- If I don't have a parent, any position is valid.
	if self.parent then
		if self.parent.constraint then
			local lPosUnrot = self.parent.lRot * self.lPos
			-- First, project my position to the plane of my parent's constraint:
			local proj = projToPlane( lPosUnrot, self.parent.constraint.axis,
				cpml.vec3() )
			-- Ensure the projection doesn't lie directly on the parent's pos:
			if proj:len2() < 1e-10 then
				proj = cpml.vec3(1,0,0)
			end
			-- Then, find out the angle between the vec connecting the bones and the
			-- parent's base vec:
			local ang = angBetweenVecs( cpml.vec3(1,0,0),proj,self.parent.constraint.axis )
			local newPos
			local newParentRot
			if ang < self.parent.constraint.minAng then
				newPos = self.parent.constraint.minDir * self.parent.len
				-- Correct parent to look at me:
				newParentRot = self.parent.constraint.minRot
				--return self.parent:toGlobalPos( newPosRot )
			elseif ang > self.parent.constraint.maxAng then
				newPos = self.parent.constraint.maxDir * self.parent.len
				-- Correct parent to look at me:
				newParentRot = self.parent.constraint.maxRot
			else
				-- Correct parent to look at me:
				newParentRot = cpml.quat.from_angle_axis( ang,
					self.parent.constraint.axis )
				-- Ensure the bone is the correct length from the parent:
				newPos = proj:normalize() * self.parent.len
			end

			-- Correct parent to look at me:
			self.parent:setLocalRotFixedChild( newParentRot, self )
			-- Rotate new position into parent space:
			local newPosRot = self.parent.lRot:inverse() * newPos
			if fixedChild then
				self:setLocalPosFixedChild( newPosRot, fixedChild )
			else
				self:setLocalPos( newPosRot )
			end
		end
	end
	--return self.lPos
end

function Bone:setConstraint( axis, minAng, maxAng )
	assert( minAng <= maxAng,
		"Can't set constraint: Minimum angle must be smaller than maximum angle")
	assert( minAng >= -math.pi,
		"Can't set constraint: Minimum angle must be greater than -pi")
	assert( maxAng <= math.pi,
		"Can't set constraint: Maximum angle must be smaller than pi")
	local minRot = cpml.quat.from_angle_axis( minAng, axis )
	local minDir = cpml.vec3.normalize( minRot * cpml.vec3(1,0,0) )
	local maxRot = cpml.quat.from_angle_axis( maxAng, axis )
	local maxDir = cpml.vec3.normalize( maxRot * cpml.vec3(1,0,0) )
	
	self.constraint = {
		axis=cpml.vec3.normalize(axis),
		minAng=minAng,
		maxAng=maxAng,
		minRot=minRot,
		maxRot=maxRot,
		minDir=minDir,
		maxDir=maxDir,
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
		local minAng = self.constraint.minAng
		local maxAng = self.constraint.maxAng

		-- My end pos in local coordinates...
		local lEndPos = cpml.vec3( 0.5*self.len,0,0 )
		local d = { col={0.9,0.2,0.2,0.4},
			drawType="poly",
			points = {pS.x, pS.y}
		}

		if self.parent then
			for i=0,10 do
				local ang = (maxAng-minAng)*(i/10) + minAng
				local curRot = cpml.quat.from_angle_axis( ang, self.constraint.axis )
				local lCurPos = cpml.quat.mul_vec3( curRot, lEndPos )
				local curPos = self.parent:toGlobalPos( self.lPos + lCurPos )
				table.insert( d.points, curPos.x )
				table.insert( d.points, curPos.y )
			end
			table.insert( data, d )
		else
			for i=0,10 do
				local ang = (maxAng-minAng)*(i/10) + minAng
				local curRot = cpml.quat.from_angle_axis( ang, self.constraint.axis )
				local lCurPos = cpml.quat.mul_vec3( curRot, lEndPos )
				local curPos = self.lPos + lCurPos
				table.insert( d.points, curPos.x )
				table.insert( d.points, curPos.y )
			end
			table.insert( data, d )
		end
		
	end

	if self.tLPos then
		local e = self.parent:toGlobalPos( self.tLPos )
		local d = { col={0.9,0,0,0.7},
			drawType="line",
			points = {pS.x, pS.y, e.x, e.y}
		}
		table.insert( data, d )
	end
	if self.pLPos then
		local pS = self.parent:getPos()
		local e = self.parent:getPos() + self.pLPos
		local d = { col={0,0.9,0,0.7},
			drawType="line",
			points = {pS.x, pS.y, e.x, e.y}
		}
		table.insert( data, d )
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

-- Check if the bone currently abides by its constraints:
function Bone:validifyConstraint()
	if self.constraint then
		local eps = math.pi*0.001

		local ang, axis = cpml.quat.to_angle_axis( self.lRot )
		ang = angleRange(ang)
		if cpml.vec3.dist2( axis, self.constraint.axis ) > 0.5 then
			axis = -axis
			ang = -ang
		end
		if ang < self.constraint.minAng - eps then
			return false, tostring(ang) .. " < " .. self.constraint.minAng .. "!"
		elseif ang > self.constraint.maxAng + eps then
			return false, tostring(ang) .. " > " .. self.constraint.maxAng .. "!"
		end
		--end
	end
	return true
end

-- Check if the bone is correctly connected to its parent:
function Bone:validifyPos()
	if self.parent then
		local l = cpml.vec3.dist2( self:getPos(), self.parent:getEndPos() )
		if l < eps then
			return true
		else
			return false, "Bone too far from parent's end position!"
		end
	end
	return true
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
end

test()

return Bone
