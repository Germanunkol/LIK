
local cpml = require("lib.cpml")

Fabrik = {}

function Fabrik.solve( chain, targetPos, targetDir, maxIterations, debugSteps )

	rootPos = chain[1]:getPos()

	debugSteps = debugSteps or math.huge
	--maxIterations = 1

	for i=1,maxIterations do
		
		-- Forward pass:
		local lPos = {}
		for j,b in ipairs(chain) do
			lPos[b] = b.lPos
		end
		chain[#chain]:setPos( targetPos )
		if targetDir then
			targetRot = rotBetweenVecs( cpml.vec3(1,0,0), targetDir )
			chain[#chain]:setRot( targetRot, true )
		else
		-- Just rotate towards the child:
			local dirFromParent = cpml.vec3.normalize( targetPos - chain[#chain-1]:getPos() )
			local r = rotBetweenVecs( cpml.vec3(1,0,0), dirFromParent )
			chain[#chain]:setRot( r )
		end
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
			else
				-- Just rotate towards the child:
				local dirToChild = cpml.vec3.normalize( curChildPos - curPos )
				local r = rotBetweenVecs( cpml.vec3(1,0,0), dirToChild )
				curBone:setRotFixedChild( r, curChild )
			end
			--if not curChild.constraint then	
				--local dirToChild = cpml.vec3.normalize( curChildPos - curPos )
				--local r = rotBetweenVecs( cpml.vec3(1,0,0), dirToChild )
				--curBone:setRotFixedChild( r, curChild )
			-- If I do have a constraint, ensure my position is valid (if child is fixed)
			--else
				--curBone:validatePosWRTChild( curChild )
			--end

		end

		-- Backward pass:
		chain[1]:setPosFixedChild( rootPos, chain[2] )
		chain[1]:setLocalRotFixedChild( chain[1].lRot, chain[2] )
		for j=2,#chain do
			local curBone = chain[j]
			local curParent = chain[j-1]
			local curPos = curBone:getPos()
			local curParentPos = curParent:getPos()
			local curChild = chain[j+1]

			local curLen = cpml.vec3.len( lPos[curBone] )
			local newPos = cpml.vec3.normalize(curPos - curParentPos)*curLen + curParentPos

			if curChild then
				curBone:setPosFixedChild( newPos, chain[j+1] )
			else
				curBone:setPos( newPos )
			end

			--if i == 1 or j == 2 then
				-- If my parent has a constraint, abide by it:
				if curParent.constraint then
					print("j", j)
					curBone:validatePosWRTParent( chain[j+1] )
					print("j", j)
				end
				--if i == 1 then

				local dirFromParent = cpml.vec3.normalize(
				curBone:getPos() - curParent:getPos() )
				local r = rotBetweenVecs( cpml.vec3(1,0,0), dirFromParent )
				curParent:setRotFixedChild( r, curBone )

				-- Ensure the constraints are still valid by rotating myself:
				if curChild then
					curBone:setLocalRotFixedChild( curBone.lRot, chain[j+1] )
				else
					curBone:setLocalRot( curBone.lRot )
				end
			--end
		end

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
