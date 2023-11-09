--[==[

	[PromiseProxy.lua]:
		Wrapper for evaera's Promise library to give the promise typing and replacing camelCase with PascalCase.

	[Author(s)]:
		- Vyon (https://github.com/Vyon)

]==]

-- Folders:
local Packages = script.Parent.Packages

-- Modules:
local Promise = require(Packages.Promise)
local Types = require(script.Parent:FindFirstChild("Types.d"))

-- Types:
--[=[
	@within PromiseProxy
	@type Promise<T> { Await: () -> T, Then: (Callback: (T) -> ()) -> (), Catch: (Callback: (string) -> ()) -> () }
	Fixes the lack of any typing for evaera's Promise library.
]=]
type Promise<T> = Types.Promise<T>

--[=[
	@class PromiseProxy
	Wrapper for evaera's Promise library to give the promise typing and removing camelCase.
]=]
local PromiseProxy = {}

--[=[
	@within PromiseProxy
	@function async
	Creates proxy promise to mimic specific methods of a promise.

	@param Handler (Resolve: (T) -> (), Reject: (any) -> ()) -> ()

	@return Promise<T>
]=]
function PromiseProxy.async<T>(Handler: (Resolve: (T) -> (), Reject: (any) -> ()) -> ())
	local NewPromise = Promise.async(Handler)

	local function Await<T>(self: Promise<T>)
		return NewPromise:await()
	end

	local function Then<T>(self: Promise<T>, Callback: (T) -> ())
		NewPromise:andThen(Callback)
		return self
	end

	local function Catch(self: Promise<T>, Callback: (string) -> ())
		NewPromise:catch(Callback)
		return self
	end

	local Promise: Promise<T> = {
		Await = Await,
		Then = Then,
		Catch = Catch,
	}

	return Promise
end

return PromiseProxy
