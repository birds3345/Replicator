local stateMap = require(script.Parent.stateMap)

local types = require(script.Parent.Parent.types)

return function(name: string, doNotYield: boolean?): types.PubState
	if not doNotYield and not stateMap.exists(name) then
		while true do
			local created = stateMap._createdState:wait()
			if created == name then
				return stateMap.get(name)
			end
		end
	end

	return stateMap.get(name)
end
