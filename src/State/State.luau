--!nolint LocalShadow

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Signal = require(script.Parent.Parent.Common.Signal)

local server = require(script.Parent.Parent.Common.server)
local types = require(script.Parent.Parent.types)
local stateMap = require(script.Parent.stateMap)

type State = types.State

local runContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

local State = {}
local StateMeta = { __index = State }

local function verifyPath(path: string, data: {[any]: any})
	local components = string.split(path, ".")
	assert(#components > 0, "Path is empty")

	for i = 1, #components - 1 do
		local component = components[i]

		local nextTable = data[component]
		assert(nextTable, `Path component "{components[i]}" doesn't exist`)
		assert(typeof(nextTable) == "table", `Path component "{components[i]}" is not a table`)

		data = nextTable
	end
end

function State.set<T>(self: State, path: string, value: T)
	assert(runContext == "server", "State:set can only be ran on the server")

	self:_setImpl(path, value)

	server.sendEvent(self, nil, "Set", path, value)
end

function State._setImpl<T>(self: State, path: string, value: T)
	local function fireAll(tree: types.SignalTree, data: {[any]: any}?, fire: boolean)
		if fire and tree.signal then
			tree.signal:fire(data)
		end

		for key, child in tree.tree do
			fireAll(child, if data and data[key] then data[key] else nil, true)
		end
	end

	if path == "" then
		self.data = value

		fireAll(self._pathChangedSignals, self.data, true)
		return
	end

	verifyPath(path, self.data)

	local components = string.split(path, ".")
	local current = self.data
	for i = 1, #components - 1 do
		local nextTable = current[components[i]]
		current = nextTable
	end

	current[components[#components]] = value

	local currentTree = self._pathChangedSignals
	local currentData = self.data

	if currentTree.signal then
		currentTree.signal:fire(currentData)
	end

	for _, component in components do
		if not currentTree.tree[component] then
			break
		end

		currentTree = currentTree.tree[component]
		currentData = currentData[component]

		if currentTree.signal then
			currentTree.signal:fire(currentData)
		end
	end

	fireAll(currentTree, currentData, false)
end

function State.setReplicationTargets(self: State, targets: {Player})
	assert(runContext == "server", "State:setReplicationTargets can only be ran on the server")

	server.sendEvent(self, targets, "New", self.data)

	self._targets = table.clone(targets)
end

function State.setReplicationTargetsAllPlayers(self: State, allPlayers: boolean)
	assert(runContext == "server", "State:setReplicationTargetsAllPlayers can only be ran on the server")

	if allPlayers == self._allPlayers then return end

	self._allPlayers = allPlayers

	server.sendEvent(self, Players:GetPlayers(), "New", self.data)

	if allPlayers then
		self._playerAddedConnection = Players.PlayerAdded:Connect(function(player: Player)
			server.sendEvent(self, {player}, "New", self.data)
		end)

	elseif self._playerAddedConnection then
		self._playerAddedConnection:Disconnect()
		self._playerAddedConnection = nil
	end
end

function State.getPathChangedSignal<T>(self: State, path: string): Signal.Signal<T>
	local components = string.split(path, ".")

	local current = self._pathChangedSignals
	for _, component in components do
		-- allows for signals bound to the root
		if #components == 1 and component == "" then continue end

		if not current.tree[component] then
			current.tree[component] = {
				tree = {}
			}
		end

		current = current.tree[component]
	end

	if not current.signal then
		current.signal = Signal.new()
	end

	return current.signal :: any
end

function State.getName(self: State)
	return self._name
end

function State.destroy(self: State)
	assert(runContext == "server", "State:destroy can only be called on the server")

	server.sendEvent(self, nil, "Destroy")

	self.destroyed:fire()
end

function State.new(name: string, data: any?): State
	return setmetatable({
		data = data or {},
		destroyed = Signal.new(),

		_targets = {},
		_allPlayers = false,
		_playerAddedConnection = nil,
		_pathChangedSignals = {
			tree = {},
		},

		_name = name,
	}, StateMeta) :: any
end

return State
