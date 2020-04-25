package.path = "../../?.lua;" .. package.path
package.path = "../../?/init.lua;" .. package.path

local Skeleton = require("Skeleton")
local Bone = require("Bone")
local Fabrik = require("Fabrik")

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")

require("profile")

function createShortChain()
	local vZero = cpml.vec3(0,0,0)
	local skel = Skeleton:new()

	local b1_0 = Bone:new( skel, nil, vZero, cpml.quat(), 0.1 )
	local b1_1 = Bone:new( skel, b1_0, cpml.vec3(0.1,0,0), cpml.quat(), 0.2 )
	local b1_2 = Bone:new( skel, b1_1, cpml.vec3(0.2,0,0), cpml.quat(), 0.2 )
	local b1_3 = Bone:new( skel, b1_2, cpml.vec3(0.2,0,0), cpml.quat(), 0.07 )
	local b1_4 = Bone:new( skel, b1_3, cpml.vec3(0.07,0,0), cpml.quat(), 0.03 )

	spine = { b1_0, b1_1, b1_2, b1_3, b1_4 }

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

	for i=1,10 do
		b = Bone:new( skel, b, cpml.vec3(segLen,0,0), cpml.quat(), segLen )
		--if i < 10 then
			b:setConstraint( cpml.vec3(0,0,1), -math.pi*0.3, math.pi*0.3 )
		--end
		table.insert(spine, b)
	end

	return skel, spine
end


function love.load()
	love.keyboard.setKeyRepeat( true )

	skel1, spine1 = createShortChain()
	skel2, spine2 = createShortChain()

	--setupCreature()
	
	targetDir = cpml.vec3(0,1,0)
	prevTargetPos = cpml.vec3()

	showConstraints = false
	speed = 0.5
	baseX = 0
	stepSize = 0.7
	--footRaise = 0.1
	footRaise = 0.55
end

function love.update( dt )
	if failed then
		return
	end
	t = love.timer.getTime()

	--baseX = baseX + speed*dt
	baseX = baseX + speed*0.005


	curStepPos = math.floor(baseX/stepSize)*stepSize + stepSize*0.5
	stepPercentage = (baseX - math.floor(baseX/stepSize)*stepSize)/stepSize

	targetDir = cpml.vec3( 1,0,0 )
	-- Foot on ground:
	local curRaise = 0
	if stepPercentage < 0.75 then
		targetX = curStepPos
	-- Foot in air:
	else
		factor = (stepPercentage-0.75)/0.25
		stepForward = stepSize*factor
		targetX = curStepPos + stepForward
		curRaise = footRaise*math.sin( factor*math.pi )
	end
	leftFloorHeight = getFloorHeight( targetX, 0 )
	targetY = leftFloorHeight - curRaise
	targetPos = cpml.vec3( targetX, targetY, 0 )

	--floorPos = cpml.vec3( 0, 0.4, 0 )
	--floorPos = floorPos + cpml.vec3( 0, 0.1*math.cos(t*0.1), 0 )
	leftFootTargetPos = targetPos
	leftFootTargetDir = targetDir

	curStepPos = math.floor((baseX+stepSize*0.5)/stepSize)*stepSize
	stepPercentage = (baseX - math.floor(baseX/stepSize)*stepSize)/stepSize

	stepPercentage = stepPercentage + 0.5
	if stepPercentage > 1 then
		stepPercentage = stepPercentage - 1
	end

	targetDir = cpml.vec3( 1,0,0 )
	-- Foot on ground:
	local curRaise = 0
	if stepPercentage < 0.75 then
		targetX = curStepPos
	-- Foot in air:
	else
		factor = (stepPercentage-0.75)/0.25
		stepForward = stepSize*factor
		targetX = curStepPos + stepForward
		curRaise = footRaise*math.sin( factor*math.pi )
	end
	rightFloorHeight = getFloorHeight( targetX, -0.2 )
	targetY = rightFloorHeight - curRaise
	targetPos = cpml.vec3( targetX, targetY, 0 )
	rightFootTargetPos = targetPos
	rightFootTargetDir = targetDir

	baseHeight = -0.35

	curHeight = (leftFloorHeight + rightFloorHeight)/2
	leftHeight = (curHeight + leftFloorHeight)/2 + baseHeight
	rightHeight = (curHeight + rightFloorHeight)/2 + baseHeight

	skel1.pos = cpml.vec3( baseX + 0.2, leftHeight, 0 )
	targetPosLocal = skel1:toLocalPos( leftFootTargetPos )
	targetDirLocal = skel1:toLocalDir( leftFootTargetDir )

	if not Fabrik.solve( spine1, targetPosLocal, targetDirLocal, 1 ) then
		failed = true
		return
	end

	skel2.pos = cpml.vec3( baseX + 0.2, rightHeight, 0 )
	targetPosLocal = skel2:toLocalPos( rightFootTargetPos )
	targetDirLocal = skel2:toLocalDir( rightFootTargetDir )

	--[[if not Fabrik.solve( spine2, targetPosLocal, targetDirLocal, 1 ) then
		failed = true
		return
	end]]

	--[[targetDir = cpml.vec3( 1,0,0 )
	targetPos = getFootPlacement( t, ang+math.pi*0.5, 0 )
	targetPosLocal = skel2:toLocalPos( targetPos )
	targetDirLocal = skel2:toLocalDir( targetDir )
	Fabrik.solve( spine2, targetPosLocal, targetDirLocal, 20 )]]

	if Fabrik.validateChain( spine1 ) ~= true then
		love.graphics.captureScreenshot( "debug.png" )
		--failed = true
		--love.event.quit()
	end
	--Fabrik.solve( spine1, targetPos, targetDir, 3 )
