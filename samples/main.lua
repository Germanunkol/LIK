package.path = "../?.lua;" .. package.path
package.path = "../?/init.lua;" .. package.path

local Skeleton = require("Skeleton")
local Bone = require("Bone")

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")

function love.load()
	vZero = cpml.vec3(0,0,0)

	skel1 = Skeleton:new()

	b1_1 = Bone:new( skel1, nil, vZero, cpml.quat(), 0.2 )
	b1_2 = Bone:new( skel1, b1_1, vZero, cpml.quat(), 0.2 )
	b1_3 = Bone:new( skel1, b1_2, vZero, cpml.quat(), 0.2 )
	spine1 = { b1_1, b1_2, b1_3 }

	skel2 = Skeleton:new()

	b2_1 = Bone:new( skel2, nil, vZero, cpml.quat(), 0.2 )
	b2_2 = Bone:new( skel2, b2_1, vZero, cpml.quat(), 0.2 )
	b2_3 = Bone:new( skel2, b2_2, vZero, cpml.quat(), 0.2 )

	b2_1:setConstraint( cpml.vec3(0,0,1), -math.pi, math.pi*0.1 )
	b2_2:setConstraint( cpml.vec3(0,0,1), math.pi*0.5, math.pi*0.5 )
	b2_3:setConstraint( cpml.vec3(0,0,1), 0, math.pi*0.2 )

	--b2:setConstraint( cpml.vec3(0,1,1), -math.pi*0.01, math.pi*0.1 )
	
	--[[rot1 = cpml.quat.from_angle_axis(math.pi*0.5, cpml.vec3(0,0,1))
	rot2 = cpml.quat.from_angle_axis(-math.pi*0.5, cpml.vec3(0,0,1))
	spine = {}
	table.insert(spine, b1)
	for i=1,5 do
		b = Bone:new( skel, b, vZero, cpml.quat(), 0.1 )
		table.insert( spine, b )
		-- Legs:
		l1Thigh = Bone:new( skel, b, vZero, rot1, 0.1 )
		l1Shin = Bone:new( skel, l1Thigh, vZero, cpml.quat(), 0.12 )
		l1Foot = Bone:new( skel, l1Shin, vZero, cpml.quat(), 0.02 )
		l2Thigh = Bone:new( skel, b, vZero, rot2, 0.1 )
		l2Shin = Bone:new( skel, l2Thigh, vZero, cpml.quat(), 0.12 )
		l2Foot = Bone:new( skel, l2Shin, vZero, cpml.quat(), 0.02 )
	end

	rot = cpml.quat.from_angle_axis(math.pi, cpml.vec3(0,0,1))
	b4 = Bone:new( skel, b1, cpml.vec3(-0.5,0,0), rot, 0.5 )]]
end

function love.draw()
	data = skel1:getDebugData()

	love.graphics.push()
	love.graphics.translate( love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.5 )
	love.graphics.translate( 0, -50 )
	love.graphics.scale( 200 )
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

	data = skel2:getDebugData()

	love.graphics.push()
	love.graphics.translate( love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.5 )
	love.graphics.translate( 0, 50 )
	love.graphics.scale( 200 )
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
	
	ang = t
	q2 = cpml.quat.from_angle_axis( ang, cpml.vec3(0,0,1) )
	b1_1:setLocalRot( q2 )
	b1_2:setLocalRot( q2 )
	b1_3:setLocalRot( q2 )

	b2_1:setLocalRot( q2 )
	b2_2:setLocalRot( q2 )
	b2_3:setLocalRot( q2 )
end
