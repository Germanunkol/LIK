package.path = "../../?.lua;" .. package.path
package.path = "../../?/init.lua;" .. package.path

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")

local Vertex = require("Vertex")

local Marker = class("Marker")
local const = require("const")

require("util")

function Marker:initialize( col )
	local w = 0.5	-- in Meters

	local v1 = Vertex:new( cpml.vec3(0,0,-w), 1 )
	local v2 = Vertex:new( cpml.vec3(w/2,w/2,0), 1 )
	local v3 = Vertex:new( cpml.vec3(w/2,-w/2,0), 1 )
	local v4 = Vertex:new( cpml.vec3(-w/2,-w/2,0), 1 )
	local v5 = Vertex:new( cpml.vec3(-w/2,w/2,0), 1 )
	local v6 = Vertex:new( cpml.vec3(0,0,w), 1 )
	v1.col = col*0.1
	v2.col = col*0.5
	v3.col = col*0.5
	v4.col = col*0.5
	v5.col = col*0.5
	v6.col = col

	local vList = {}
	table.insert( vList, v1:toTable() )
	table.insert( vList, v2:toTable() )
	table.insert( vList, v3:toTable() )
	table.insert( vList, v4:toTable() )
	table.insert( vList, v5:toTable() )
	table.insert( vList, v6:toTable() )

	local vMap = {
		1,2,3,
		1,3,4,
		1,4,5,
		1,5,2,
		2,3,6,
		3,4,6,
		4,5,6,
		5,2,6 }

	self.mesh = love.graphics.newMesh( const.vFormatPlain, vList, "triangles" )
	self.mesh:setVertexMap( vMap )
	self.shader = love.graphics.newShader( "shaders/ShaderPixel.glsl",
		"shaders/ShaderVertex.glsl" )
	self.shader:send("scale", const.meters2Pixels )
end

function Marker:draw( projMat, viewMat )
	self.shader:send("projMat", projMat)
	self.shader:send("viewMat", viewMat)
	love.graphics.setShader( self.shader )
	love.graphics.draw( self.mesh )
end

return Marker



