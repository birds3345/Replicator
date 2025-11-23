local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local types = require(script.Parent.Parent.types)

local server = {}

local replicatorRemote: RemoteEvent? = nil
function server.sendEvent<T, U...>(state: types.State<T>, targets: {Player}?, action: string, ...: U...)
	-- this should never be nil
	if not replicatorRemote then return end

	if not targets then
		local eventTargets = if state._allPlayers then Players:GetPlayers() else state._targets
		for _, target in eventTargets do
			replicatorRemote:FireClient(target, state._name, action, ...)
		end

		return
	end

	for _, target in targets do
		if table.find(state._targets, target) then
			continue
		end

		replicatorRemote:FireClient(target, state._name, action, ...)
	end
end

function server.init()
	local remote = Instance.new("RemoteEvent")
	remote.Name = "ReplicatorRemote"
	remote.Parent = ReplicatedStorage

	replicatorRemote = remote
end

return server
