
local cpml = require("lib.cpml")

Fabrik = {}

function Fabrik.solve( chain, targetPos, targetDir, maxIterations, debugSteps )

	rootPos = chain[1]:getPos()

	debugSteps = debugSteps or math.huge
	--maxIterations = 1
	--chain[1].skeleton:setDebugChain( chain )

	for i=1,maxIterations do

		-- Store bone offsets:
		local lPos = {}
		for j,b in ipairs(chain) do
			lPos[b] = b.lPos
		end
		
		-- Forward pass:
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
			local curDiff = cpml.vec3.normalize(curPos - curChildPos)
			if cpml.vec3.len( curDiff ) == 0 then
				curDiff = cpml.vec3(1,0,0)
			end
			local newPos = curDiff*curLen + curChildPos

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

			print("forward", j)
			if not Fabrik.validateBone( curChild, j ) then
				return false
			end
			--if not Fabrik.validateChain( chain ) then
				--return false
			--end
		end

		--if love.keyboard.isDown("t") then
			--return
		--end

		-- Backward pass:
		chain[1]:setPosFixedChild( rootPos, chain[2] )
		chain[1]:setLocalRotFixedChild( chain[1].lRot, chain[2] )
		for j=2,#chain do
			--if j>2 then return end
			local curBone = chain[j]
			local curParent = chain[j-1]
			local curPos = curBone:getPos()
			local curParentPos = curParent:getPos()
			local curChild = chain[j+1]

			local curLen = cpml.vec3.len( lPos[curBone] )
			local curDiff = cpml.vec3.normalize(curPos - curParentPos)
			if cpml.vec3.len( curDiff ) == 0 then
				curDiff = cpml.vec3(-1,0,0)
			end
			local newPos = curDiff*curLen + curParentPos

			if curChild then
				curBone:setPosFixedChild( newPos, chain[j+1] )
			else
				curBone:setPos( newPos )
			end

			-- If my parent has a constraint, abide by it:
			if curParent.constraint then
				curBone:validatePosWRTParent( chain[j+1] )
			end
			print("backward2", j)
			if not Fabrik.validateBone( curBone, j ) then
				return false
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
		
			print("backward3", j)
			if not Fabrik.validateBone( curBone, j ) then
				return false
			end
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
	return true
end

function Fabrik.validateBone( bone, name )
	local valid = true
	local eps = math.pi*0.001
	if bone.constraint then
		--if bone.parent then
		--else
		local ang, axis = cpml.quat.to_angle_axis( bone.lRot )
		ang = angleRange(ang)
		if cpml.vec3.dist2( axis, bone.constraint.axis ) > 0.5 then
			axis = -axis
			ang = -ang
		end
		if ang < bone.constraint.minAng - eps then
			print( "Bone ".. name .. " (" .. ang .. ") lower than min angle (" ..

				bone.constraint.minAng .. ")!" )
			valid = false
		elseif ang > bone.constraint.maxAng + eps then
			print( "Bone " .. name .. " (" .. ang .. ") higher than max angle (" ..
				bone.constraint.maxAng .. ")!" )
			valid = false
		end
		--end
	end
	return valid
end

function Fabrik.validateChain( chain )
	local valid = true
	for i, bone in ipairs(chain) do
		-- Check that bone is within bounds with respect to parent:
		local bvalid = Fabrik.validateBone( bone, i )
		valid = valid and bvalid
	end
	return valid
end

return Fabrik
