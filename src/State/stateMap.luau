-- a name to state map used exclusively for the client

local Signal = require(script.Parent.Parent.Common.Signal)

local types = require(script.Parent.Parent.types)

type State = types.State

local stateMap = {
	_states = {} :: {[string]: State},
	_createdState = Signal.new() :: Signal.Signal<string>,
}

function stateMap.bind(state: State)
	stateMap._states[state._name] = state
	stateMap._createdState:fire(state._name)
end

function stateMap.unbind(name: string)
	stateMap._states[name] = nil
end

function stateMap.get(name: string): State
	return stateMap._states[name]
end

function stateMap.exists(name: string): boolean
	return stateMap._states[name] ~= nil
end

return stateMap
