package.path = "../../?.lua;" .. package.path
package.path = "../../?/init.lua;" .. package.path

local class = require("lib.middleclass.middleclass")
local cpml = require("lib.cpml")

local Vertex = class("Vertex")

function Vertex:initialize( pos, ID, boneID )
	self.lPos = pos
	self.ID = ID
	self.texCoord = cpml.vec2(0,0)
	--self.col = cpml.vec3(self.lPos.z*0.4,self.lPos.z*0.4,self.lPos.z*0.4)
	self.col = cpml.vec3(0.5*pos.z+0.5,0.5*pos.z,0)
	--self.col = cpml.vec3(0.5, 0.4, self.localPos.z )
	if boneID then
		self.boneIDs = {boneID,-1,-1,-1}
		self.boneWeights = {1,0,0,0}
	end
end

function Vertex:toTable()
	--[[if self.pos == nil then
		error("You must call Skeleton:bindVertices() before calling the toTable() method!")
	end]]
	if self.boneIDs then
		return { self.lPos.x, self.lPos.y, self.lPos.z,
			self.texCoord.x, self.texCoord.y,
			self.col.x, self.col.y, self.col.z,
			--self.boneIDs[1]/7, self.boneIDs[2]/7, self.pos.z/10,
			--self.boneIDs[1]/7, 0, self.pos.z/10,
			--self.boneWeights[1]/2, self.boneWeights[2]/2, self.pos.z/10,
			self.boneIDs[1]-1, self.boneIDs[2]-1, self.boneIDs[3]-1, self.boneIDs[4]-1,
			self.boneWeights[1], self.boneWeights[2], self.boneWeights[3], self.boneWeights[4]
		}
	else
		return { self.lPos.x, self.lPos.y, self.lPos.z,
			self.texCoord.x, self.texCoord.y,
			self.col.x, self.col.y, self.col.z
		}
	end
end

return Vertex