end


function drawSkel( skel, alpha )
	data = skel:getDebugData( showConstraints )
	alpha = alpha or 1

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
		love.graphics.setColor( d.col[1], d.col[2], d.col[3], d.col[4]*alpha )
		if d.drawType == "line" then
			love.graphics.line( d.points )
		elseif d.drawType == "poly" then
			love.graphics.polygon( "fill", d.points )
		end
	end
	love.graphics.pop()

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
	--love.graphics.line( -1, 0, 1, 0 )
end


function love.draw()
	love.graphics.push()
	love.graphics.translate( love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.5 )
	love.graphics.scale( 300 )

	love.graphics.translate( -baseX, 0 )
	drawGrid( baseX )

	love.graphics.setColor( 0.4,0.5,1,1 )
	love.graphics.circle( "fill", leftFootTargetPos.x, leftFootTargetPos.y, 0.02 )
	local endPoint = leftFootTargetPos + targetDir*0.05
	love.graphics.line( leftFootTargetPos.x, leftFootTargetPos.y, endPoint.x, endPoint.y )

	love.graphics.setColor( 0.4,0.5,1,0.5 )
	love.graphics.circle( "fill", rightFootTargetPos.x, rightFootTargetPos.y, 0.02 )
	local endPoint = rightFootTargetPos + targetDir*0.05
	love.graphics.line( rightFootTargetPos.x, rightFootTargetPos.y, endPoint.x, endPoint.y )
	
	--baseX = speed*t
	-- Draw the floor:
	floor = {}
	for x=-1,1,0.01 do
		y = getFloorHeight( baseX + x, -0.2 )
		table.insert( floor, baseX + x )
		table.insert( floor, y )
	end
	love.graphics.setColor( 0.8, 0.8, 1, 0.3 )
	love.graphics.line( floor )
	floor = {}
	for x=-1,1,0.01 do
		y = getFloorHeight( baseX + x, 0 )
		table.insert( floor, baseX + x )
		table.insert( floor, y )
	end
	love.graphics.setColor( 0.8, 0.8, 1, 0.7 )
	love.graphics.line( floor )

	-- Draw reference posts:
	--[[baseXrounded = math.floor( baseX )
	print(baseX, baseXrounded)
	height = 0.03
	love.graphics.setColor( 0.8, 0.8, 1, 0.3 )
	for dx=-1,2,0.2 do
		x = baseXrounded + dx
		y = getFloorHeight( baseXrounded + dx, 0 )
		love.graphics.line( x, y, x, y-height )
	end]]

	--drawSkel( skel2, 0.6 )
	drawSkel( skel1, 1 )
	love.graphics.line( skel1.pos.x, skel1.pos.y, skel2.pos.x, skel2.pos.y )

	love.graphics.pop()

	love.graphics.setColor(1,1,1,1)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
	love.graphics.print("Speed: "..tostring(speed), 10, 25)
	love.graphics.print("Step Size: "..tostring(stepSize), 10, 40)
	love.graphics.print("Foot Raise: "..tostring(footRaise), 10, 55)
end

function getFloorHeight( x, y )
	local noise = love.math.noise( x, y )
	h = 0.25 + noise*0.3
	return h
end

function love.keypressed( key )
	if key == "space" then
		Fabrik.solve( spine1, targetPos, targetDir, 2 )
		--prevTargetPos = targetPos
	elseif key == "d" then
		showConstraints = not showConstraints
	elseif key == "right" then
		speed = speed + 0.1
	elseif key == "left" then
		speed = speed - 0.1
	elseif key == "j" then
		stepSize = stepSize - 0.1
	elseif key == "l" then
		stepSize = stepSize + 0.1
	elseif key == "i" then
		footRaise = footRaise + 0.05
	elseif key == "k" then
		footRaise = footRaise - 0.05
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


