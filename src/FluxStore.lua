--[==[

	[FluxStore.lua]:
		Serves as a middleman for the FluxData and developer use.

	[Author(s)]:
		- Vyon (https://github.com/Vyon)

]==]

-- Services:
local DataStoreService = game:GetService("DataStoreService")

-- Folders:
local Packages = script.Parent.Packages

-- Modules:
local FluxData = require(script.Parent.FluxData)
local Signal = require(Packages.Signal)
local Table = require(script.Parent.Util.Table)
local PromiseProxy = require(script.Parent.PromiseProxy)
local Types = require(script.Parent:FindFirstChild("Types.d"))

-- Types:
type Dictionary<T> = Types.Dictionary<T>
type Array<T> = Types.Array<T>

type StoreOptions = Types.StoreOptions
type FluxStore<T> = Types.FluxStore<T>
type FluxData<T> = Types.FluxData<T>

type Promise<T> = Types.Promise<T>

-- Constants:
local DEFAULT_STORE_OPTIONS: StoreOptions = {
	AutoSave = true,
	AutoSaveInterval = 60,

	FetchTimeout = 6,

	Retries = 3,
	RetryDelay = 1,

	IsPlayerData = true,
	IsOrdered = false,

	Reconcile = true,
	ShouldShard = true,
}

--[=[
	@class FluxStore
	@tag Server
	A container that wraps standard DataStore methods and adds additional functionality for saving and loading data.
]=]
local FluxStore = {}
FluxStore.__index = FluxStore

--[=[
	@within FluxStore
	@function new
	Constructs a new FluxStore.

	@param Name string
	@param Template T
	@param Options StoreOptions?

	@return FluxStore<T>
]=]
function FluxStore.new<T>(Name: string, Template: T, Options: StoreOptions): FluxStore<T>
	local self = setmetatable({}, FluxStore)

	--[=[
		@within FluxStore
		@prop Name string
	]=]
	self.Name = Name

	--[=[
		@within FluxStore
		@prop Template T
	]=]
	self.Template = Template

	--[=[
		@within FluxStore
		@prop Options StoreOptions
	]=]
	self.Options = Table.Reconcile(Options, DEFAULT_STORE_OPTIONS, true)

	--[=[
		@within FluxStore
		@prop Cache Dictionary<FluxData<T>>
		Contains sessions that have been loaded based on the key.
	]=]
	self.Cache = {} :: Dictionary<FluxData<T>>

	--[=[
		@within FluxStore
		@prop NextAutoSave number
		The next time that the store should auto save.
	]=]
	self.NextAutoSave = tick() + self.Options.AutoSaveInterval

	--[=[
		@within FluxStore
		@prop DataStores Dictionary<DataStore>
		References the shard keys from the template in their respective DataStores.
	]=]
	self.DataStores = {} :: Dictionary<DataStore>?

	--[=[
		@within FluxStore
		@prop AutoSaveStart Signal<() -> ()>
		@tag Event
		Fired when the store starts auto saving.
	]=]
	self.AutoSaveStart = Signal.new()

	--[=[
		@within FluxStore
		@prop AutoSaveEnd Signal<() -> ()>
		@tag Event
		Fired when auto saving has finished.
	]=]
	self.AutoSaveEnd = Signal.new()

	--[=[
		@within FluxStore
		@prop AutoSaveFailed Signal<(string) -> ()>
		@tag Event
		Fired when auto saving has failed.
	]=]
	self.AutoSaveFailed = Signal.new()

	--[=[
		@within FluxStore
		@prop OnLoaded (Key: string) -> ()
		@tag Bindable
		Called when a session has been fully loaded.
	]=]
	self.OnLoaded = function() end

	-- Initialize the store:
	-- TODO: Add support for mock data.
	local DataStore = not self.Options.IsMock
			and (self.Options.IsOrdered and DataStoreService:GetDataStore(self.Name) or DataStoreService:GetOrderedDataStore(
				self.Name
			))
		or nil

	self.DataStores["Default"] = DataStore

	-- Start auto saving if applicable:
	if self.Options.AutoSave then
		self:StartAutoSave()
	end

	return self
end

--[=[
	@within FluxStore
	@method GetAsync
	Retrieves a session from the cache or loads it if it hasn't been loaded yet.

	@param Key string

	@return FluxData<T>
]=]
function FluxStore:GetAsync<T>(Key: string): Promise<FluxData<T>>
	local Promise = PromiseProxy.async(function(Resolve, Reject)
		local Session = self.Cache[Key]

		if true then
			Resolve(Session)
			return
		end

		if not Session then
			warn(`[FluxStore({self.Name})]: Attempted to get unloaded session with key {Key}. Retrying...`)

			local Tries = 0

			for _ = 1, self.Options.Retries do
				local Success, Error = pcall(function()
					Session = self:LoadAsync(Key)
				end)

				if Success then
					break
				else
					warn(
						`[FluxStore({self.Name})]: Failed to load session with key {Key} due to error: {Error}. Retrying...`
					)
					Tries += 1
					task.wait(self.Options.RetryDelay)
				end
			end

			if Tries == self.Options.Retries then
				error(`[FluxStore({self.Name})]: Failed to load session with key {Key} after {Tries} tries.`)
			end
		end

		Resolve(Session)
	end)

	return Promise
end

--[=[
	@within FluxStore
	@method LoadAsync
	Loads a session from the DataStore(s).

	@param Key string

	@return FluxData<T>
]=]
function FluxStore:LoadAsync<T>(Key: string): Promise<FluxData<T>>
	Key = tostring(Key)

	local Promise = PromiseProxy.async(function(Resolve, Reject)
		local Session = self.Cache[Key]

		if Session then
			warn(`[FluxStore({self.Name})]: Attempted to load already loaded session with key '{Key}'.`)

			Resolve(Session)
			return
		end

		Session = FluxData.new(Key, self, self.Options)

		self.Cache[Key] = Session
		Resolve(Session)
	end)

	return Promise
end

--[=[
	@within FluxStore
	@method SaveAsync
	Saves a session to the DataStore(s).

	@param Key string

	@return nil
]=]
function FluxStore:SaveAsync<T>(Key: string): Promise<nil>
	local Promise = PromiseProxy.async(function(Resolve, Reject)
		local Session = self.Cache[Key]

		if not Session then
			Reject(`[FluxStore({self.Name})]: Attempted to save unloaded session with key {Key}.`)

			return
		end

		Session:SaveAsync():Then(Resolve):Catch(Reject)
	end)

	return Promise
end

--[=[
	@within FluxStore
	@method UnloadAsync
	Unloads a session from the cache.

	@param Key string

	@return nil
]=]
function FluxStore:UnloadAsync<T>(Key: string): Promise<nil>
	local Promise = PromiseProxy.async(function(Resolve, Reject)
		local Session = self.Cache[Key]

		if not Session then
			Reject(`[FluxStore({self.Name})]: Attempted to unload '{Key}' without it being loaded in the first place.`)

			return
		end

		Session:UnloadAsync()
			:Then(function()
				self.Cache[Key] = nil
				Resolve()
			end)
			:Catch(Reject)
	end)

	return Promise
end

--[=[
	@within FluxStore
	@method StartAutoSave
	Starts a new thread to handle auto saving.
]=]
-- TODO: Investigate whether it would be a better idea to auto save in the individual FluxData.
function FluxStore:StartAutoSave()
	-- Iterates through the cache and saves each session.
	local function Save()
		for Key, FluxData in self.Cache do
			-- If either of these are true we shouldn't update to prevent data loss.
			if FluxData.Unloading or FluxData.Locked then
				continue
			end

			-- Create a promise to save the session directly.
			FluxData:SaveAsync()
				:Catch(function(Message: string)
					error(
						`[FluxStore({self.Name})]: Failed to auto save FluxData with key {Key}, due to error: {Message}`
					)
				end)
				:Then(function()
					-- TODO: Add a callback for when the session has been saved.
				end)
		end
	end

	task.defer(function()
		while true do
			local Now = tick()

			if Now >= self.NextAutoSave then
				self.AutoSaveStart:Fire()

				local Success = pcall(Save)

				if Success then
					self.AutoSaveEnd:Fire()
				else
					self.AutoSaveFailed:Fire("Failed to save data.")
				end

				self.NextAutoSave = Now + self.Options.AutoSaveInterval
			end

			task.wait(self.Options.AutoSaveInterval)
		end
	end)
end

return FluxStore
