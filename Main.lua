--this script is responsible for the games main function

--variables
local repstor=game:GetService("ReplicatedStorage")
local lobbyGUIevent=repstor["Prep GUI for lobby"]
local gameGUIevent=repstor["Prep GUI for game"]
local serstor=game:GetService("ServerStorage")
local teams=game:GetService("Teams")

-------------------------------------------------------------This part is in charge of making the game play--------------------------------------

local Module=require(game:GetService("ReplicatedStorage"):WaitForChild("Painting Cycle"))
local Teams=game:GetService("Teams")
local gemstoneNames={"lapis","diamonds","emerald","gold","pearls","rubies"}

--makes it so if players commit suicide they die in the game
game:GetService("Players").PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid").Died:Connect(function()
			if script:FindFirstChild("Game Started").Value then
				local playerTeam=player.TeamColor
				player.TeamColor=BrickColor.new("Fossil")
				for _,part in pairs(workspace:GetDescendants())do
					if part.Name=="paint" then
						local painval=part:WaitForChild("Painter").Value
						if painval==player.Name then
							part:WaitForChild("Painter").Value=""
						end
					end
				end
				local toggle=true
				for _,player in pairs(game.Players:GetChildren()) do
					if player.TeamColor==playerTeam then
						toggle=false
					end
				end
				if toggle then
					killTeam(playerTeam,nil)
				end
			end
		end)
	end)
end)

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
	for _,team in pairs(Teams:GetChildren()) do
		if team.TeamColor~=BrickColor.new("Fossil") then
			team:FindFirstChild("Score").Value=0
		end
	end
	for _,player in pairs(game.Players:GetChildren()) do
		local gui=player:WaitForChild("PlayerGui"):WaitForChild("Game Screen"):WaitForChild("score")
		gui.Text="Score: "
		gui.TextColor3=Color3.new(0, 0, 0)
	end
	--signals that the game has ended
	script:FindFirstChild("Game Over").Value=true
	script:FindFirstChild("Game Started").Value=false
end

--used to remove a team from the game when all their players are eliminated
function killTeam(color,killerColor)
	for _,part in pairs(game.Workspace:GetDescendants()) do
		if killerColor~=nil then
			if part.Name=="paint" and part.Painter.Value=="" and part.BrickColor==color then
				part.BrickColor=killerColor
			end
		end
		if part.ClassName=="SpawnLocation" then
			if part.TeamColor==color then
				part:Destroy()
			end
		end
	end
	local teamcolors={}
	for _,player in pairs(game.Players:GetChildren()) do
		if (not table.find(teamcolors,player.TeamColor))and player.TeamColor~=BrickColor.new("Fossil") then
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

function buildgameboard()
	
	--put the painter object in each paintable part
	for _,part in pairs(workspace:GetDescendants())do
		if part.Name=="paint" then
			local painter=Instance.new("StringValue",part)
			painter.Name="Painter"
			painter.Value=""
		end
	end
	
	--makes all parts in the map do their job
	for _,item in pairs(workspace:GetDescendants()) do

		--lava and cactus parts
		if item.Name=="lava" or item.Name=="cac" then
			item.Touched:Connect(function(part)
				local hum=part.Parent:FindFirstChild("Humanoid")
				if hum then
					killPlayer(game.Players:WaitForChild(hum.Parent.Name),nil)
				end
			end)
		end
		
		--ice parts
		if item.Name=="ice" then
			item.Touched:Connect(function(part)
				local hum=part.Parent:FindFirstChild("Humanoid")
				if hum then
					hum.WalkSpeed=50
				end
			end)
			item.TouchEnded:Connect(function(part)
				local hum=part.Parent:FindFirstChild("Humanoid")
				if hum then
					hum.WalkSpeed=16
				end
			end)
		end
		
		--if the part is named paint it is paintable
		if item.Name=="paint" then
			item.Touched:Connect(function(part)
				local hum=part.Parent:FindFirstChild("Humanoid")
				if hum and hum.Health>0 then
					local player=game.Players:WaitForChild(hum.Parent.Name)
					
					--if the part is currently trying to be painted
					if item.Painter.Value~="" and item.Painter.Value~="repaint me" then
						local currentPainter=game.Players:WaitForChild(item.Painter.Value)
						if currentPainter.TeamColor~=player.TeamColor then
							--increase the players kill count
							player:WaitForChild("leaderstats"):WaitForChild("Kills").Value=player:WaitForChild("leaderstats"):WaitForChild("Kills").Value+1
							killPlayer(currentPainter,player.TeamColor)
						end
					end
					
					--if the part is currently your color
					if item.BrickColor==player.TeamColor and (item.Material==Enum.Material.SmoothPlastic or item.ClassName=="SpawnLocation") and item:WaitForChild("Painter").Value=="" then
						for _,piece in pairs(game.Workspace:GetDescendants()) do
							if piece.Name=="paint" then
								local paintval=piece:WaitForChild("Painter").Value
								if paintval==player.Name then
									piece:WaitForChild("Painter").Value="repaint me"
									--increase the player kill count if they took a spawn
									if piece.ClassName=="SpawnLocation" then
										print("in here")
										for _,person in pairs(game.Players:GetChildren()) do
											if person.TeamColor==piece.TeamColor then
												player:WaitForChild("leaderstats"):WaitForChild("Kills").Value=player:WaitForChild("leaderstats"):WaitForChild("Kills").Value+1
											end
										end
									end
									--increase the teams score
									local value=1
									for _,name in pairs(gemstoneNames) do
										if piece.Parent.Name==name then
											value=5
										end
									end
									local score=0;
									for _,team in pairs(Teams:GetChildren())do
										if team.TeamColor==item.BrickColor then
											team:FindFirstChild("Score").Value=team:FindFirstChild("Score").Value+value
											score=team:FindFirstChild("Score").Value
										end
									end
									--show the team score
									player:WaitForChild("PlayerGui"):WaitForChild("Game Screen"):WaitForChild("score").Text="Score: "..score
									player:WaitForChild("PlayerGui"):WaitForChild("Game Screen"):WaitForChild("score").TextColor3=player.TeamColor.Color
								end
							end	
						end
					end
					
					--if you also want to paint the part
					if item:WaitForChild("Painter").Value~=player.Name and item.BrickColor~=player.TeamColor then
						item:WaitForChild("Painter").Value=player.Name
						local oldColor=item.BrickColor
						local oldMaterial=item.Material
						Module.Cycle(player.TeamColor,Enum.Material.SmoothPlastic,oldColor,oldMaterial,item,player.Name)
					end
				end
			end)
		end
	end
