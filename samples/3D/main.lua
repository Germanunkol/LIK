package.path = "../../?.lua;" .. package.path
package.path = "../../?/init.lua;" .. package.path

local Skeleton = require("Skeleton")
local Bone = require("Bone")
local Fabrik = require("Fabrik")
local Camera = require("Camera")
local Arm = require("Arm")

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")

function love.load()

	arm = Arm:new()

	targetDir = cpml.vec3(-1,0,0)

	cursorX, cursorY = -0.4,0

	love.keyboard.setKeyRepeat( true )

	love.graphics.setMeshCullMode( "none" )
	love.graphics.setDepthMode( "lequal", true )
	--w, h, flags = love.window.getMode( )
	love.graphics.setCanvas({depth=true})
    camera = Camera()
	camera:setPos( cpml.vec3(100,100,0), 200 )
	camera:setRot( cpml.quat.from_angle_axis( 0.7*math.pi, cpml.vec3(1,0,0) ) )

end

function love.update( dt )
	t = love.timer.getTime()
	--camera:setRot( cpml.quat.from_angle_axis( math.cos(t)*math.pi, cpml.vec3(1,0,0) ) )
	--Fabrik.solve( spine, targetPosLocal, targetDirLocal, 1 )
end

function love.draw()
	projMat = camera:getProjectionMatrix()
	viewMat = camera:getViewMatrix()

	arm:draw( projMat, viewMat )

	love.graphics.setShader()
	love.graphics.setColor(1,1,1,1)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function love.keypressed( key, code, isrepeat )
end

