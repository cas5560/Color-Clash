--this script makes leaderstats
game.Players.PlayerAdded:Connect(function(player)
	local leaderstats=Instance.new("Folder",player)
	leaderstats.Name="leaderstats"
	
	local wins=Instance.new("IntValue",leaderstats)
	wins.Name="Wins"
	wins.Value=0
	local kills=Instance.new("IntValue",leaderstats)
	kills.Name="Kills"
	kills.Value=0
end)