end

-------------------------------------------------------------This part is in charge of starting the game----------------------------------------------------------------------------

local function countplayers()
	--this function counts the number of players in game and returns the total
	local players=0
	for _,player in pairs(game.Players:GetChildren()) do
		players+=1
	end
	return players
end

local function prepareMapSpawn(colors,map)
	--this function switches the colors of the map spawns to the colors that were chosen as team colors
	for _,part in pairs(workspace:WaitForChild(map):GetDescendants()) do
		if part.ClassName=="SpawnLocation" and #colors~=0 then
			local choice=math.random(1,#colors)
			part.TeamColor=colors[choice].TeamColor
			part.BrickColor=colors[choice].TeamColor
			table.remove(colors,choice)
		end
	end
end
local function removeUnusedSpawn(map)
	--this function cleans up the spawns that aren't used
	for _,part in pairs(workspace:WaitForChild(map):GetDescendants()) do
		local used=false
		if part.ClassName=="SpawnLocation" then
			for _,player in pairs(game.Players:GetChildren())do
				if player.TeamColor==part.TeamColor then
					used=true
				end
			end
			if not used then
				part:Destroy()
			end
		end
	end
end

local function startgame()
	----------------------------set the players gui to the game gui-------------------------------
	for _,player in pairs(game.Players:GetChildren()) do
		gameGUIevent:FireClient(player)
	end

	----------------------------------select the map------------------------------
	local mapchoice=math.random(1,1)
	local map
	local teamcount=0
	if mapchoice==1 then
		--Cube Biomes
		map=serstor:WaitForChild("Cube Biomes"):Clone()
		teamcount=6
		map.Name="Cube Biomes"
	end
	map.Parent=workspace

	------------------------------put players on teams-------------------------------
	local playerPERteam=math.floor(countplayers()/teamcount)
	local teamcolors={}
	--build the table of color names
	for _,color in pairs(teams:GetChildren()) do
		if color.Name ~= "Lobby" then
			table.insert(teamcolors,color)
		end
	end
	--remove color names until only the amount needed are left
	while #teamcolors>teamcount do
		local removal=math.random(1,#teamcolors)
		table.remove(teamcolors,removal)
	end
	--assign the players their colors
	local removed_table={}
	for _,player in pairs(game.Players:GetChildren()) do
		--assign the color
		local choice=math.random(1,#teamcolors)
		local colorchoice=teamcolors[choice]
		player.TeamColor=colorchoice.TeamColor
		--put that color on the removed table
		table.insert(removed_table,colorchoice)
		table.remove(teamcolors,choice)
		--empty the removed table if the color list is empty
		if #teamcolors==0 then
			for index,item in pairs(removed_table) do
				table.insert(teamcolors,item)
				removed_table[index]=nil
			end
		end
	end
	
	-------------------------spawn the players-------------------------------------
	for _,color in pairs(removed_table) do
		table.insert(teamcolors,color)
	end
	prepareMapSpawn(teamcolors,map.Name)
	removeUnusedSpawn(map.Name)
	for _,player in pairs(game.Players:GetChildren()) do
		workspace:WaitForChild(player.Name):WaitForChild("Humanoid").Health=0
	end
	for _,player in pairs(game.Players:GetChildren()) do
		repeat wait()
		until game.Workspace:WaitForChild(player.Name):WaitForChild("Humanoid").Health==100
	end
	script:FindFirstChild("Game Started").Value=true
end

local function countdown()
	--this function makes the countdown operate properly
	while true do
		local count=script:FindFirstChild("Time Between Rounds").Value
		while count>0 do
			for _,player in pairs(game.Players:GetChildren()) do
				player:WaitForChild("PlayerGui"):WaitForChild("Lobby Screen"):WaitForChild("Countdown").Text="Game Starting in: "..count
			end
			wait(1)
			count-=1
		end
		local players=countplayers()
		if players>1 then
			startgame()
			break
		else
			for _,player in pairs(game.Players:GetChildren()) do
				local message=player:WaitForChild("PlayerGui"):WaitForChild("Lobby Screen"):WaitForChild("Waiting on Players")
				local countdown=player:WaitForChild("PlayerGui"):WaitForChild("Lobby Screen"):WaitForChild("Countdown")
				message.Visible=true
				countdown.Visible=false
				wait(3)
				message.Visible=false
				countdown.Visible=true
			end
		end
	end
end
--this loops plays the actual game
while true do
	--for when the game first starts
	countdown()
	--to set up the parts in the game to do their thing
	buildgameboard()
	--wait until the game ends
	repeat wait() until script:FindFirstChild("Game Over").Value==true
	--change back to original value
	script:FindFirstChild("Game Over").Value=false
	--give the players back the lobby gui
	for _,player in pairs(game.Players:GetChildren()) do
		game:GetService("ReplicatedStorage"):WaitForChild("Prep GUI for lobby"):FireClient(player)
	end
end