
local cpml = require("lib.cpml")

Fabrik = {}

function Fabrik.solve( chain, targetPos, targetDir, maxIterations, debugSteps )

	rootPos = chain[1]:getPos()

	debugSteps = debugSteps or math.huge

	for i=1,maxIterations do
		
		-- Forward pass:
		local lPos = {}
		for j,b in ipairs(chain) do
			lPos[b] = b.lPos
		end
		chain[#chain]:setPos( targetPos )
		targetRot = rotBetweenVecs( cpml.vec3(1,0,0), targetDir )
		chain[#chain]:setRot( targetRot, true )
		-- DEBUG: 2
		for j=#chain-1,1,-1 do
			local curBone = chain[j]
			local curChild = chain[j+1]
			local curPos = curBone:getPos()
			local curChildPos = curChild:getPos()

			-- Get the current offset between the curBone and the child bone:
			local curLen = cpml.vec3.len( lPos[curChild] )
			local newPos = cpml.vec3.normalize(curPos - curChildPos)*curLen + curChildPos

			curBone:setPosFixedChild( newPos, curChild )

			-- If my child has a constraint, abide by it:
			if curChild.constraint then
				curBone:validatePosWRTChild( curChild )
			end
			--if not curChild.constraint then	
				--local dirToChild = cpml.vec3.normalize( curChildPos - curPos )
				--local r = rotBetweenVecs( cpml.vec3(1,0,0), dirToChild )
				--curBone:setRotFixedChild( r, curChild )
			-- If I do have a constraint, ensure my position is valid (if child is fixed)
			--else
				curBone:validatePosWRTChild( curChild )
			--end
		end

		-- Backward pass:
		--chain[1]:setPos( rootPos )
		--chain[1]:validateRot()
		--[[for j=2,#chain do
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

			-- If my parent has a constraint, abide by it:
			if curParent.constraint then
				curBone:validatePosWRTParent( curParent, chain[j+1] )
			end
		end]]

	end

	--[[for j,b in ipairs( chain ) do
		-- Let last element point towards target:
		if j == #chain then
			--local dir = cpml.vec3.normalize( targetPos - b:getPos() )
			--local r = rotBetweenVecs( cpml.vec3(1,0,0), dir )
			--b:setRot( r )
		-- Let other elements point towards their child:
		else
			local child = chain[j+1]
			local dir = cpml.vec3.normalize( child:getPos() - b:getPos() )
			local r = rotBetweenVecs( cpml.vec3(1,0,0), dir )
			b:setRotFixedChild( r, child )
		end
	end]]

end

return Fabrik
