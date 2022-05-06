local Players = game:GetService("Players")


-- // If you want to use a whitelist mode for animations instead of a blacklist.
local USE_WHITELIST = false
-- // If you want to whitelist / blacklist an animation enter it here.
local ANIMATIONS_LIST = {}


local function protectHat(hat)
	local handle = hat:WaitForChild("Handle", 30)

	if handle then
		-- Network ownership
		task.defer(function()
			local joint = handle:WaitForChild("AccessoryWeld")

			local connection
			connection = joint.AncestryChanged:Connect(function(_, parent)
				if not connection.Connected or parent then
					return
				end

				connection:Disconnect()

				if handle and handle:CanSetNetworkOwnership() then
					handle:SetNetworkOwner(nil)
				end
			end)
		end)

		-- Mesh hat
		if handle:IsA("Part") then
			local mesh = handle:FindFirstChildOfClass("SpecialMesh") or handle:WaitForChild("Mesh")

			mesh.AncestryChanged:Connect(function(child, parent)
				task.defer(function()
					if child == mesh and handle and (not parent or not handle:IsAncestorOf(mesh)) and hat and hat.Parent then
						mesh.Parent = handle
					end
				end)
			end)
		end
	end
end

local function killHumanoid(humanoid)
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
		humanoid.Health = 0
	end
end

local function onPlayerAdded(player)
	local function onCharacterAdded(character)
		for _, v in ipairs(character:GetChildren()) do
			if v:IsA("Accoutrement") then
				coroutine.wrap(protectHat)(v)
			end
		end

		character.ChildAdded:Connect(function(child)
			if child:IsA("Accoutrement") then
				protectHat(child)
			elseif child:IsA("BackpackItem") then
				local count = 0
				-- Multi Tool
				task.defer(function()
					for _, v in ipairs(character:GetChildren()) do
						if v:IsA("BackpackItem") then
							count += 1
							if count > 1 then
								v.Parent = player:FindFirstChildOfClass("Backpack") or Instance.new("Backpack", player)
							end
						end
					end
				end)
			end
		end)


		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")

		-- Humanoid Delete
		humanoid.AncestryChanged:Connect(function(child, parent)
			task.defer(function()
				if child == humanoid and character and (not parent or not character:IsAncestorOf(humanoid)) then
					humanoid.Parent = character
				end
			end)
		end)

		humanoid.StateChanged:Connect(function(last, state)
			if last == Enum.HumanoidStateType.Dead and state ~= Enum.HumanoidStateType.Dead then
				killHumanoid(humanoid)
			end
		end)

		-- Force Respawn
		if Players.CharacterAutoLoads then
			local connection

			connection = humanoid.Died:Connect(function()
				if not connection.Connected then
					return
				end

				connection:Disconnect()

				task.wait(Players.RespawnTime + 1.5)

				if humanoid and workspace:IsAncestorOf(humanoid) then
					player:LoadCharacter()
				end
			end)
		end

		local animator = humanoid:WaitForChild("Animator")
		-- Animation Blacklist and whitelist
		animator.AnimationPlayed:Connect(function(animationTrack)
			local animationId = string.lower(string.gsub(animationTrack.Animation.AnimationId, "%s", ""))
			if
				animationId == "rbxassetid://148840371" or
				string.match(animationId, "[%d%l]+://[/%w%p%?=%-_%$&'%*%+%%]*148840371/*") or
				USE_WHITELIST and not table.find(ANIMATIONS_LIST, animationId) or
				not USE_WHITELIST and table.find(ANIMATIONS_LIST, animationId)
			then
				task.defer(function()
					animationTrack:Stop(1/60)
				end)
			end
		end)

		local connections = {}
		local function makeConnection(Conn)
			local connection
			connection = Conn:Connect(function(_, parent)
				task.defer(function()
					if not connection.Connected or parent or humanoid and not humanoid.RequiresNeck then
						return
					end

					for _, v in ipairs(connections) do
						v:Disconnect()
					end

					if humanoid and not (humanoid.Health <= 0) then
						killHumanoid(humanoid)
					end
				end)
			end)

			table.insert(connections, connection)
		end
		-- Joint hack lol
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local rootJoint = humanoid.RigType == Enum.HumanoidRigType.R15 and character:WaitForChild("LowerTorso"):WaitForChild("Root") or humanoid.RigType == Enum.HumanoidRigType.R6 and (humanoidRootPart:FindFirstChild("Root Hip") or humanoidRootPart:WaitForChild("RootJoint"))

		makeConnection(rootJoint.AncestryChanged)

		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			makeConnection(character:WaitForChild("UpperTorso"):WaitForChild("Waist").AncestryChanged)
		end
	end

	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end

	player.CharacterAdded:Connect(onCharacterAdded)
end


for _, v in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, v)
end

Players.PlayerAdded:Connect(onPlayerAdded)
