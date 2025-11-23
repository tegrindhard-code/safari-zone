local _f = require(script.Parent.Parent)

local players = game:GetService('Players')
local Utilities = _f.Utilities
local create = Utilities.Create
local Network = _f.Network

local screen = workspace:WaitForChild('WorldModel').LeaderboardStand.Screen.SurfaceGui

local manager = {
	lastUpdate = 0
}

-- Configure the Elo Ranking System object
local elo = _f.Elo:new('BattleEloV5')
elo.allowFloatingRanks = true
elo.rankTransformation = function(rank)
	return math.floor((rank-800) * 4 + .5)
end
elo.kFactor = function(rank, s)
	if rank < 2100 then return 32 end
	if rank < 2400 then return 24 end
	return 16
end

local UPDATE_PERIOD = 60
local CROWN_ID = {11226822199, 11226829292, 11226838798}
local POS_COLORS = {
	Color3.new(1, 1, 0),
	BrickColor.new('Ghost grey').Color,
	BrickColor.new('Brown').Color,
	BrickColor.new('Cyan').Color
}

local listLastUpdate
local playerCrowns = setmetatable({}, {__mode='k'})

local function getPlayerFromId(idString)
	local id = tonumber(idString)
	if not id then return end
	for _, p in pairs(players:GetChildren()) do
		if p:IsA('Player') and p.UserId == id then
			return p
		end
	end
end

local function setPlayerCrownLevel(player, level)
	local existingCrown = playerCrowns[player]
	if existingCrown then
		if existingCrown.level == level then
			existingCrown.outdated = nil
			return
		end
		pcall(function() existingCrown.bbg:Destroy() end)
	end
	if not player.Character then return end
	local head = player.Character:FindFirstChild('Head')
	if not head then return end
	playerCrowns[player] = {
		level = level,
		bbg = create('BillboardGui') {
			Adornee = head,
			Size = UDim2.new(2.0, 0, 2.0, 0),
			StudsOffset = Vector3.new(0, 2, 0),
			Parent = player.Character,
			create('ImageLabel') {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://' .. CROWN_ID[level],
				Size = UDim2.new(1.0, 0, 1.0, 0),
			}
		}
	}
end

local usernameCache = {}
local function usernameFromId(id)
	if usernameCache[id] then
		return usernameCache[id]
	end
	local s, name = pcall(function() return players:GetNameFromUserIdAsync(id) end)
	if s then
		usernameCache[id] = name
		return name
	end
	return '?'
end

function manager:processMatchResult(id1, id2, winner)
	local d1, d2 = elo:adjustRanks(id1, id2, winner)
	local function updatePlayerLists(id)
		local player = getPlayerFromId(id)
		if player then
			local rank = elo:getTransformedPlayerRank(id)
			if not player:FindFirstChild('OwnedPokemon') then
				Instance.new('IntValue', player).Name = 'OwnedPokemon'
			end
			local badgeId = 0
			pcall(function() badgeId = player.BadgeId.Value end)
			player.OwnedPokemon.Value = rank
			Network:postAll('UpdatePlayerlist', player.Name, badgeId, rank)
		end
	end
	updatePlayerLists(id1)
	updatePlayerLists(id2)
	spawn(function() self:update() end)
	return d1, d2
end

function manager:getPlayerRank(...)
	return elo:getTransformedPlayerRank(...)
end

local updateThread
function manager:update()
	if tick() - self.lastUpdate < 5 then return end
	self.lastUpdate = tick()

	local list = elo:getTopList(20)
	listLastUpdate = list

	local thisThread = {}
	updateThread = thisThread

	for _, crown in pairs(playerCrowns) do
		crown.outdated = true
	end
	for i, entry in pairs(list) do
		if i > 15 or entry.value <= 800 then break end
		local p = getPlayerFromId(entry.key)
		if p then
			setPlayerCrownLevel(p, math.ceil(i / 5))
		end
	end
	for p, crown in pairs(playerCrowns) do
		if crown.outdated then
			pcall(function() crown.bbg:Destroy() end)
			playerCrowns[p] = nil
		end
	end

	screen:ClearAllChildren()
	for i, entry in pairs(list) do
		if i > 20 or entry.value <= 800 then break end
		local cell = create('Frame') {
			BorderSizePixel = 0,
			BackgroundColor3 = BrickColor.new('Deep blue').Color,
			BackgroundTransparency = .2,
			Size = UDim2.new(.5, -6, (19/20)/10, -6),
			Position = UDim2.new(i > 10 and .5 or 0, 3, i > 10 and (1/20 + (i-11) * (19/20)/10) or ((i-1) * (19/20)/10), 3),
			Parent = screen
		}
		Utilities.Write(tostring(i)) {
			Frame = create('Frame') {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.5, 0),
				Position = UDim2.new(0.025, 0, 0.3, 0),
				ZIndex = 3, Parent = cell
			}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			Color = POS_COLORS[math.ceil(i / 5)]
		}
		Utilities.Write(tostring(elo.rankTransformation(entry.value))) {
			Frame = create('Frame') {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.5, 0),
				Position = UDim2.new(0.975, 0, 0.3, 0),
				ZIndex = 2, Parent = cell
			}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right
		}
		Utilities.fastSpawn(function()
			local name = usernameFromId(tonumber(entry.key))
			if updateThread ~= thisThread then return end
			Utilities.Write(name) {
				Frame = create('Frame') {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					ZIndex = 2, Parent = create('Frame') {
						ClipsDescendants = true,
						BackgroundTransparency = 1.0,
						Size = UDim2.new(.65, 0, 1.0, 0),
						Position = UDim2.new(.125, 0, 0.0, 0),
						Parent = cell
					}
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left
			}
		end)
	end
end

function manager:startUpdateCycle()
	if self.started then return end
	self.started = true
	spawn(function()
		while true do
			self:update()
			wait(UPDATE_PERIOD)
		end
	end)
end

players.ChildAdded:connect(function(player)
	if not player or not player:IsA('Player') then return end
	player.CharacterAdded:connect(function(character)
		if not listLastUpdate then
			manager:update()
			return
		end
		local idString = tostring(player.UserId)
		for i, entry in pairs(listLastUpdate) do
			if i > 15 then break end
			if entry.key == idString and entry.value > 800 then
				setPlayerCrownLevel(player, math.ceil(i / 5))
				break
			end
		end
	end)
end)

return manager
