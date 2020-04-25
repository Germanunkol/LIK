
local cpml = require("lib.cpml")

Fabrik = {}

function Fabrik.solve( chain, targetPos, targetDir, maxIterations, debugSteps )

	rootPos = chain[1]:getPos()

	debugSteps = debugSteps or math.huge
	--maxIterations = 1
	--chain[1].skeleton:setDebugChain( chain )

	for i=1,maxIterations do

		-- Store bone offsets:
		local len = {}
		for j,b in ipairs(chain) do
			len[b] = cpml.vec3.len( b.lPos )
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

		print("Forward:")
			
		-- DEBUG: 2
		for j=#chain-1,1,-1 do
			print("BONE ", j)
			local curBone = chain[j]
			local curChild = chain[j+1]
			local curPos = curBone:getPos()
			local curChildPos = curChild:getPos()

			print("1", curBone:getRot():to_angle_axis())

			-- Get the current offset between the curBone and the child bone:
			local curLen = len[curChild]
			local curDiff = cpml.vec3.normalize(curPos - curChildPos)
			if cpml.vec3.len( curDiff ) == 0 then
				curDiff = cpml.vec3(1,0,0)
			end
			local newPos = curDiff*curLen + curChildPos

			curBone:setPosFixedChild( newPos, curChild )

			--if j == 1 and love.keyboard.isDown("t") then return false end
			-- If my child has a constraint, abide by it:
			if curChild.constraint then
				curBone:validatePosWRTChild( curChild )
			else
				-- Just rotate towards the child:
				local dirToChild = cpml.vec3.normalize( curChildPos - curPos )
				local fallbackAxis = nil
				if curBone.constraint then
					fallbackAxis = curBone.constraint.axis -- TODO: To global axis?
				end
				local r = rotBetweenVecs( cpml.vec3(1,0,0), dirToChild, fallbackAxis )
				curBone:setRotFixedChild( r, curChild, true )
			end
			--if not curChild.constraint then	
				--local dirToChild = cpml.vec3.normalize( curChildPos - curPos )
				--local r = rotBetweenVecs( cpml.vec3(1,0,0), dirToChild )
				--curBone:setRotFixedChild( r, curChild )
			-- If I do have a constraint, ensure my position is valid (if child is fixed)
			--else
				--curBone:validatePosWRTChild( curChild )
			--end

			--if not Fabrik.validateChain( chain ) then
				--return false
			--end
		end

		-- Backward pass:
		chain[1]:setPosFixedChild( rootPos, chain[2] )
		chain[1]:setLocalRotFixedChild( chain[1].lRot, chain[2] )

		print("backward:")

		for j=2,#chain do
			print("BONE ", j)
			--if j>2 then return end
			local curBone = chain[j]
			local curParent = chain[j-1]
			local curPos = curBone:getPos()
			local curParentPos = curParent:getPos()
			local curChild = chain[j+1]

			local curLen = len[curBone]
			local curDiff = cpml.vec3.normalize(curPos - curParentPos)
			if cpml.vec3.len( curDiff ) == 0 then
				curDiff = cpml.vec3(-1,0,0)
			end
			local newPos = curDiff*curLen + curParentPos

			print("4", curBone:getRot():to_angle_axis())

			if curChild then
				curBone:setPosFixedChild( newPos, curChild )
			else
				curBone:setPos( newPos )
			end

			print("5", curBone:getRot():to_angle_axis())

			-- If my parent has a constraint, abide by it:
			if curParent.constraint then
				curBone:validatePosWRTParent( chain[j+1] )
			end

			print("6", curBone:getRot():to_angle_axis())

			-- Ensure the parent is facing me:
			local foundRot = curParent:findRotationTo( curBone:getPos() )
			curParent:setRotFixedChild( foundRot, curBone, true )
			--if true then return false end

			if j == 3 and love.keyboard.isDown("t") then return end

			print("7", curBone:getRot():to_angle_axis())

			-- Ensure the constraints are still valid by rotating myself:
			if curChild then
				print("child")
				print( curBone.lRot:to_angle_axis() )
				curBone:setLocalRotFixedChild( curBone.lRot, curChild )
			else
				curBone:setLocalRot( curBone.lRot )
			end

			print("8", curBone:getRot():to_angle_axis())
			print("constraint", curBone.constraint)

			for c,b in ipairs(chain) do
				print(c,b,b:getPos(),cpml.quat.to_angle_axis(b:getRot()))
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
