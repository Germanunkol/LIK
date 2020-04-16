package.path = "../?.lua;" .. package.path
package.path = "../?/init.lua;" .. package.path

local Skeleton = require("Skeleton")
local Bone = require("Bone")
local Fabrik = require("Fabrik")

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")

function love.load()
	vZero = cpml.vec3(0,0,0)

	skel1 = Skeleton:new()

	b1_1 = Bone:new( skel1, nil, vZero, cpml.quat(), 0.3 )
	b1_2 = Bone:new( skel1, b1_1, cpml.vec3(0.3,0,0), cpml.quat(), 0.2 )
	b1_3 = Bone:new( skel1, b1_2, cpml.vec3(0.2,0,0), cpml.quat(), 0.1 )
	spine1 = { b1_1, b1_2, b1_3 }

	--[[

	skel2 = Skeleton:new()

	b2_1 = Bone:new( skel2, nil, vZero, cpml.quat(), 0.2 )
	b2_2 = Bone:new( skel2, b2_1, vZero, cpml.quat(), 0.2 )
	b2_3 = Bone:new( skel2, b2_2, vZero, cpml.quat(), 0.2 )

	b2_1:setConstraint( cpml.vec3(0,0,1), -math.pi*0.5, math.pi*0.1 )
	b2_2:setConstraint( cpml.vec3(0,0,1), math.pi*0.5, math.pi*0.5 )
	b2_3:setConstraint( cpml.vec3(0,0,1), -math.pi*0.2, math.pi*0.2 )

	b1_2:setPos( cpml.vec3(0,0.2,0) )
	b2_2:setPos( cpml.vec3(0,0.2,0) )

	skel3 = Skeleton:new()

	b3_1 = Bone:new( skel3, nil, vZero, cpml.quat(), 0.2 )
	b3_2 = Bone:new( skel3, b3_1, vZero, cpml.quat(), 0.2 )
	b3_3 = Bone:new( skel3, b3_2, vZero, cpml.quat(), 0.2 )
	b3_4 = Bone:new( skel3, b3_1, vZero, cpml.quat(), 0.2 )
	b3_5 = Bone:new( skel3, b3_4, vZero, cpml.quat(), 0.2 )

	--b3_1:setConstraint( cpml.vec3(0,0,1), -math.pi*0.1, math.pi*0.1 )
	b3_2:setConstraint( cpml.vec3(0,0,1), 0, math.pi*0.3 )
	b3_3:setConstraint( cpml.vec3(0,0,1), -math.pi*0.2, math.pi*0.2 )
	b3_4:setConstraint( cpml.vec3(0,0,1), -math.pi*0.3, 0 )
	b3_5:setConstraint( cpml.vec3(0,0,1), -math.pi*0.2, math.pi*0.2 )

	b3_2:setPos( cpml.vec3(0,0.2,0) )
	b3_4:setPos( cpml.vec3(0,-0.2,0) )]]



	--b2:setConstraint( cpml.vec3(0,1,1), -math.pi*0.01, math.pi*0.1 )
	--setupCreature()
	

	prevTargetPos = cpml.vec3()
end

function drawSkel( skel, x, y )
	data = skel:getDebugData()

	love.graphics.push()
	love.graphics.translate( x, y )
	--love.graphics.scale( scale )
	love.graphics.setLineWidth( 1/200 )
	for i,d in ipairs(data) do
		love.graphics.setColor( d.col )
		if d.drawType == "line" then
			love.graphics.line( d.p0.x, d.p0.y, d.p1.x, d.p1.y )
		elseif d.drawType == "tri" then
			love.graphics.polygon( "fill",
				d.p0.x, d.p0.y,
				d.p1.x, d.p1.y,
				d.p2.x, d.p2.y,
				d.p3.x, d.p3.y )
		end
	end
	love.graphics.pop()
end

function drawGrid()
	love.graphics.setColor( 1,1,1,0.1 )
	for x=-1,1,0.1 do
		love.graphics.line( x, -1, x, 1 )
	end
	for y=-1,1,0.1 do
		love.graphics.line( -1, y, 1, y )
	end
	love.graphics.setColor( 1,1,1,0.3 )
	love.graphics.line( 0, -1, 0, 1 )
	love.graphics.line( -1, 0, 1, 0 )
end

function love.draw()
	--[[drawSkel( skel1, -250, 0, 200 )
	drawSkel( skel2, -50, 0, 200 )
	drawSkel( skel3, 150, 0, 200 )]]
	love.graphics.translate( love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.5 )
	love.graphics.scale( 300 )

	drawGrid()

	--drawSkel( skel, 0, 0 )
	drawSkel( skel1, 0, 0 )
	love.graphics.setColor( 1,0.3,0.3,1 )
	love.graphics.circle( "fill", targetPos.x, targetPos.y, 0.03 )
	love.graphics.setColor( 0.3,1,0.3,1 )
	love.graphics.circle( "fill", prevTargetPos.x, prevTargetPos.y, 0.03 )
