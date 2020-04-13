local class = require("lib/middleclass/middleclass")
local cpml = require("lib.cpml")

local Skeleton = class("Skeleton")

function Skeleton:initialize()
	self.bones = {}
end

function Skeleton:addBone( b )
	if self.bones[b] == nil then
		self.bones[b] = true
	end
end

function Skeleton:getDebugData()
	data = {}
	for b,t in pairs(self.bones) do
		pS = b:getPos()
		pE = b:getEndPos()
		len = cpml.vec3.len( pS - pE )
		--r = b:getRot()
		--tmp = cpml.vec3( 1,0,0 )
		w = 0.05
		pO0 = b:toGlobal( cpml.vec3( len*0.05, len*w, 0 ) )
		pO1 = b:toGlobal( cpml.vec3( len*0.05, -len*w, 0 ) )

		-- Insert a triangle:
		d = { col={0.5,0.5,0.5},
			drawType="tri",
			p0=pS,
			p1=pO0,
			p2=pE,
			p3=pO1,
		}
		table.insert( data, d )

		d = { col={0.75,0.5,0.5},
			drawType="line",
			p0=pS,
			p1=pE
		}
		table.insert( data, d )
	end
	return data
end

return Skeleton
