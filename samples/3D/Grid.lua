package.path = "../../?.lua;" .. package.path
package.path = "../../?/init.lua;" .. package.path

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")

local Vertex = require("Vertex")

local Grid = class("Grid")
local const = require("const")

local gridTex = love.graphics.newImage( "grid.png" )
gridTex:setWrap("repeat")

require("util")

function Grid:initialize( w, h )

	local v1 = Vertex:new( cpml.vec3(w/2,h/2,0), 1 )
	local v2 = Vertex:new( cpml.vec3(w/2,-h/2,0), 1 )
	local v3 = Vertex:new( cpml.vec3(-w/2,h/2,0), 1 )
	local v4 = Vertex:new( cpml.vec3(-w/2,-h/2,0), 1 )
	v1.texCoord = cpml.vec2( w/2, h/2) v1.col = cpml.vec3(1,1,1)
	v2.texCoord = cpml.vec2( w/2, -h/2) v2.col = cpml.vec3(1,1,1)
	v3.texCoord = cpml.vec2( -w/2, h/2) v3.col = cpml.vec3(1,1,1)
	v4.texCoord = cpml.vec2( -w/2, -h/2) v4.col = cpml.vec3(1,1,1)

	local vList = {}
	table.insert( vList, v1:toTable() )
	table.insert( vList, v2:toTable() )
	table.insert( vList, v3:toTable() )
	table.insert( vList, v4:toTable() )

	local vMap = {1,2,3,2,3,4}

	self.mesh = love.graphics.newMesh( const.vFormatPlain, vList, "triangles" )
	self.mesh:setVertexMap( vMap )
	self.mesh:setTexture( gridTex )
	self.shader = love.graphics.newShader( "shaders/ShaderPixel.glsl",
		"shaders/ShaderVertex.glsl" )
	self.shader:send("scale", const.meters2Pixels )
end

function Grid:draw( projMat, viewMat )
	self.shader:send("projMat", projMat)
	self.shader:send("viewMat", viewMat)
	--love.graphics.setDepthMode( "lequal", false )
	love.graphics.setShader( self.shader )
	love.graphics.draw( self.mesh )
end

return Grid



