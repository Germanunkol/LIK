package.path = "../?.lua;" .. package.path
package.path = "../?/init.lua;" .. package.path

local Skeleton = require("Skeleton")
local Bone = require("Bone")
local Fabrik = require("Fabrik")

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")

function createShortChain()
	local vZero = cpml.vec3(0,0,0)
	local skel = Skeleton:new()

	local b1_0 = Bone:new( skel, nil, vZero, cpml.quat(), 0.1 )
	local b1_1 = Bone:new( skel, b1_0, cpml.vec3(0.1,0,0), cpml.quat(), 0.2 )
	local b1_2 = Bone:new( skel, b1_1, cpml.vec3(0.2,0,0), cpml.quat(), 0.2 )
	local b1_3 = Bone:new( skel, b1_2, cpml.vec3(0.2,0,0), cpml.quat(), 0.07 )
	local b1_4 = Bone:new( skel, b1_3, cpml.vec3(0.07,0,0), cpml.quat(), 0.03 )

	spine = { b1_0, b1_1, b1_2, b1_3, b1_4 }

	--b1_1:setConstraint( cpml.vec3(0,0,1), -math.pi*0.5, math.pi*0.5 )
	b1_0:setConstraint( cpml.vec3(0,0,1), -math.pi, -math.pi )
	b1_1:setConstraint( cpml.vec3(0,0,1), -math.pi*0.9, math.pi*0.1 )
	b1_2:setConstraint( cpml.vec3(0,0,1), -math.pi, -math.pi*0.1 )
	b1_3:setConstraint( cpml.vec3(0,0,1), -math.pi*0.5, 0 )
	b1_4:setConstraint( cpml.vec3(0,0,1), -math.pi*0.5, 0 )
	return skel, spine
end

function createLongChain()
	local vZero = cpml.vec3(0,0,0)
	local skel = Skeleton:new()
	spine = {}

	local segLen = 0.05
	local b = Bone:new( skel, nil, vZero, cpml.quat(), segLen )
	b:setConstraint( cpml.vec3(0,0,1), 0.5*math.pi, 0.5*math.pi )
	table.insert(spine, b)

	for i=1,15 do
		b = Bone:new( skel, b, cpml.vec3(segLen,0,0), cpml.quat(), segLen )
		--if i < 10 then
			b:setConstraint( cpml.vec3(0,0,1), -math.pi*0.3, math.pi*0.3 )
		--end
		table.insert(spine, b)
	end

	return skel, spine
end


function love.load()

	--skel1, spine1 = createLongChain()
	skel1, spine1 = createShortChain()

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
	
	targetDir = cpml.vec3(0,1,0)
	prevTargetPos = cpml.vec3()
end

function drawSkel( skel )
	data = skel:getDebugData()

	love.graphics.push()
	love.graphics.translate( skel.pos.x, skel.pos.y )
	local ang,axis = cpml.quat.to_angle_axis( skel.rot )
	if axis.z < 0 then
		axis = -axis
		ang = -ang
	end
	--print(skel.pos.x, skel.pos.y)
	love.graphics.rotate( ang )
	--love.graphics.scale( scale )
	love.graphics.setLineWidth( 1/200 )
	for i,d in ipairs(data) do
		love.graphics.setColor( d.col )
		if d.drawType == "line" then
			p = d.points
			love.graphics.line( p[1].x, p[1].y, p[2].x, p[2].y )
		elseif d.drawType == "quad" then
			p = d.points
			love.graphics.polygon( "fill",
				p[1].x, p[1].y,
				p[2].x, p[2].y,
				p[3].x, p[3].y,
				p[4].x, p[4].y )

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
	love.graphics.push()
	love.graphics.translate( love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.5 )
	love.graphics.scale( 300 )

	drawGrid()

	--drawSkel( skel, 0, 0 )
	drawSkel( skel1 )
	love.graphics.setColor( 0.4,0.5,1,1 )
	--love.graphics.circle( "fill", targetPos.x, targetPos.y, 0.02 )
	local endPoint = targetPos + targetDir*0.05
	--love.graphics.line( targetPos.x, targetPos.y, endPoint.x, endPoint.y )
	love.graphics.setColor( 0.3,1,0.3,1 )
	--love.graphics.circle( "fill", prevTargetPos.x, prevTargetPos.y, 0.02 )
	
	-- Draw the floor:
	love.graphics.setColor( 0.8, 0.8, 1, 0.5 )
	floor = {}
	for x=-1,1,0.05 do
		pos = getFloorPos( t, x )
		table.insert( floor, x )
		table.insert( floor, pos.y )
	end
	love.graphics.line( floor )
	love.graphics.pop()

	love.graphics.setColor(1,1,1,1)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function getFloorPos( t, x )
	local p = cpml.vec3( 0, 0.35, 0 )
	p = p + cpml.vec3( 0, 0.05*math.cos(t*0.3+x*0.3), 0 )
	return p
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

	--floorPos = cpml.vec3( 0, 0.4, 0 )
	--floorPos = floorPos + cpml.vec3( 0, 0.1*math.cos(t*0.1), 0 )

	--targetPos = cpml.vec3( 0.5, -0.5, 0 )
	cycleLen = 4
	cycle = t - math.floor( t/cycleLen )
	cycleNorm = t/cycleLen
	ang = math.pi*2*cycleNorm

	raise = 0.1
	len = 0.2

	x = len*math.cos( ang )
	floorPos = getFloorPos( t, x )

	targetPos = floorPos + cpml.vec3( x, math.min(raise*math.sin( ang ),0), 0 )
	
	footAng = pos

	--targetPos = cpml.vec3( math.cos(t)*0.5, math.cos(t*1.3+1)*0.35, 0 )

	targetDir = cpml.vec3( 1,0,0 )
	--targetDir = cpml.vec3( 0, -1, 0 )
	--spine[1]:setPos( cpml.vec3( 0, 0.2, 0 ) )
	--spine[4]:setPos( targetPos )
	
	--moveCreature()
	skel1.pos = cpml.vec3( math.sin(-ang)*raise*2, math.cos(-ang)*raise*0.5, 0 )
	--skel1.rot = cpml.quat.from_angle_axis( ang, cpml.vec3( 0,0,1 ) )
	--print( skel1:toGlobalPos( cpml.vec3( 1, 0, 0 ) ) )
	--print(skel1.pos)
	targetPosLocal = skel1:toLocalPos( targetPos )
	targetDirLocal = skel1:toLocalDir( targetDir )
	--targetPosLocal = cpml.vec3(-0.230,0.239,0.000)
	--Fabrik.solve( spine1, targetPosLocal, targetDirLocal, 5 )
	print(targetPosLocal, targetDirLocal )
	Fabrik.solve( spine1, targetPosLocal, targetDirLocal, 20 )
	if Fabrik.validateChain( spine1 ) ~= true then
		love.graphics.captureScreenshot( "debug.png" )
		love.event.quit()
	end
	--Fabrik.solve( spine1, targetPos, targetDir, 3 )
end

function love.keypressed( key )
	if key == "space" then
		Fabrik.solve( spine1, targetPos, targetDir, 2 )
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


