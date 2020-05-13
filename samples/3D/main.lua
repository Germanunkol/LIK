package.path = "../../?.lua;" .. package.path
package.path = "../../?/init.lua;" .. package.path

local const = require("const")

local Skeleton = require("Skeleton")
local Bone = require("Bone")
local Fabrik = require("Fabrik")
local Camera = require("Camera")
local Grid = require("Grid")
local Arm = require("Arm")
local Marker = require("Marker")

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")

function love.load()

	arm = Arm:new()
	grid = Grid:new( 20, 20 )
	marker = Marker:new( cpml.vec3( 0,1,0 ) )

	targetDir = cpml.vec3(-1,0,0)

	cursorX, cursorY = -0.4,0

	love.keyboard.setKeyRepeat( true )

	love.graphics.setMeshCullMode( "none" )
	love.graphics.setDepthMode( "lequal", true )
	--w, h, flags = love.window.getMode( )
	love.graphics.setCanvas({depth=true})
    camera = Camera()
	camera:setPos( cpml.vec3(0,0,0), 200 )
	local rZ = cpml.quat.from_angle_axis( 0.25*math.pi, cpml.vec3(0,0,1) )
	local rX = cpml.quat.from_angle_axis( 0.7*math.pi, cpml.vec3(1,0,0) )
	camera:setRot( rZ*rX )
	--camera:setRot( cpml.quat.from_angle_axis( math.pi, cpml.vec3(1,0,0) ) )

	love.graphics.setBackgroundColor( 0.1, 0.1, 0.1 )

end

function love.update( dt )
	t = love.timer.getTime()

	arm:update( dt )
	--camera:setRot( cpml.quat.from_angle_axis( math.cos(t)*math.pi, cpml.vec3(1,0,0) ) )
	--Fabrik.solve( spine, targetPosLocal, targetDirLocal, 1 )
end

function love.draw()
	c,w = love.graphics.getDepthMode()
	print(c,w)
	projMat = camera:getProjectionMatrix()
	viewMat = camera:getViewMatrix()

	love.graphics.push()
	love.graphics.setBlendMode( "alpha" )
	--love.graphics.scale( const.meters2Pixels )

	grid:draw( projMat, viewMat )

	arm:draw( projMat, viewMat )
	marker:draw( projMat, viewMat )

	love.graphics.pop()
	love.graphics.setShader()
	love.graphics.setColor(1,1,1,1)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function love.keypressed( key, code, isrepeat )
end

