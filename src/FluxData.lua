--[==[

	[FluxData.lua]:
		Represents a entry in a FluxStore cache. It is compatible with both player and general data.

	[Author(s)]:
		- Vyon (https://github.com/Vyon)

]==]

-- Services:
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")

-- Modules:
local Constants = require(script.Parent.Constants)
local Table = require(script.Parent.Util.Table)
local String = require(script.Parent.Util.String)
local PromiseProxy = require(script.Parent.PromiseProxy)
local Types = require(script.Parent:FindFirstChild("Types.d"))

-- Types:
type Array<T> = Types.Array<T>
type Dictionary<T> = Types.Dictionary<T>
type GenericTable = Types.GenericTable

type StoreOptions = Types.StoreOptions
type FluxData<T> = Types.FluxData<T>
type FluxStore<T> = Types.FluxStore<T>

type Promise<T> = Types.Promise<T>

-- Variables:
local SessionLock = game.GameId ~= 0 and MemoryStoreService:GetHashMap(Constants.SESSION_LOCK_NAME) or nil

--[=[
	@class FluxData
	@tag Server
	Represents an entry in a FluxStore. This represents multiple types of data, such as player data, general data, etc.
]=]
local FluxData = {}
FluxData.__index = FluxData

--[=[
	@within FluxData
	@function new
	Constructs a new FluxData object.

	@param Key string
	@param Store FluxStore<T>
	@param Options StoreOptions?

	@return FluxData<T>
]=]
function FluxData.new<T>(Key: string, Store: FluxStore<T>, Options: StoreOptions): FluxData<T>
	local self = setmetatable({}, FluxData)

	--[=[
		@within FluxData
		@prop Key string

		The key that allows us to get and set data from the DataStore.
	]=]
	self.Key = Key

	--[=[
		@within FluxData
		@prop Data T

		The data that is stored in the DataStore.
	]=]
	self.Data = {}

	--[=[
		@within FluxData
		@prop SessionId string

		The session ID that can be used to identify the current session. This can only used for player data.
	]=]
	self.SessionId = String.Random(16)

	--[=[
		@within FluxData
		@prop LoadedAt number

		The time that the FluxData was created.
	]=]
	self.LoadedAt = 0

	--[=[
		@within FluxData
		@prop _Options StoreOptions
		@private

		Holds a copy of the options that were used to create the FluxStore.
	]=]
	self._Options = Store.Options

	--[=[
		@within FluxData
		@prop _Store FluxStore<T>
		@private

		Holds a reference to the FluxStore that this FluxData is a part of.
	]=]
	self._Store = Store

	--[=[
		@within FluxData
		@prop _UserIds Array<number>
		@private

		Holds a list of user IDs that are allowed to access the data. This only applies to player data.
	]=]
	self._UserIds = {} :: Array<number>

	--[=[
		@within FluxData
		@prop Loaded boolean
		@tag State

		Whether or not the data has been fully loaded from the DataStore.
	]=]
	self.Loaded = false

	--[=[
		@within FluxData
		@prop Unloading boolean
		@tag State

		Whether or not the data is currently being unloaded.
	]=]
	self.Unloading = false

	--[=[
		@within FluxData
		@prop Locked boolean
		@tag State

		Whether or not the FluxData can be accessed. This is only set to true after the data has been unloaded.
	]=]
	self.Locked = false

	--[=[
		@within FluxData
		@prop OnLocked Signal<(boolean) -> ()>
		@tag Event
		Fired when the FluxData is locked.
	]=]

	-- Load the data from the DataStore(s).
	self:_LoadAsync()
		:Catch(function(Message: string)
			warn(`[FluxData({self.Key})]: Failed to load data from: {self._Store.Name}, due to error: {Message}`)
		end)
		:Await()

	return self
end

--[=[
	@within FluxData
	@method SaveAsync

	Saves the data to the DataStore(s).

	@return Promise<nil>
]=]
function FluxData:SaveAsync<T>(): Promise<nil>
	return PromiseProxy.async(function(Resolve, Reject)
		local Options: StoreOptions = self._Options
		local Store: FluxStore<T> = self._Store

		local IsMock = Options.IsMock

		local DataStores = Store.DataStores

		-- There's no need to save if the data is of the mock variety:
		if IsMock then
			Resolve()
			return
		end

		local Success, Result = pcall(function()
			return DataStores["Default"]:SetAsync(self.Key, self.Data, self._UserIds)
		end)

		if not Success then
			Reject(`[FluxData({self.Key})]: Failed to save data due to error: {Result}`)
			return
		end

		Resolve()
	end)
end

--[=[
	@within FluxData
	@method UnloadAsync

	Unloads the data from the current session.

	@return Promise<nil>
]=]
function FluxData:UnloadAsync<T>(): Promise<nil>
	return PromiseProxy.async(function(Resolve, Reject)
		-- We do NOT want anything to happen to the data (aside from saving)
		-- so we update this to a sort of pre-locked state.
		self.Unloading = true

		self:SaveAsync()
			:Catch(function(Message: string)
				warn(`[FluxData({self.Key})]: Failed to save data due to error: {Message}`)
			end)
			:Await()

		self.Unloading = false
		self.Locked = true

		self.OnLocked:Fire()

		Resolve()
	end)
end

--[=[
	@within FluxData
	@method AddUserIds

	Pushes new user IDs to the list of user IDs that are allowed to access the data.

	@param ... number

	@return nil
]=]
function FluxData:AddUserIds(...: number)
	local UserIds = { ... }

	for _, UserId in UserIds do
		if table.find(self._UserIds, UserId) then
			continue
		end

		table.insert(self._UserIds, UserId)
	end
end

--[=[
	@within FluxData
	@method RemoveUserIds

	Removes user IDs from the list of user IDs that are allowed to access the data.

	@param ... number

	@return nil
]=]
function FluxData:RemoveUserIds(...: number)
	local UserIds = { ... }

	for _, UserId in UserIds do
		local Index = table.find(self._UserIds, UserId)

		if not Index then
			continue
		end

		table.remove(self._UserIds, Index)
	end
end

--[=[
	@within FluxData
	@method _LoadAsync
	@private

	Loads the data from the DataStore(s) and reconciles it with the template if applicable.

	@return Promise<nil>
]=]
function FluxData:_LoadAsync<T>(): Promise<any>
	return PromiseProxy.async(function(Resolve: (...any) -> (), Reject)
		local Options: StoreOptions = self._Options
		local Store: FluxStore<T> = self._Store

		local IsMock = Options.IsMock
		local IsPlayerData = Options.IsPlayerData

		local DataStores = Store.DataStores

		-- TODO: Add timeouts.
		-- TODO: Add data sharding.
		local Success, Result = pcall(function()
			return not IsMock and DataStores["Default"]:GetAsync(self.Key) or nil
		end)

		if not Success then
			Reject(`[FluxData({self.Key})]: Failed to load due to {Result}`)
			return
		end

		self.Data = Result or Table.Copy(self._Store.Template, true)

		if Options.Reconcile then
			self:_Reconcile()
		end

		-- Start trying to create a session lock if the FluxData is player data:
		if IsPlayerData then
			local OldSessionId = SessionLock and SessionLock:GetAsync(self.Key) or ""

			if OldSessionId == self.SessionId then
				warn(
					`[FluxData({self.Key})]: Fatal error: Session ID already exists. This should never happen and not be possible in any capacity. Please create an issue on the GitHub repository.`
				)

				Reject()
			end

			local IsLockSet = pcall(function()
				-- SessionLock can't be accessed if the game is unpublished or unsaved.
				if not SessionLock then
					return
				end

				SessionLock:SetAsync(self.Key, self.SessionId, Constants.SESSION_LOCK_TTL)
			end)

			if not IsLockSet then
				Reject(`[FluxData({self.Key})]: Failed to create session lock.`)
			end

			self:_StartSessionLockRenewer()
		end

		self.LoadedAt = os.time()
		self.Loaded = true

		local DidCallFinish, Error: any = pcall(Store.OnLoaded, self.Key)

		if not DidCallFinish then
			warn(`[FluxData({self.Key})]: The OnLoaded callback failed to run due to the following error: {Error}`)
		end

		Resolve()
	end)
end

--[=[
	@within FluxData
	@method _Reconcile
	@private

	Reconciles the data with the template.

	@return nil
]=]
function FluxData:_Reconcile()
	local Template = self._Store.Template
	local Data = self.Data

	Table.Reconcile(Data, Template, true)
end

--[=[
	@within FluxData
	@method _StartSessionLockRenewer
	@private

	Starts a loop that renews the session lock every 10 seconds.

	@return nil
]=]
function FluxData:_StartSessionLockRenewer()
	-- Safely attempts to kick the player to initiate UnloadAsync.
	-- We should be able to apply modifications to the data last minute
	-- without worry of it not existing because the SessionLock key expired.
	local function Kick()
		local UserIdMatch = string.match(self.Key, "%d+")
		local UserId = tonumber(UserIdMatch)

		-- If there is no UserId, we're just going to assume that it is not directly player data.
		if not UserId then
			return
		end

		local Player = Players:GetPlayerByUserId(UserId)

		if not Player then
			warn(`[FluxData({self.Key})]: Unable to find player with UserId {UserId}.`)

			return
		end

		Player:Kick("Your data has been been loaded elsewhere. If you believe this is a mistake, please rejoin.")
	end

	-- Create a new handler thread.
	task.defer(function()
		while not self.Locked do
			task.wait(Constants.SESSION_LOCK_RENEWAL_INTERVAL)

			local Success, Result = pcall(function()
				-- If the SessionLock was not present, it would most likely mean the game is unpublished / not saved.
				return SessionLock and SessionLock:GetAsync(self.Key) or self.SessionId
			end)

			if not Success then
				warn(`[FluxData({self.Key})]: Failed to renew session lock due to error: {Result}.`)

				self.Locked = true
				Kick()

				return
			end

			if Result ~= self.SessionId then
				warn(
					`[FluxData({self.Key})]: Session lock was stolen. To ensure data integrity, the session will be unloaded.`
				)

				self.Locked = true
				Kick()

				return
			end
		end
	end)
end

return FluxData
