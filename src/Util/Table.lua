--[==[

	[Table.lua]:
		Utility functions specifically for tables.

	[Author(s)]:
		- Vyon (https://github.com/Vyon)

]==]

-- Modules:
local Types = require(script.Parent.Parent:FindFirstChild("Types.d"))

-- Types:
type Dictionary<T> = Types.Dictionary<T>
type Array<T> = Types.Array<T>
type GenericTable = Types.GenericTable

--[=[
	@class Table
	@private

	Utility functions specifically for tables.
]=]
local Table = {}

--[=[
	@within Table
	@function Length

	Returns the true length of a table instead of differing between array and dictionary tables.

	@param TableToCheck GenericTable

	@return number
]=]
function Table.Length(TableToCheck: GenericTable): number
	local Length = 0

	for _ in TableToCheck do
		Length += 1
	end

	return Length
end

--[=[
	@within Table
	@function Keys

	Returns an array of keys from a table.

	@param Table GenericTable

	@return Array<any>
]=]
function Table.Keys(From: GenericTable): Array<any>
	local Keys: Array<any> = {}

	for Key in From do
		table.insert(Keys, Key)
	end

	return Keys
end

--[=[
	@within Table
	@function Values

	Returns an array of values from a table.

	@param Table GenericTable

	@return Array<any>
]=]
function Table.Values(From: GenericTable): Array<any>
	local Values: Array<any> = {}

	for _, Value in From do
		table.insert(Values, Value)
	end

	return Values
end

--[=[
	@within Table
	@function Copy<T>

	Copies a table and returns a new table with the same values. Has the option to DeepCopy the table.
	
	@param TableToCopy T
	@param IsDeep boolean?

	@return T
]=]
function Table.Copy<T>(TableToCopy: T, IsDeep: boolean?): T
	local NewTable: any = {}

	for Key, Value in TableToCopy :: any do
		if IsDeep and typeof(Value) == "table" then
			NewTable[Key] = Table.Copy(Value, IsDeep)
		else
			NewTable[Key] = Value
		end
	end

	return NewTable :: T
end

--[=[
	@within Table
	@function Merge<A, B>

	Merges two tables together and returns the result of the merge.
	
	@param To A
	@param From B
	@param IsDeep boolean?

	@return A & B
]=]
function Table.Merge<A, B>(To: A, From: B, IsDeep: boolean?): A & B
	local ProxyTable: any = To

	for Key, Value in From :: any do
		if ProxyTable[Key] == Value then
			continue
		end

		if IsDeep and typeof(ProxyTable[Key]) == "table" and typeof(Value) == "table" then
			ProxyTable[Key] = Table.Merge(ProxyTable[Key], Value, IsDeep)
		else
			ProxyTable[Key] = Value
		end
	end

	ProxyTable = nil

	return To :: A & B
end

--[=[
	@within Table
	@function Reconcile<A, B>

	Reconciles two tables together and returns the result of the reconciliation.

	@param To A
	@param From B
	@param IsDeep boolean?

	@return A & B
]=]
function Table.Reconcile<A, B>(To: A, From: B, IsDeep: boolean?): A & B
	local ProxyTable: any = To

	for Key, Value in From :: any do
		local KeyIsNil = ProxyTable[Key] == nil

		if IsDeep and typeof(ProxyTable[Key]) == "table" and typeof(Value) == "table" then
			ProxyTable[Key] = Table.Reconcile(ProxyTable[Key], Value, IsDeep)
		elseif KeyIsNil then
			ProxyTable[Key] = Value
		end
	end

	ProxyTable = nil

	return To :: A & B
end

--[=[
	@within Table
	@function DeepFreeze
	
	Recursively freezes all tables within a table.

	@param TableToFreeze GenericTable
]=]
function Table.DeepFreeze(TableToFreeze: GenericTable)
	for Key, Value in TableToFreeze do
		if typeof(Value) ~= "table" then
			continue
		end

		Table.DeepFreeze(Value)
	end

	table.freeze(TableToFreeze)
end

--[=[
	@within Table
	@function IsArray

	Determines if a table is an array or not.

	@param TableToCheck GenericTable

	@return boolean
]=]
function Table.IsArray(TableToCheck: GenericTable): boolean
	local ArrayLength = #TableToCheck
	local TrueLength = Table.Length(TableToCheck)

	return ArrayLength == TrueLength
end

--[=[
	@within Table
	@function Reverse

	Reverses the order of elements in an array.

	@param TableToReverse Array<any>
]=]
function Table.Reverse(TableToReverse: Array<any>)
	local Clone = Table.Copy(TableToReverse)

	for Index, Value in Clone do
		TableToReverse[Index] = Clone[#Clone - Index + 1]
	end

	Clone = nil

	return TableToReverse
end

return Table
