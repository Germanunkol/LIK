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
	local data = {}
	for b,t in pairs(self.bones) do
		local boneData = b:getDebugData()
		for key, val in pairs(boneData) do
			print(key, val)
			--print(i,d)
			table.insert( data, val )
		end
	end
	return data
end

return Skeleton
