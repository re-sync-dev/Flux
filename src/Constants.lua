--[==[

	[Constants.lua]:
		All variables that should be static in the package.

	[Author(s)]:
		- Vyon (https://github.com/Vyon)

]==]

-- Functions:
local function GetSecondsFromHours(Hours: number): number
	return Hours * 60 * 60
end

local function GetSecondsFromMinutes(Minutes: number): number
	return Minutes * 60
end

return {
	SESSION_LOCK_NAME = "SessionLock",
	SESSION_LOCK_TTL = GetSecondsFromHours(1) + GetSecondsFromMinutes(10), -- 1 hour and 10 minutes lifetime.
	SESSION_LOCK_RENEWAL_INTERVAL = GetSecondsFromHours(1), -- 1 hour renewal interval.
}
