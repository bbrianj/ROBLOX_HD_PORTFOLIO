local repStore = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

--modules
local library = repStore.Library
local lobbyModule = require(library.LobbyUI)

--events
local remotes = repStore.Remotes
local teamChosen = remotes.TeamChosen
local leaveEvent = remotes.TeamLeave

local lobbyFolder = workspace:WaitForChild("Lobby", 5)
local placeID = 138217272463519


local teams = {
	TeamA = {},
	TeamB = {},
	TeamC = {},
	TeamD = {},
	TeamE = {},
}
local teamOwner = {
	TeamA = "",
	TeamB = "",
	TeamC = "",
	TeamD = "",
	TeamE = "",
}
local teamLimit = {
	TeamA = 0,
	TeamB = 0,
	TeamC = 0,
	TeamD = 0,
	TeamE = 0,
}

local playerToGroup = {}

local function checkPlayerNumber(group)
	return #group
end

--Player creates a team
teamChosen.Event:Connect(function(player:Player, limitChoice)
	print(player.Name.." has chosen "..limitChoice)
	local group:string = playerToGroup[player]
	local lobbyModel = workspace.Lobby:FindFirstChild(group:sub(5,5))
    --timeout, eject the player to not cause jams
	if limitChoice == 0 then
		local char = player.Character
		local hrp:Part = char:FindFirstChild("HumanoidRootPart")
		for i, plrItem in ipairs(teams[group]) do
			if plrItem == player then
				table.remove(teams[group], i)
			end
		end
		hrp.CFrame = lobbyModel.TelePart.CFrame
		playerToGroup[player] = ""
		print("Timeout!")
	else
    --Player has successfully created a group!
		teamLimit[group] = limitChoice
		lobbyModule.UpdateBillboard(group, #teams[group], teamLimit[group])
		lobbyModel.TouchPart.LockEnabled.Value = false
		
		local counter:TextLabel = lobbyModel.UIModel.Part.BillboardGui.Counter
		if counter then
			local countdown = (limitChoice*2) + 5
			task.spawn(function()
				while countdown > 0 do
					counter.Text = "Starting in... "..countdown
					countdown -= 1
					task.wait(1)
				end
				lobbyModel.TouchPart.LockEnabled.Value = true
				counter.Text = "Teleporting..."
				
				for i, teamPlayer in ipairs(teams[group]) do
					if teamPlayer and teamPlayer.Character then
						TeleportService:Teleport(placeID, teamPlayer)
						table.remove(teams[group], i)
					end
				end
				counter.Text = ""
				teamLimit[group] = 0
				teamOwner[group] = ""
				lobbyModel.TouchPart.LockEnabled.Value = false
				lobbyModule.UpdateBillboard(group, #teams[group], teamLimit[group])
			end)
		end
	end
end)

--Player leaves a group
leaveEvent.OnServerEvent:Connect(function(plr)
	local char = plr.Character
	local hrp:Part = char:FindFirstChild("HumanoidRootPart")
	local group:string = playerToGroup[plr]
	--Player is ejected and removed from the player list
	hrp.CFrame = lobbyFolder[group:sub(5,5)]:FindFirstChild("TelePart").CFrame
	task.wait()
	playerToGroup[plr] = nil
	for i,playerInTeam in ipairs(teams[group]) do
		if playerInTeam == plr then
			table.remove(teams[group], i)
		end
	end
	if teamOwner[group] == plr.Name then
		teamOwner[group] = ""
	end
	lobbyModule.UpdateBillboard(group, #teams[group], teamLimit[group])
end)


for _, touchPart: Part in pairs(lobbyFolder:GetDescendants()) do
	if touchPart.Name == "TouchPart" then
		if touchPart:FindFirstChild("LockEnabled").Value == false then
			touchPart.Touched:Connect(function(hit)
				local humanoid = hit.Parent:FindFirstChild("Humanoid")
				if humanoid then
					local char = hit.Parent
					local hrp:Part = char:FindFirstChild("HumanoidRootPart")
					local plr = Players:GetPlayerFromCharacter(char)
					local group = ("Team".. touchPart.Parent.Name)
					--make group
					if checkPlayerNumber(teams[group]) == 0  then
						touchPart.LockEnabled.Value = true
						table.insert(teams[group], plr)
						teamOwner[group] = plr.Name --player is the first person to join, hence he is the team owner.
						lobbyModule.init_team(plr)
						hrp.CFrame = touchPart.Parent.UIModel.Part.CFrame
						playerToGroup[plr] = group --for identification and categorization purposes
					--join group	
					elseif checkPlayerNumber(teams[group]) < teamLimit[group] then
						table.insert(teams[group], plr) --player is added to the team
						lobbyModule.UpdateBillboard(group, #teams[group], teamLimit[group])
						hrp.CFrame = touchPart.Parent.UIModel.Part.CFrame
						playerToGroup[plr] = group --for identification and categorization purposes
						lobbyModule.normalJoin(plr)
					--unable to join group	
					elseif checkPlayerNumber(teams[group]) >= teamLimit[group] then
						return
					end
				else
					return
				end
			end)
		end
	end
end


