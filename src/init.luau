local RunService = game:GetService("RunService")

local client = require(script.Common.client)
local server = require(script.Common.server)

local getState = require(script.State.getState)
local newState = require(script.State.newState)
local stateExists = require(script.State.stateExists)

local types = require(script.types)

if RunService:IsServer() then
	server.init()
else
	client.init()
end

export type State<T = {[any]: any}> = types.PubState<T>

return {
	newState = newState,
	getState = getState,
	stateExists = stateExists,
}
