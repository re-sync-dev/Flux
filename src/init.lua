--[==[

	[init.lua]:
		Flux is a DataStore wrapper with a focus on extensibility and easy modification to fit developer needs.

	[Author(s)]:
		- Vyon (https://github.com/Vyon)

]==]

-- Services:
local DataStoreService = game:GetService("DataStoreService")

-- Modules:
local FluxStore = require(script.FluxStore)
local Types = require(script:FindFirstChild("Types.d"))

-- Types:
--[=[
	@within Flux
	@type StoreOptions { StoreType: StoreType, AutoSave: boolean, AutoSaveInterval: number, FetchTimeout: number, Retries: number, RetryDelay: number, IsPlayerData: boolean, Reconcile: boolean }
]=]
export type StoreOptions = Types.StoreOptions

--[=[
	@within Flux
	@type FluxData<T> { Key: string, Data: T, Options: StoreOptions, Store: FluxStore<T>, Loaded: boolean, Unloading: boolean, Locked: boolean, new: (Store: FluxStore<T>, Key: string, Options: StoreOptions) -> FluxData<T>, SaveAsync: (self: FluxData<T>) -> (), UnloadAsync: (self: FluxData<T>) -> (), Get: (self: FluxData<T>, Key: string) -> any, Set: (self: FluxData<T>, Key: string, Value: any) -> (), Remove: (self: FluxData<T>, Key: string) -> (), _Reconcile: (self: FluxData<T>) -> boolean }
]=]
export type FluxData<T> = Types.FluxData<T>

--[=[
	@within Flux
	@type FluxStore<T> { Name: string, Template: T, Options: StoreOptions, Sessions: Dictionary<FluxData<T>>, NextAutoSave: number, DataStores: Dictionary<DataStore>, DataLocation: Folder?, AutoSaveStart: Signal<() -> ()>, AutoSaveEnd: Signal<() -> ()>, AutoSaveFailed: Signal<(string) -> ()>, new: (Name: string, Template: T, Options: StoreOptions) -> FluxStore<T>, GetAsync: (self: FluxStore<T>, Key: string) -> FluxData<T>, LoadAsync: (self: FluxStore<T>, Key: string) -> FluxData<T>, SaveAsync: (self: FluxStore<T>, Key: string) -> (), UnloadAsync: (self: FluxStore<T>, Key: string) -> (), OnLoaded: (Key: string) -> () }
]=]
export type FluxStore<T> = Types.FluxStore<T>

-- Functions:
local function IsAPIAccessEnabled()
	local Success, Result = pcall(function()
		return DataStoreService:GetDataStore("__FLUX_TEST")
	end)

	return Success and Result ~= nil
end

-- Variables:
local CanAccessAPI = IsAPIAccessEnabled()

--[=[
	@class Flux
	@tag Server
	DataStore wrapper with a focus on extensibility and easy modification to fit developer needs.
]=]
local Flux = {}

--[=[
	@within Flux
	@prop Stores Dictionary<FluxStore<T>>
]=]
Flux.Stores = {}

--[=[
	@within Flux
	@method GetStore
	Retrieves a FluxStore and then loads it if it hasn't been loaded yet.

	@param Name string
	@param Template T
	@param Options StoreOptions?

	@return FluxStore<T>
]=]
function Flux:GetStore<T>(Name: string, Template: T, Options: StoreOptions?): FluxStore<T>
	local WillForceMock = false

	if game.GameId == 0 or not CanAccessAPI then
		WillForceMock = true
		warn(`[FluxStore({Name})]: Game is not published, switched to mock data.`)
	end

	local ProxiedOptions = Options or {}

	ProxiedOptions.IsMock = WillForceMock or ProxiedOptions.IsMock or false

	if not self.Stores[Name] then
		self.Stores[Name] = FluxStore.new(Name, Template, ProxiedOptions)
	end

	return self.Stores[Name]
end

if game.GameId == 0 or not CanAccessAPI then
	warn("[Flux]: Flux has loaded, data will not be saved.")
else
	print("[Flux]: Flux has loaded, data will be saved.")
end

return Flux
