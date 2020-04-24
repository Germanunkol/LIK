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

function rotBetweenVecs( vec1, vec2 )
	local rAxis = cpml.vec3.cross( cpml.vec3.normalize(vec1), cpml.vec3.normalize(vec2) )

	-- Check if vectors were parallel:
	if cpml.vec3.len2( rAxis ) == 0 then
		return cpml.quat.from_angle_axis( 0, cpml.vec3(1,0,0 ) )
	end

	local w = math.sqrt((cpml.vec3.len(vec1) ^ 2) * (cpml.vec3.len(vec2) ^ 2)) + cpml.vec3.dot(vec1, vec2);
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


