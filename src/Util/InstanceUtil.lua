--[==[

	[InstanceUtil.lua]:
		Utility functions specifically for instances.

	[Author(s)]:
		- Vyon (https://github.com/Vyon)

]==]

-- Modules:
local Types = require(script.Parent.Parent:FindFirstChild("Types.d"))

-- Types:
type Dictionary<T> = Types.Dictionary<T>

--[=[
	@class InstanceUtil
	Utility functions specifically for instances.
]=]
local InstanceUtil = {}

--[=[
	@within InstanceUtil
	@function HasProperty
	Checks if an instance has a property.

	@param Instance Instance
	@param Property string

	@return boolean
]=]
function InstanceUtil.HasProperty(Instance: Instance, Property: string): boolean
	local Success = pcall(function()
		return Instance[Property]
	end)

	return Success
end

--[=[
	@within InstanceUtil
	@function SetProperty
	Sets a property on an instance if it exists.

	@param Instance Instance
	@param Property string
	@param Value any

	@return nil
]=]
function InstanceUtil.SetProperty(Instance: Instance, Property: string, NewValue: any)
	local HasProperty = InstanceUtil.HasProperty(Instance, Property)

	if not HasProperty then
		return
	end

	local CurrentValue = Instance[Property]

	if typeof(CurrentValue) ~= typeof(NewValue) then
		return
	end

	local Success = pcall(function()
		Instance[Property] = NewValue
	end)

	if Success then
		return
	end

	warn(`[Flux.InstanceUtil]: Failed to set property {Property} on instance {Instance.Name}.`)
end

--[=[
	@within InstanceUtil
	@function Create
	Creates instances based on the structure of the template.

	@param Template Dictionary<any> & { Children: Dictionary<any>? }

	@return Instance
]=]
function InstanceUtil.Create(Template: Dictionary<any> & { Children: Dictionary<any>? }): Instance
	local Instance = Instance.new(Template.ClassName)

	for Property, Value in Template :: any do
		if Property == "ClassName" then
			continue
		end

		if Property == "Children" and typeof(Value) == "table" then
			for _, ChildTemplate in Value do
				local Child = InstanceUtil.Create(ChildTemplate)
				Child.Parent = Instance
			end

			continue
		end

		if not InstanceUtil.HasProperty(Instance, Property) then
			continue
		end

		InstanceUtil.SetProperty(Instance, Property, Value)
	end

	return Instance
end

return InstanceUtil
