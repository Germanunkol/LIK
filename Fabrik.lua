
local cpml = require("lib.cpml")

Fabrik = {}

function Fabrik.solve( chain, targetPos, targetDir, maxIterations, debugSteps )

	local rootPos = chain[1]:getPos()
	local endEffector = chain[#chain]

	local lenCache = {}
	for j,b in ipairs(chain) do
		lenCache[j] = b.len
	end

	for i=1,maxIterations do

		--------------------------------------------
		-- Forward reaching pass:
		print("Forward reaching pass")


		chain[#chain]:setPos( targetPos )
		local targetRot = rotBetweenVecs( cpml.vec3(1,0,0), targetDir,
			chain[#chain].constraint and chain[#chain].constraint.axis or nil )
		chain[#chain]:setRot( targetRot, true )

		for j=#chain-1,1,-1 do
			local curBone = chain[j]
			local curChild = chain[j+1]
			local curPos = curBone:getPos()
			local curChildPos = curChild:getPos()
	
			local diff = (curPos - curChildPos):normalize()
			if diff:len() == 0 then
				diff = cpml.vec3(1,0,0)
			end
			local newPos = curChildPos + diff*curBone.len

			curBone:setPosFixedChild( newPos, curChild )
			if love.keyboard.isDown("1") then return end

			-- Check what the pose of the child currently is...
			local posBeforeValidation = curChild:getPos()
			local rotBeforeValidation = curChild:getRot()
			-- ... and fix if necessary:
			curChild:correctRot()
			print(curChild.lRot:to_angle_axis())
			if love.keyboard.isDown("2") then return end
			curChild:correctPos()
			if love.keyboard.isDown("3") then return end

			local posAfterValidation = curChild:getPos()
			local rotAfterValidation = curChild:getRot()
			local undoMovement = posBeforeValidation - posAfterValidation
			local undoRotation = rotBeforeValidation * rotAfterValidation:inverse()
			print(undoMovement)
			print("rot before", rotBeforeValidation:to_angle_axis())
			print("rot after", rotAfterValidation:to_angle_axis())
			print(undoRotation:to_angle_axis())
			if love.keyboard.isDown("4") then return end
			--curBone:setRot( curBone:getRot()*undoRotation )
			curBone:rotateAroundPoint( curChild:getPos(), undoRotation )
			curBone:setPos( curBone:getPos() + undoMovement )
			--curChild:setPos( posBeforeValidation )
			--curChild:setRot( rotBeforeValidation )
			
			-- Simply "undo" the rotation/translation to both child _and also the parent_.

		end


		--------------------------------------------
		-- Backward reaching pass:
		print("Backward reaching pass")
		
		-- Move root bone back to original position:
		chain[1]:setPosFixedChild( rootPos, chain[2] )
		-- Ensure root bone is within valid bounds:
		chain[1]:correctRot( chain[2] )

		for j=2,#chain do
			local curBone = chain[j]
			local curParent = chain[j-1]
			local curPos = curBone:getPos()
			local curParentPos = curParent:getPos()
			local curChild = chain[j+1]
	
			local diff = (curPos - curParentPos):normalize()
			if diff:len() == 0 then
				diff = cpml.vec3(1,0,0)
			end
			local newPos = curParentPos + diff*curBone.len
		
			if curChild then
				curBone:setPosFixedChild( newPos, curChild )
			else
				curBone:setPos( newPos )
			end

			curBone:correctRot()
			curBone:correctPos()

		end
	end
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
