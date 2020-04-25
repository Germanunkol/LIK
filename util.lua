local cpml = require("lib.cpml")

-- Rotate and angle by 2*pi until it's in the -pi to +pi range:
function angleRange( v )
	while v < -math.pi do
		v = v + math.pi*2
	end
	while v > math.pi do
		v = v - math.pi*2
	end
	return v
end

-- Project a rotation onto a direction axis, i.e. extract the part of the rotation
-- which rotates around this axis (twist) and the part rotating around the direction
-- perpendicular (swing).
-- See this answer on SO: https://stackoverflow.com/a/22401169/1936575
function swingTwistDecomposition( rotation, direction )
	--local rAngle, rAxis = cpml.quat.to_angle_axis( rotation )
	local rAxis = cpml.vec3( rotation.x, rotation.y, rotation.z )
	local proj = direction*cpml.vec3.dot( rAxis, direction )
	local twist = cpml.quat( proj.x, proj.y, proj.z, rotation.w )
	if cpml.quat.len(twist) < 1e-9 then
		twist = rotation
	end
	local twist = cpml.quat.normalize( twist )
	local swing = rotation * cpml.quat.conjugate( twist )
	return swing, twist
end

function findPerpendicular( vec )
	local p = cpml.vec3(0,0,0)
	if vec.x ~= 0 then
		p.y = vec.x
		p.x = -vec.y
	elseif vec.y ~= 0 then
		p.x = vec.y
		p.y = -vec.x
	elseif vec.z ~= 0 then
		p.x = vec.z
		p.z = -vec.x
	end
	return p
	--return cpml.vec3.normalize( p )
end

function rotBetweenVecs( vec1, vec2, fallbackAxis )
	local rAxis = cpml.vec3.cross( cpml.vec3.normalize(vec1), cpml.vec3.normalize(vec2) )

	local l1 = cpml.vec3.len( vec1 )
	local l2 = cpml.vec3.len( vec2 )
	local dot = cpml.vec3.dot( vec1, vec2 )
	local ang = math.acos( dot/(l1*l2) )
	-- Check if vectors are parallel or anti-parallel:
	if ang == 0 then
		return cpml.quat.from_angle_axis( 0, cpml.vec3(1,0,0 ) )
	elseif math.abs( ang ) > math.pi - 1e-10 then
		if fallbackAxis and cpml.vec3.dot( vec1, fallbackAxis ) < 1e-10 then
			return cpml.quat.from_angle_axis( ang, fallbackAxis )
		else
			-- Compute a valid rotation axis
			local perpendicularAxis = findPerpendicular( vec1 )
			return cpml.quat.from_angle_axis( ang, perpendicularAxis )
		end
	end

	local w = math.sqrt((l1 ^ 2) * (l2 ^ 2)) + dot
	local q = cpml.quat( rAxis.x, rAxis.y, rAxis.z, w )
	return cpml.quat.normalize( q )
end

function angBetweenVecs( vec1, vec2, up )
	local l1 = cpml.vec3.len( vec1 )
	local l2 = cpml.vec3.len( vec2 )
	local ang = math.acos( cpml.vec3.dot( vec1,vec2 )/(l1*l2) )
	-- If no "up" direction is given, simply return the angle (will always be positive)
	if up == nil then
		return ang
	end
	local cross = cpml.vec3.cross( vec1, vec2 )
	-- Check if the cross product is "facing upwards" or "downwards":
	if cpml.vec3.dist( up, cross ) < cpml.vec3.dist( up, -cross ) then
		return -ang
	else
		return ang
	end
end

function toAngleAxis( q )
	local ang, axis = cpml.quat.to_angle_axis( q )
	if cpml.vec3.len( axis ) < 0.9999 then
		axis = cpml.vec3(1,0,0)
		ang = 0
	end
	return ang, axis
end

-- Deep copy a table:
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function test()
	print("Testing angBetweenVecs...")
	eps = 1e-10
	for i=0,100 do
		ang = math.cos(i/100*2*math.pi)
		vec = cpml.vec3( math.cos(ang), math.sin(ang), 0 )
		dAng = angBetweenVecs( cpml.vec3(1,0,0), vec, cpml.vec3(0,0,-1) )
		--print(ang, dAng, vec)
		assert( ang < dAng + eps and ang > dAng - eps, "Invalid angBetweenVecs " .. ang .. " " .. dAng .. " " .. tostring(vec) )
	end

	ang = math.pi
	dAng = angBetweenVecs( cpml.vec3(1,0,0), cpml.vec3(-1,0,0), cpml.vec3(0,0,1) )
	assert( ang < dAng + eps and ang > dAng - eps, "Invalid angBetweenVecs " .. ang .. " " .. dAng .. " " .. tostring(vec) )
	print("Test passed.")

	print("Testing rotBetweenVecs...")
	local rr = rotBetweenVecs( cpml.vec3(1,0,0), cpml.vec3(-1,0,0) )
	print(rr, cpml.quat.to_angle_axis(rr))
	print(rr, toAngleAxis(rr))
end
test()


