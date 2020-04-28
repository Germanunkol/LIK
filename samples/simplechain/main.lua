package.path = "../../?.lua;" .. package.path
package.path = "../../?/init.lua;" .. package.path

local Skeleton = require("Skeleton")
local Bone = require("Bone")
local Fabrik = require("Fabrik")

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")

function createShortChain()
	local vZero = cpml.vec3(0,0,0)
	local skel = Skeleton:new()

	local noRot = cpml.quat(0,0,0,1)

	local b1_0 = Bone:new( skel, nil, vZero, noRot, 0.1 )
	local b1_1 = Bone:new( skel, b1_0, cpml.vec3(0.1,0,0), noRot, 0.2 )
	local b1_2 = Bone:new( skel, b1_1, cpml.vec3(0.2,0,0), noRot, 0.3 )
	--local b1_3 = Bone:new( skel, b1_2, cpml.vec3(0.2,0,0), cpml.quat(), 0.07 )
	--local b1_4 = Bone:new( skel, b1_3, cpml.vec3(0.07,0,0), cpml.quat(), 0.03 )

	spine = { b1_0, b1_1, b1_2 }

	b1_0:setConstraint( cpml.vec3(0,0,1), -math.pi*0.5, math.pi*0.5 )
	b1_1:setConstraint( cpml.vec3(0,0,1), -math.pi*0.5, math.pi*0.5 )
	b1_2:setConstraint( cpml.vec3(0,0,1), -math.pi*0.25, math.pi*0.25 )
	--b1_3:setConstraint( cpml.vec3(0,0,1), -math.pi*0.5, 0 )
	--b1_4:setConstraint( cpml.vec3(0,0,1), -math.pi*0.5, 0 )
	--b1_1:setConstraint( cpml.vec3(0,0,1), -math.pi, -math.pi )

	return skel, spine
end

function love.load()

	skel, spine = createShortChain()

	targetDir = cpml.vec3(1,0,0)

	cursorX, cursorY = -0.4,0

	love.keyboard.setKeyRepeat( true )
end

function love.update( dt )
	t = love.timer.getTime()

	speed = 0.5
	baseX = 0
	stepSize = 0.3

	basePos = cpml.vec3( baseX, 0, 0 )

	--cursorX = math.sin( t )*0.5
	--cursorY = math.cos( 1.6*t + 0.7 )*0.5
	--targetDir = cpml.quat.from_angle_axis( t*0.5, cpml.vec3(0,0,1) ):mul_vec3( cpml.vec3(1,0,0) )

	targetPos = basePos + cpml.vec3( cursorX, cursorY, 0 )

	targetPosLocal = skel:toLocalPos( targetPos )
	targetDirLocal = skel:toLocalDir( targetDir )

	--floorPos = cpml.vec3( 0, 0.4, 0 )
	--floorPos = floorPos + cpml.vec3( 0, 0.1*math.cos(t*0.1), 0 )
	skel.pos = cpml.vec3( baseX, 0, 0 )

	--Fabrik.solve( spine, targetPosLocal, targetDirLocal, 1 )
	
end

function drawGrid( baseX )
	love.graphics.setColor( 1,1,1,0.1 )
	baseXrounded = math.floor( baseX )
	for dx=-2,3,0.1 do
		x = baseXrounded + dx
		love.graphics.line( x, -1, x, 1 )
	end
	for y=-1,1,0.1 do
		love.graphics.line( baseXrounded -2, y, baseXrounded + 3, y )
	end
	love.graphics.setColor( 1,1,1,0.3 )
	love.graphics.line( -1, 0, 1, 0 )
end

function drawSkel( skel, alpha )
	data = skel:getDebugData( true )
	alpha = alpha or 1

	love.graphics.push()
	love.graphics.translate( skel.pos.x, skel.pos.y )
	local ang,axis = toAngleAxis( skel.rot )
	if axis.z < 0 then
		axis = -axis
		ang = -ang
	end
	--print(skel.pos.x, skel.pos.y)
	love.graphics.rotate( ang )
	--love.graphics.scale( scale )
	love.graphics.setLineWidth( 1/200 )
	for i,d in ipairs(data) do
		love.graphics.setColor( d.col[1], d.col[2], d.col[3], d.col[4]*alpha )
		if d.drawType == "line" then
			love.graphics.line( d.points )
		elseif d.drawType == "poly" then
			love.graphics.polygon( "fill", d.points )
		end
	end
	love.graphics.pop()

end


function love.draw()
	--[[drawSkel( skel1, -250, 0, 200 )
	drawSkel( skel2, -50, 0, 200 )
	drawSkel( skel3, 150, 0, 200 )]]
	love.graphics.push()
	love.graphics.translate( love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.5 )
	love.graphics.scale( 300 )

	love.graphics.translate( -baseX, 0 )
	drawGrid( baseX )

	--drawSkel( skel, 0, 0 )
	love.graphics.setColor( 0.4,0.5,1,1 )
	if targetPos then
		love.graphics.circle( "fill", targetPos.x, targetPos.y, 0.02 )
		local endPoint = targetPos + targetDir*0.05
		love.graphics.line( targetPos.x, targetPos.y, endPoint.x, endPoint.y )
	end
	if prevTargetPos then
		love.graphics.setColor( 0.4,1,0.5,1 )
		love.graphics.circle( "fill", prevTargetPos.x + baseX, prevTargetPos.y, 0.02 )
		local endPoint = prevTargetPos + prevTargetDir*0.05
		love.graphics.line( prevTargetPos.x + baseX, prevTargetPos.y, endPoint.x + baseX, endPoint.y )
	end
	
	drawSkel( skel, 1 )

	love.graphics.pop()

	love.graphics.setColor(1,1,1,1)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function getFloorHeight( x, y )
	local noise = love.math.noise( x, y )
	h = 0.25 + noise*0.1
	return h
end

function getFootPlacement( baseX, ang, y )
	raise = 0.1
	len = 0.3

	x = len*math.cos( ang )
	floorPos = getFloorPos( baseX + x, y )

	targetPos = floorPos + cpml.vec3( x, math.min(raise*math.sin( ang ),0), 0 )
	return targetPos
end

function love.keypressed( key, code, isrepeat )
	if key == "right" then
		cursorX = cursorX + 0.01
	elseif key == "up" then
		cursorY = cursorY - 0.01
	elseif key == "left" then
		cursorX = cursorX - 0.01
	elseif key == "down" then
		cursorY = cursorY + 0.01
	end
	if love.keyboard.isDown( "space") then

		targetPosLocal = skel:toLocalPos( targetPos )
		targetDirLocal = skel:toLocalDir( targetDir )

		skel.pos = cpml.vec3( baseX, 0, 0 )

		Fabrik.solve( spine, targetPosLocal, targetDirLocal, 1 )
		--Fabrik.solve( spine, targetPosLocal, nil, 20 )
		prevTargetPos = targetPos
		prevTargetDir = targetDir
		prevTargetPos.x = prevTargetPos.x - baseX

		--[[for i,b in ipairs(spine) do
			b:correctPos()
			b:correctRot()
		end]]

		if Fabrik.validateChain( spine ) ~= true then
			love.graphics.captureScreenshot( "debug.png" )
			--love.event.quit()
		end
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


