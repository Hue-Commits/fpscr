-- Author: Blaze(@DevHue)
-- Created: 5/2/22
-- Edited 5/*/22

-- Events
local expltJoined = game.ReplicatedStorage.EventHandlers.xpltJ
local degnJoined = game.ReplicatedStorage.EventHandlers.dgnJ

-- Databases
local xpltList = script.Database.xplt
local dgnList = script.Database.dgn
local Casetype = nil

game.Players.PlayerAdded:Connect(function(Plr)
	-- Player joins games
	if Plr.UserId == 1 then
		Casetype = "xplt"
		expltJoined:FireAllClients(Plr, Casetype)
	end
end)

