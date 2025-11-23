local State = require(script.Parent.State)

local types = require(script.Parent.Parent.types)

return function<T>(name: string, data: T): types.PubState<T>
	return State.new(name, data) :: any
end
