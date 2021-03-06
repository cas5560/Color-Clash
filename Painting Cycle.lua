--this script is responsible for alternating the colors on blocks that are being taken and handles some of the main script stuff
local module = {}

--used to finish the game when only one team remains
function endGame(winningTeam)
	--shows and then hides the you win title
	for _,player in pairs(game.Players:GetChildren())do
		if player.TeamColor==winningTeam then
			player:WaitForChild("PlayerGui"):WaitForChild("Winner Screen").Enabled=true
			--give the player a leaderstats win
			player:WaitForChild("leaderstats"):WaitForChild("Wins").Value=player:WaitForChild("leaderstats"):WaitForChild("Wins").Value+1
		end
	end
	wait(3)
	for _,player in pairs(game.Players:GetChildren())do
		if player.TeamColor==winningTeam then
			player:WaitForChild("PlayerGui"):WaitForChild("Winner Screen").Enabled=false
		end
	end
	--removes the remaining players from the game
	for _,player in pairs(game.Players:GetChildren())do
		if(player.TeamColor==winningTeam) then
			player.TeamColor=BrickColor.new("Fossil")
			game.Workspace:WaitForChild(player.Name):WaitForChild("Humanoid").Health=0
		end
	end
	--destroy the map
	for _,obj in pairs(game.Workspace:GetChildren())do
		if obj:FindFirstChild("IsMap") then
			wait(10)
			obj:Destroy()
		end
	end
	--reset the scores
	for _,team in pairs(game:GetService("Teams"):GetChildren()) do
		if team.TeamColor~=BrickColor.new("Fossil") then
			team:FindFirstChild("Score").Value=0
		end
	end
	for _,player in pairs(game.Players:GetChildren()) do
		local gui=player:WaitForChild("PlayerGui"):WaitForChild("Game Screen"):WaitForChild("score")
		gui.Text="Score: "
		gui.TextColor3=Color3.new(0, 0, 0)
	end
	--signals that the game has finished
	game:GetService("ServerScriptService"):FindFirstChild("Main"):FindFirstChild("Game Over").Value=true
	game:GetService("ServerScriptService"):FindFirstChild("Main"):FindFirstChild("Game Started").Value=false
end
	
--used to remove a team from the game when all their players are eliminated
function killTeam(color,killerColor)
	for _,part in pairs(game.Workspace:GetDescendants()) do
		if part.Name=="paint" and part.Painter.Value=="" and part.BrickColor==color then
			part.BrickColor=killerColor
		end
		if part.ClassName=="SpawnLocation" then
			if part.TeamColor==color then
				part:Destroy()
			end
		end
	end
	local teamcolors={}
	for _,player in pairs(game.Players:GetChildren()) do
		if (not table.find(teamcolors,player.TeamColor)) and player.TeamColor~=BrickColor.new("Fossil") then
			table.insert(teamcolors,player.TeamColor)
		end
	end
	if #teamcolors<=1 then
		endGame(table.remove(teamcolors,1))
	end
end

--used to properly remove a player from the game
function killPlayer(person,killer)
	--remove the player
	local playerTeam=person.TeamColor
	game.Workspace:WaitForChild(person.Name):WaitForChild("Humanoid").Health=0
	person.TeamColor=BrickColor.new("Fossil")
	for _,part in pairs(workspace:GetDescendants())do
		if part.Name=="paint" then
			local painval=part:WaitForChild("Painter").Value
			if painval==person.Name then
				part:WaitForChild("Painter").Value=""
			end
		end
	end
	--remove the team if that was the last surviving player
	local toggle=true
	for _,player in pairs(game.Players:GetChildren()) do
		if player.TeamColor==playerTeam then
			toggle=false
		end
	end
	if toggle then
		--that was the last player on that team
		if killer==nil then
			killTeam(playerTeam,nil)
		else
			killTeam(playerTeam,killer)
		end
	end
end

module.Cycle=function(firstColor,firstMaterial,secondColor,secondMaterial,part,painter)
	while true do
		part.BrickColor=firstColor
		part.Material=firstMaterial
		wait(.5)
		if part:WaitForChild("Painter").Value~=painter then
			break
		end
		part.BrickColor=secondColor
		part.Material=secondMaterial
		wait(.5)
		if part:WaitForChild("Painter").Value~=painter then
			break
		end
	end
	if part:WaitForChild("Painter").Value=="repaint me" then
		part.BrickColor=firstColor
		part.Material=firstMaterial
		part:WaitForChild("Painter").Value=""
		if part.ClassName=="SpawnLocation" then
			if part.TeamColor~=firstColor then
				for _,player in pairs(game.Players:GetChildren()) do
					if player.TeamColor==part.TeamColor then
						killPlayer(player,firstColor)
					end
				end
			end
		end
	else
		part.BrickColor=secondColor
		part.Material=secondMaterial
	end
end

return module