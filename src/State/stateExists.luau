local stateMap = require(script.Parent.stateMap)

return function(name: string): boolean
	return stateMap.exists(name)
end
