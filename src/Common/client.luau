local ReplicatedStorage = game:GetService("ReplicatedStorage")

local State = require(script.Parent.Parent.State.State)

local stateMap = require(script.Parent.Parent.State.stateMap)

local client = {}

function client.init()
	local replicatorRemote: RemoteEvent = ReplicatedStorage:WaitForChild("ReplicatorRemote")

	replicatorRemote.OnClientEvent:Connect(function(name: string, action: string, ...)
		if action == "New" then
			if stateMap.exists(name) then
				warn(`Server made a duplicate state "{name}". Call {name}:destroy() before creating a state with the same name.`)
			end

			local state = State.new(name, ...)
			stateMap.bind(state)

		elseif action == "Set" then
			if not stateMap.exists(name) then return end

			local path: string, value: any = ...

			local state = stateMap.get(name)
			state:_setImpl(path, value)

		elseif action == "Destroy" then
			if not stateMap.exists(name) then return end

			stateMap.get(name).destroyed:fire()
			stateMap.unbind(name)

		end
	end)
end

return client
