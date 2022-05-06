-- Author: Blaze(@DevHue)
-- Created: 5/2/22
-- Edited 5/*/22


-- Events
local expltJoined = game.ReplicatedStorage.EventHandlers.xpltJ
local degnJoined = game.ReplicatedStorage.EventHandlers.dgnJ

--
local StarterUI = game.StarterGui


local function chatAlert(aName, aText, aColor, aFont, aFontSize)
	-- Send an alert using this, since it's actually easier somehow
	StarterUI:SetCore("ChatMakeSystemMessage", {
		Text = aText;
		Color = aColor;
		Font = aFont;
		FontSize = aFontSize
	})
end



expltJoined.OnClientEvent:Connect(function(Plr, Type)
	if Type == "xplt" then
		local Name = Plr.Name
		local Text = "[FPS PLUS]: "..Name.." is currently registered on the FPS:CR database, and has been removed from the game!"
		local Color = Color3.fromRGB(65, 128, 255)
		local Font = Enum.Font.SourceSansBold
		local FontSize = Enum.FontSize.Size32

		chatAlert(Name, Text, Color, Font, FontSize)
		
	elseif Type == "degn" then
		print("Something else happens here, I guess?")
		
	else
		warn("[Error: 254] If you get this error, please attempt to replicate it and send me a message on how you did it, please! You will probably be rewarded in some way.")
	end
end)
