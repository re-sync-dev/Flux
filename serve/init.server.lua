--[==[

	[init.server.lua]:
		Example of how to use Flux in a server context.

	[Author(s)]:
		- Vyon (https://github.com/Vyon)

]==]

-- Services:
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Modules:
local Flux = require(script.Flux)

-- Variables:
local MyFluxStore = Flux:GetStore("GGEz", {
	Coins = 1,
	Gems = 21,
	Pets = {
		"Dog",
		"Cat",
		"Fish",
	},
}, {
	IsMock = true,
})

-- Functions:
local function PlayerAdded(Player: Player)
	MyFluxStore:LoadAsync(Player.UserId)
		:Then(function(FluxData)
			FluxData:AddUserIds(Player.UserId)

			local Data = FluxData.Data

			while RunService:IsRunning() do
				Data.Coins += 1

				print(`{Player.Name}'s coins:`, Data.Coins)

				task.wait(1)
			end
		end)
		:Catch(function(Message: string)
			warn(`Failed to load data for {Player.Name}: {Message}`)
		end)
end

-- Main:
for _, Player in Players:GetPlayers() do
	task.spawn(PlayerAdded, Player)
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(function(Player: Player)
	MyFluxStore:UnloadAsync(Player.UserId):Await()
end)
