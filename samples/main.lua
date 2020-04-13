package.path = "../?.lua;" .. package.path
package.path = "../?/init.lua;" .. package.path

local Skeleton = require("Skeleton")
local Bone = require("Bone")

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")

function love.load()
	print("Sample started")
	skel = Skeleton:new()
	b1 = Bone:new( skel, nil, cpml.quat() )
end

function love.draw()
	data = skel:getDebugData()

	love.graphics.push()
	love.graphics.translate( love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.5 )
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

