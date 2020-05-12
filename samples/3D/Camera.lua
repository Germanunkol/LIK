package.path = "../../?.lua;" .. package.path
package.path = "../../?/init.lua;" .. package.path

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")
--require("utils")

local Camera = class("Camera")

function Camera:initialize()
	self.pos = cpml.vec3()
	self.rot = cpml.quat()
	self.height = 0
	self.near = -5000
	self.far = 5000
	self.zoom = 1
	self.minZoom = 0.75
	self.maxZoom = 1.5
end

function Camera:setPos( p )
	self.pos = p
end

function Camera:setRot( r )
	self.rot = r
end

function Camera:activate()
end

function Camera:deactivate()
end

function Camera:setZoom( z )
	self.zoom = math.max( math.min( z, self.maxZoom ), self.minZoom )
end

function Camera:getProjectionMatrix()
	w,h,f = love.window.getMode()
	r = w/2*self.zoom
	t = h/2*self.zoom
	f = -self.far
	n = -self.near
 	mat = cpml.mat4.from_ortho(-r,r,t,-t,n,f)
	cpml.mat4.transpose( mat, mat )
	return mat
end

function Camera:getViewMatrix()
	-- Rotation around x axis:
	--mat = cpml.mat4.from_angle_axis(self.tilt,cpml.vec3(1,0,0))
	mat = cpml.mat4.from_quaternion(self.rot)
	-- Set position:
	mat[4] = -self.pos.x
	--mat[8] = -self.pos.y*math.cos(self.tilt)
	mat[8] = -self.pos.y
	mat[12] = self.pos.z
	return mat
end

return Camera
