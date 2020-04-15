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
