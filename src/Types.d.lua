--[==[

	[Types.d.lua]:
		Contains all static types for the module.

	[Author(s)]:
		- Vyon (https://github.com/Vyon)

]==]

-- Types:
-- Private Types:
type Connection = {
	Disconnect: (self: Connection) -> (),
	Destroy: (self: Connection) -> (),
	Connected: boolean,
}

type Signal<T...> = {
	Fire: (self: Signal<T...>, T...) -> (),
	FireDeferred: (self: Signal<T...>, T...) -> (),
	Connect: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	DisconnectAll: (self: Signal<T...>) -> (),
	GetConnections: (self: Signal<T...>) -> { Connection },
	Destroy: (self: Signal<T...>) -> (),
	Wait: (self: Signal<T...>) -> T...,
}

-- Exported Types:
export type Array<T> = { T }
export type Dictionary<T> = { [string]: T }
export type GenericTable = { [any]: any }

export type StoreOptions = {
	IsMock: boolean?,

	AutoSave: boolean?,
	AutoSaveInterval: number?,

	FetchTimeout: number?,

	Retries: number?,
	RetryDelay: number?,

	IsPlayerData: boolean?, -- Is this for specifically PlayerData?
	IsOrdered: boolean?, -- Is this an ordered data store?

	Reconcile: boolean?, -- Should we reconcile data?
	ShouldShard: boolean?, -- Should we shard data?

	-- TODO: Add providers & provider options.
}

export type FluxData<T> = {
	Key: string,
	Data: T,
	SessionId: string,
	LoadedAt: number,
	_Options: StoreOptions,
	_Store: FluxStore<T>,

	_UserIds: Array<number>,

	-- States:
	Loaded: boolean,
	Unloading: boolean,
	Locked: boolean,

	-- Events:
	OnLocked: Signal<(boolean) -> ()>,

	-- Methods:
	new: (Store: FluxStore<T>, Key: string, Options: StoreOptions) -> FluxData<T>,
	SaveAsync: (self: FluxData<T>) -> Promise<nil>,
	UnloadAsync: (self: FluxData<T>) -> Promise<nil>,

	AddUserIds: (self: FluxData<T>, ...number) -> (),
	RemoveUserIds: (self: FluxData<T>, ...number) -> (),

	-- Private Methods:
	_LoadAsync: (self: FluxData<T>) -> Promise<FluxData<T>?>, -- Pretty much serves as an initializer.
	_Reconcile: (self: FluxData<T>) -> (),
	_StartSessionLockRenewer: (self: FluxData<T>) -> (),
}

export type FluxStore<T> = {
	Name: string,
	Template: T,
	Options: StoreOptions,
	Cache: Dictionary<FluxData<T>>,
	NextAutoSave: number,
	DataStores: Dictionary<DataStore>,

	-- Events:
	AutoSaveStart: Signal<() -> ()>,
	AutoSaveEnd: Signal<() -> ()>,
	AutoSaveFailed: Signal<(string) -> ()>,

	-- Methods:
	new: (Name: string, Template: T, Options: StoreOptions) -> FluxStore<T>,
	GetAsync: (self: FluxStore<T>, Key: string) -> Promise<FluxData<T>?>,
	LoadAsync: (self: FluxStore<T>, Key: string) -> Promise<FluxData<T>?>,
	SaveAsync: (self: FluxStore<T>, Key: string) -> Promise<nil>,
	UnloadAsync: (self: FluxStore<T>, Key: string) -> Promise<nil>,

	StartAutoSave: (self: FluxStore<T>) -> (),

	-- Bindable Functions:
	OnLoaded: (Key: string) -> (),
}

export type Promise<T> = {
	Await: (self: Promise<T>) -> T,
	Then: (self: Promise<T>, Callback: (T) -> ()) -> Promise<T>,
	Catch: (self: Promise<T>, Callback: (string) -> ()) -> Promise<T>,
}

return {}
