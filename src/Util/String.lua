--[==[

	[String.lua]:
		String utility functions.

	[Author(s)]:
		- Vyon (https://github.com/Vyon)

]==]

--[=[
	@class String
	String utility functions.
]=]
local String = {}

--[=[
	@within String
	@function Random

	@param Length number
	@param Characters string?
	@param Generator Random?

	@return string
]=]
function String.Random(Length: number, InputCharacters: string?, InputGenerator: Random?): string
	local Characters = InputCharacters or "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local Generator = InputGenerator or Random.new()

	local String = ""

	for _ = 1, Length do
		local Index = Generator:NextInteger(1, #Characters)

		String ..= Characters:sub(Index, Index)
	end

	return String
end

return String