end

function love.update( dt )
	t = love.timer.getTime()
	--q1 = cpml.quat.from_angle_axis( t, cpml.vec3(0,0,1) )
	--b1:setLocalRot( q1 )

	--[[ang = math.cos(t)*0.2
	q2 = cpml.quat.from_angle_axis( ang, cpml.vec3(0,0,1) )
	b2:setLocalRot( q2 )

	ang = math.cos(t*2)*0.2
	q2 = cpml.quat.from_angle_axis( ang, cpml.vec3(0,0,1) )
	b3:setLocalRot( q2 )]]
	
	--[[ang = math.sin( t )
	q2 = cpml.quat.from_angle_axis( ang, cpml.vec3(0,0,1) )
	b1_1:setLocalRot( q2 )
	b1_2:setLocalRot( q2 )
	b1_3:setLocalRot( q2 )

	b2_1:setLocalRot( q2 )
	b2_2:setLocalRot( q2 )
	b2_3:setLocalRot( q2 )
	
	b3_1:setLocalRot( q2 )
	b3_2:setLocalRot( q2 )
	b3_3:setLocalRot( q2 )
	b3_4:setLocalRot( q2 )
	b3_5:setLocalRot( q2 )]]

	targetPos = cpml.vec3( math.sin(t*0.25)*1, math.cos(t*0.5+1)*0.75, 0 )
	--spine[1]:setPos( cpml.vec3( 0, 0.2, 0 ) )
	--spine[4]:setPos( targetPos )

	--moveCreature()
	Fabrik.solve( spine1, targetPos, 20 )
end

function love.keypressed( key )
	if key == "space" then
		Fabrik.solve( spine1, targetPos, 20 )
		--prevTargetPos = targetPos
	end
end

function addLegs( p )
	-- Left:
	local bThighL = Bone:new( p.skeleton, p,
			cpml.vec3( p.len*0.5, p.len*0.25, 0 ),
			cpml.quat.from_angle_axis( math.pi*0.5, cpml.vec3(0,0,1) ), p.len*0.75 )
	local bShinL = Bone:new( p.skeleton, bThighL,
			cpml.vec3( bThighL.len,0,0 ),
			cpml.quat.from_angle_axis( math.pi*0.1, cpml.vec3(0,0,1) ), p.len*0.5 )
	-- Right:
	local bThighR = Bone:new( p.skeleton, p,
			cpml.vec3( p.len*0.5, -p.len*0.25, 0 ),
			cpml.quat.from_angle_axis( -math.pi*0.5, cpml.vec3(0,0,1) ), p.len*0.75 )
	local bShinR = Bone:new( p.skeleton, bThighR,
			cpml.vec3( bThighR.len,0,0 ),
			cpml.quat.from_angle_axis( -math.pi*0.1, cpml.vec3(0,0,1) ), p.len*0.5 )
end

function setupCreature()
	skel = Skeleton()
	spine = {}
	pos = cpml.vec3(0.2,0,0)
	rot = cpml.quat()
	for i=1,5 do
		len = 0.25/i + 0.05
		b = Bone:new( skel, spine[i-1], pos, rot, len )
		pos = cpml.vec3( len,0,0 )	-- Position of next bone
		b:setConstraint( cpml.vec3(0,0,1), -math.pi*0.2, math.pi*0.2 )
		table.insert( spine, b )
		if i <= 3 then
			--addLegs( b )
		end
	end
	neck = {}
	rot0 = cpml.quat.from_angle_axis( math.pi, cpml.vec3(0,0,1) )
	pos0 = cpml.vec3( -0.2,0,0 )
	b = Bone:new( skel, spine[1], pos0, rot0, 0.15 )
	b:setConstraint( cpml.vec3(0,0,1), -math.pi, -math.pi)
	table.insert( neck, b )
	for i=2,3 do
		parent = neck[i-1]
		pos = cpml.vec3( 0.2,0,0 )
		b = Bone:new( skel, neck[i-1], pos, rot, 0.15 )
		table.insert( neck, b )
	end
end

function moveCreature()
	local t = love.timer.getTime()

	for i,b in ipairs(spine) do
		ang = math.sin(t)*i/4
		q = cpml.quat.from_angle_axis( ang, cpml.vec3(0,0,1) )
		b:setLocalRot( q )
	end
	for i,b in ipairs(neck) do
		ang = math.sin(t+0.5)*i/3
		q = cpml.quat.from_angle_axis( ang, cpml.vec3(0,0,1) )
		b:setLocalRot( q )
	end
end


