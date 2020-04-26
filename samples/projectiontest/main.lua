package.path = "../../?.lua;" .. package.path
package.path = "../../?/init.lua;" .. package.path

local Skeleton = require("Skeleton")
local Bone = require("Bone")
local Fabrik = require("Fabrik")

local cpml = require("lib.cpml")

function love.load()
	love.keyboard.setKeyRepeat( true )

	skel = Skeleton:new()
	bone1 = Bone:new( skel, nil, cpml.vec3(), cpml.quat(), 0.3 )
	bone2 = Bone:new( skel, bone1, cpml.vec3(0.3,0,0), cpml.quat(), 0.2 )
	bone3 = Bone:new( skel, bone2, cpml.vec3(0.2,0,0), cpml.quat(), 0.1 )

	bone1:setConstraint( cpml.vec3(0,0,1), 0, math.pi*0.5 )
	bone2:setConstraint( cpml.vec3(0,0,1), 0, math.pi*0.5 )
	bone3:setConstraint( cpml.vec3(0,0,1), 0, math.pi*0.5 )

	spine = { bone1, bone2, bone3 }
end

function love.keypressed( key, code )
	if key == "space" then
		local p = cpml.vec3( math.random() - 0.5, math.random() - 0.5, math.random() - 0.5 )
		bone1:setPos( p )
		local r = cpml.quat( math.random() - 0.5, math.random() - 0.5, math.random() - 0.5, math.random() - 0.5 )
		bone1:setRot( r:normalize() )
		--bone1:correctRot()
		bone1:correctRot()
		bone1:correctPos()

		local p = cpml.vec3( math.random() - 0.5, math.random() - 0.5, math.random() - 0.5 )
		bone2:setPos( p )
		local r = cpml.quat( math.random() - 0.5, math.random() - 0.5, math.random() - 0.5, math.random() - 0.5 )
		bone2:setRot( r:normalize() )
		bone2:correctRot()
		bone2:correctPos()

		local p = cpml.vec3( math.random() - 0.5, math.random() - 0.5, math.random() - 0.5 )
		bone3:setPos( p )
		local r = cpml.quat( math.random() - 0.5, math.random() - 0.5, math.random() - 0.5, math.random() - 0.5 )
		bone3:setRot( r:normalize() )
		bone3:correctRot()
		bone3:correctPos()
	end
end

--[[local skelAng = 0 
function love.update( dt )
	skelAng = skelAng - dt
	skel.rot = cpml.quat.from_angle_axis( skelAng, cpml.vec3(0,0,1) )
end]]

function drawSkel( skel, alpha )
	data = skel:getDebugData( true )
	alpha = alpha or 1

	love.graphics.push()
	love.graphics.translate( skel.pos.x, skel.pos.y )
	local ang,axis = skel.rot:to_angle_axis()
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
	love.graphics.line( -1, 0, 1, 0 )
	love.graphics.line( 0, -1, 0, 1 )
end


function love.draw()
	love.graphics.push()
	love.graphics.translate( love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.5 )
	love.graphics.scale( 300 )

	drawGrid( 0 )

	drawSkel( skel, 1 )

	love.graphics.pop()

	love.graphics.setColor(1,1,1,1)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end


