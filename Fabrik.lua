Fabrik = {}

function Fabrik.solve( chain, targetPos, maxIterations, debugSteps )

	basePos = chain[1]:getPos()

	debugSteps = debugSteps or math.huge

	for i=1,maxIterations do
		
		-- Forward pass:
		chain[#chain]:setPos( targetPos )
		for j=#chain,1,-1 do
			curBone = chain[j]
		end



		-- Backward pass:


	end
end

return Fabrik
