local Signal = require(script.Parent.Common.Signal)

export type PubState<T = any> = {
	data: T,

	destroyed: Signal.Signal<>,

	set: <U>(self: PubState<T>, path: string, value: U) -> (),
	setReplicationTargets: (self: PubState<T>, targets: {Player}) -> (),
	setReplicationTargetsAllPlayers: (self: PubState<T>, allPlayers: boolean) -> (),
	getName: (self: PubState<T>) -> string,
	getPathChangedSignal: <U>(self: PubState<T>, path: string) -> Signal.Signal<U>,
	destroy: (self: PubState<T>) -> (),
}

export type SignalTree = {
	signal: Signal.Signal<any>?,
	tree: {
		[string]: SignalTree,
	},
}

export type State<T = any> = {
	_setImpl: <U>(self: State<T>, path: string, value: U) -> (),

	_targets: {Player},
	_allPlayers: boolean,
	_playerAddedConnection: RBXScriptConnection?,
	_name: string,
	_pathChangedSignals: SignalTree,
} & PubState<T>

return nil
