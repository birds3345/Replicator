local Signal = {}
local SignalMeta = { __index = Signal }

function Signal.connect<T...>(self: Signal<T...>, func: (T...) -> ()): Connection
	local connections = self._connections
	table.insert(connections, func)
	
    local disconnected = false
	return {
		disconnect = function(self: Connection)
            if disconnected then return end
            disconnected = true

			table.remove(connections, table.find(connections, func))
		end;
	}
end

function Signal.once<T...>(self: Signal<T...>, func: (T...) -> ()): Connection
	local connection: Connection
    connection = self:connect(function(...: T...)
		connection:disconnect()
		func(...)
	end)

    return connection
end

function Signal.wait<T...>(self: Signal<T...>): (T...)
	local current = coroutine.running()
	
	local connection: Connection
    connection = self:connect(function(...: T...)
		task.spawn(current, ...)
		
		connection:disconnect()
	end)
	
	return coroutine.yield()
end

function Signal.fire<T...>(self: Signal<T...>, ...: T...): ()
	for _, connection in self._connections do
		task.spawn(connection, ...)
	end
end

function Signal.new<T...>(): Signal<T...>
	return setmetatable({
		_connections = {},
	}, SignalMeta) :: any
end

export type Signal<T...> = {
    _connections: { (T...) -> () },
    connect: (self: Signal<T...>, func: (T...) -> ()) -> Connection,
    once: (self: Signal<T...>, func: (T...) -> ()) -> Connection,
    wait: (self: Signal<T...>) -> T...,
    fire: (self: Signal<T...>, T...) -> (),
}

export type Connection = {
    disconnect: (Connection) -> (),
}

return Signal
