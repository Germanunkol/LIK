
local cpml = require("lib.cpml")

Fabrik = {}

function Fabrik.solve( chain, targetPos, maxIterations, debugSteps )

	rootPos = chain[1]:getPos()

	debugSteps = debugSteps or math.huge

	for i=1,maxIterations do
		
		-- Forward pass:
		local lPos = {}
		for j,b in ipairs(chain) do
			lPos[b] = b.lPos
		end
		chain[#chain]:setPos( targetPos )
		for j=#chain-1,1,-1 do
			curBone = chain[j]
			curChild = chain[j+1]
			curPos = curBone:getPos()
			curChildPos = curChild:getPos()

			-- Get the current offset between the curBone and the child bone:
			curLen = cpml.vec3.len( lPos[curChild] )
			newPos = cpml.vec3.normalize(curPos - curChildPos)*curLen + curChildPos

			curBone:setPosFixedChild( newPos, curChild )
		end

		-- Backward pass:
		chain[1]:setPos( rootPos )
		for j=2,#chain do
			curBone = chain[j]
			curParent = chain[j-1]
			curPos = curBone:getPos()
			curParentPos = curParent:getPos()

			curLen = cpml.vec3.len( lPos[curBone] )
			newPos = cpml.vec3.normalize(curPos - curParentPos)*curLen + curParentPos

			if j < #chain then
				curBone:setPosFixedChild( newPos, chain[j+1] )
			else
				curBone:setPos( newPos )
			end
		end

	end

	--[[for j,b in ipairs( chain ) do
		if j < #chain then
			--if j == #chain-1 then
			local child = chain[j+1]
			local dir = cpml.vec3.normalize( child:getPos() - b:getPos() )
			local r = rotBetweenVecs( cpml.vec3(1,0,0), dir )
			--print( cpml.quat.to_angle_axis( r ) )
				--b:setRotFixedChild( r, child )
			print("Set rot", cpml.quat.to_angle_axis(r) )
				b:setRot( r, child )
			--end
		end
	end]]
	local b = chain[#chain]
	local dir = cpml.vec3.normalize( targetPos - b:getPos() )
	print( "dir", dir )
	local r = rotBetweenVecs( cpml.vec3(1,0,0), dir )
	--print( cpml.quat.to_angle_axis( r ) )
	--b:setRotFixedChild( r, child )
	print("Set rot", cpml.quat.to_angle_axis(r) )
	b:setRot( r )
				
	local b = chain[#chain-1]
	local child = chain[#chain]
	local dir = cpml.vec3.normalize( child:getPos() - b:getPos() )
	print( "dir", dir )
	local r = rotBetweenVecs( cpml.vec3(1,0,0), dir )
	--print( cpml.quat.to_angle_axis( r ) )
	--b:setRotFixedChild( r, child )
	print("Set rot", cpml.quat.to_angle_axis(r) )
	b:setRotFixedChild( r, child )
		
	local b = chain[#chain-2]
	local child = chain[#chain-1]
	local dir = cpml.vec3.normalize( child:getPos() - b:getPos() )
	print( "dir", dir )
	local r = rotBetweenVecs( cpml.vec3(1,0,0), dir )
	--print( cpml.quat.to_angle_axis( r ) )
	--b:setRotFixedChild( r, child )
	print("Set rot", cpml.quat.to_angle_axis(r) )
	b:setRotFixedChild( r, child )

	print("Done")
end

return Fabrik
