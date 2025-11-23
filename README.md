# Replicator
A server to client state replication library.

Example:
```luau
-- server
local Replicator = require(path.to.Replicator)

local state = Replicator.newState("State", {
  a = 1,
  b = {
    c = 3,
  },
})

-- replicate the state to all players
state:setReplicationTargetsAllPlayers(true)

state:set("b.c", 5)

-- client
local Replicator = require(path.to.Replicator)

-- yields until the server sends the state
local state = Replicator.getState("State")

print(state.data.a)

state:getPathChangedSignal("b.c"):connect(function(newValue: number)
  print(newValue)
end)

state.destroyed:connect(function()
  print("destroyed!")
end)
```
