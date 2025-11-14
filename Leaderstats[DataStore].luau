local DataStore = game:GetService("DataStoreService")

--DATA
local lastSavedData = DataStore:GetDataStore("LastSavedData")
local startingSceneData = DataStore:GetDataStore("StartingSceneData") 
local Day1Data = DataStore:GetDataStore("Day1Data") 
------------------------------------------------------------------------------------------------------------------------------



local Value = false


--when the player joins, a set of values are assigned under the player
game.Players.PlayerAdded:Connect(function(player)
	local progress= Instance.new("Folder")
	progress.Name= ("Progress")
	progress.Parent= player
    --progress folder holds all the values to be saved
	-----------------------------------------------------------
	local startingscene= Instance.new("BoolValue")
	startingscene.Name= ("StartingScene") 
	startingscene.Parent = progress
	--startingscene.Value = true
	local data = startingSceneData:GetAsync(player.UserId)
	if data == nil then
		startingscene.Value = Value
	else
		startingscene.Value = startingSceneData:GetAsync(player.UserId)
	end
	--startingscene.Value = startingSceneData:GetAsync(player.UserId)
	startingSceneData:SetAsync(player.UserId, startingscene.Value)
	-----------------------------------------------------------
	local day1= Instance.new("BoolValue")
	day1.Name= ("Day1") 
	day1.Parent = progress
	--day1.Value = true
	local data = Day1Data:GetAsync(player.UserId)
	if data == nil then
		day1.Value = Value
	else
		day1.Value = Day1Data:GetAsync(player.UserId)
	end
	Day1Data:SetAsync(player.UserId, day1.Value)
	------------------------------------------------------------
	local lastSaved = Instance.new("StringValue")
	lastSaved.Name = "LastSaved"
	lastSaved.Parent = progress
	local data = lastSavedData:GetAsync(player.UserId)
	if data == nil then
		lastSaved.Value = "nil"
	else
		lastSaved.Value = lastSavedData:GetAsync(player.UserId)
	end
  
	lastSavedData:SetAsync(player.UserId, lastSaved.Value)
    --player leaves, data store sets and stores the persistent data
	game.Players.PlayerRemoving:Connect(function(player)
		startingSceneData:SetAsync(player.UserId, player.progress.StartingScene.Value)
		Day1Data:SetAsync(player.UserId, player.progress.Day1.Value)
		lastSavedData:SetAsync(player.UserId, lastSaved.Value)
	end)
end) 




