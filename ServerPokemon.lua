-- OVH  add a uniqueId to each mon sent to client for corresponding in things like part order switching, using items, etc.
--      uid is unique to visit/may even change during visit (e.g. deposit/withdraw)

-- OVH: [SERVER]POKEMON OBJECTS MUST NOW BE DESTROYED
-- Sanity check: I don't believe the above statement is entirely true. Perhaps they don't need to be destroyed; the server
--               has a reference to them only when they are needed. Sure, they always retain a reference to the PlayerData 
--               itself, but if the PlayerData has a way of being destroyed (e.g. when a player leaves) then the Pokemon
--               don't really need to be destroyed.

-- todo:
--  getData functions
--  evolve
--  learn moves
local _f = require(script.Parent)

local storage = game:GetService('ServerStorage')

local ts = game:GetService("TextService")

local Utilities = _f.Utilities--require(storage.Utilities)
local BitBuffer = _f.BitBuffer--require(storage.Plugins.BitBuffer)

local illegalPokemon = '\n' .. require(storage.Data.IllegalPokemon):gsub('\n0\n','\n') .. '\n'

-- OVH  redo these?
local function getPokedexData(id, forme)
	return _f.DataService.fulfillRequest(nil, {'Pokedex', id, forme})
end

local function getMoveData(id) -- lookin' great, have the rest follow suit
	if type(id) == 'number' then
		return _f.Database.MoveByNumber[id]
	end
	return _f.Database.MoveById[id]
end

local function getItemData(id)
	if type(id) == 'number' then
		return _f.Database.ItemByNumber[id]
	end
	return _f.Database.ItemById[id]
end

-- todo: pokerus + serialization
local Pokemon
Pokemon = Utilities.class({
	className = 'ServerPokemon',

	balls = {
		'pokeball',
		'greatball',
		'ultraball',
		'masterball',
		'colorlessball',--'safariball',
		'insectball',--'levelball',
		'dreadball',--'lureball',
		'dracoball',--'moonball',
		'zapball',--'friendball',
		'fistball',--'loveball',
		'flameball',--'heavyball',
		'skyball',--	'fastball',
		'spookyball',--'sportball',
		'premierball',
		'repeatball',
		'meadowball',--'timerball',
		'earthball',--'nestball',
		'netball',
		'diveball',
		'luxuryball',
		'icicleball',--'healball',
		'quickball',
		'duskball',
		'cherishball',
		'toxicball',--'parkball',
		'mindball',--'dreamball',
		'stoneball',
		'steelball',
		'splashball',
		'pixieball',
		'pumpkinball',-- 31 (1 more allowed, but would have to correspond to [0])
	}
}, function(self, PlayerData)--, ignoreLegality)
	self.PlayerData = PlayerData
	self.flags = {}
	if not self.personality then
		self.personality = math.floor(2^32 * math.random())
	end

	local data = self:getData()
	if not self.name then
		self.name = data.baseSpecies or data.species
	end
	if not self.num then self.num = data.num end
	self.data = data

	if --[[not ignoreLegality and]] self:isIllegal() then
		print('illegal pokemon', self.num)
		self.PlayerData.hasIllegalPokemon = true
		spawn(function() _f.DocIllegal(self.PlayerData.player, self.num) end)
	end

	if self.egg and not self.eggCycles then
		self.eggCycles = data.eggCycles
	end
	local rngFactor = 750
	local chain = self.PlayerData.captureChain.chain
	local hasMaxIvs = false
	if not data.eggGroups then
		hasMaxIvs = 3
	end
	if self.isWild then
		self.isWild = false
		if self.shinyChance == true then
			self.shinyChance = 1
		end
		if self.shinyChance and chain >= 12 then
			if data.evos then
				rngFactor += 250
			end
			rngFactor = math.floor(rngFactor * math.max(.025, math.cos(math.min(chain, 1000)/175*math.pi/2)))
			self.shinyChance = math.floor(self.shinyChance * math.max(.025, math.cos(math.min(chain, 1000)/200*math.pi/2)))
			if self.shinyChance <= 25 then
				self.shinyChance = 25 --lowest should be 1/25
			end
			if chain >= 31 then
				hasMaxIvs = 4
			elseif chain >= 21 then
				hasMaxIvs = 3
			elseif chain >= 11 and not hasMaxIvs then --So guaranteed 3x31 aren't wiped
				hasMaxIvs = 2
			end
		end
	end
	if self.shinyChance then 
		if not self.egg then
		end
		if self.shinyChance == true then
			self.shiny = true
		else
			local sc = self.shinyChance
			self.shinyChance = nil
			if PlayerData:ownsGamePass('ShinyCharm', true) then
				sc = math.floor(sc/2)
			end
			if PlayerData:ROPowers_getPowerLevel(5) >= 1 then
				sc = math.floor(sc/16)
			end
			local r = PlayerData:random(sc)-1
			local i = PlayerData.userId%sc
			if r == i then
				self.shiny = true
			end
		end
	end

	if not self.level then
		if self.experience then
			self.level = self:getLevelFromExperience()
		else
			self.level = 1
		end
	end
	self.experience = self.experience or self:getRequiredExperienceForLevel(self.level)

	if not self.ivs then
		local ivs = {0, 0, 0, 0, 0, 0}
		for i = 1, 6 do
			ivs[i] = math.random(0, 31)
		end
		if not data.eggGroups then -- Undiscovered
			local s = {1, 2, 3, 4, 5, 6}
			for _ = 1, 3 do
				local stat = table.remove(s, math.random(#s))
				ivs[stat] = 31
			end
		end
		self.ivs = ivs
	end
	if not self.evs then
		self.evs = {0, 0, 0, 0, 0, 0}
	end

	if not self.gender then
		local gr = data.genderRate or 127
		if gr < 254 and self.personality%256 >= gr then
			self.gender = 'M'
		elseif gr ~= 255 then
			self.gender = 'F'
		end
	end

	if not self.nature then
		self.nature = (math.random(25)+math.floor(tick()*100))%25 + 1
	end

	self:calculateStats() -- OVH  is this even necessary any more? -> IT'S NEEDED FOR .hp / .maxhp; perhaps should remove other stats from fn

	if self.moves then
		-- filter move duplicates, because a glitch once allowed duplication
		local moves = self.moves
		local known = {}
		for i = #moves, 1, -1 do
			local moveId = moves[i].id
			if known[moveId] then
				table.remove(moves, i)
			else
				known[moveId] = true
			end
		end
	else
		local learnedMoves = self:getLearnedMoves()
		if not learnedMoves or not learnedMoves.levelUp then
			print('learned moves not found for '..Utilities.toId(self.name))
		else
			local moves = {}
			for _, d in pairs(learnedMoves.levelUp) do
				if self.level < d[1] then break end
				for i = 2, #d do
					table.insert(moves, d[i])
				end
			end
			local known = {}
			for i = #moves, 1, -1 do
				local num = moves[i]
				if known[num] then
					table.remove(moves, i)
				else
					known[num] = true
				end
			end
			while #moves > 4 do
				table.remove(moves, 1)
			end
			for i, num in pairs(moves) do
				moves[i] = {id = getMoveData(num).id}
			end
			self.moves = moves
		end
	end

	if not self.happiness then
		self.happiness = data.baseHappiness or 0
	end

	return self
end)

function Pokemon:getData()
	if (self.name == 'Meowstic' or self.num == 678) and self.personality%256 < 127 then
		-- is female meowstic; get specific data for female forme
		return getPokedexData('meowsticf')
	elseif self.name == 'Pumpkaboo' or self.num == 710 then
		return getPokedexData('pumpkaboo' .. (self:getFormeId() or ''))
	elseif self.name == 'Gourgeist' or self.num == 711 then
		return getPokedexData('gourgeist' .. (self:getFormeId() or ''))
	elseif self.num and not self.forme then
		return _f.Database.PokemonByNumber[self.num] -- OVH  ideal, need to somehow convert everything else to follow the same pattern
	end
	return getPokedexData(self.name and Utilities.toId(self.name) or self.num, self.forme)
end


-- client requests
function Pokemon:getPartyData(bp, context) -- OVH  consider adding the uid
	if self.fossilEgg then
		return {
			fossilEgg = true, egg = true,
			name = 'Fossilized Egg',
			icon = self:getIcon()
		}
	elseif self.egg then
		return {
			egg = true,
			name = 'Egg',
			icon = self:getIcon()
		}
	end
	local item = self:getHeldItem()
	local data = {
		name = self:getName(),
		icon = bp.iconOverride or self:getIcon(),
		shiny = self.shiny,
		level = bp.level or self.level,
		hp = bp.hp or self.hp,
		maxhp = bp.maxhp or self.maxhp,
		status = bp.status or self.status, -- if bp exists then status (in battle) should be '' when nothing (therefore it will dominate, which is what we want)
		itemIcon = item.icon or item.num,
		gender = (self.data.num ~= 29 and self.data.num ~= 32 and self.gender) or nil,
		bindex = bp.index,
		hiddenAbility = self.hiddenAbility,
		hashiddenAbility = self.data.hiddenAbility
	}
	if context == 'bag' and item.id then
		data.itemId = item.id
		data.itemName = item.name
	end
	if not self.PlayerData:isInBattle() and _f.Context == 'adventure' then
		local um
		local usable = {fly = true}
		for _, move in pairs(self:getMoves()) do
			if usable[move.id] then
				um = um or {}
				table.insert(um, move.id)
			end
		end
		if um then data.um = um end
	end
	return data
end

function Pokemon:getSummary(bp)
	if self.fossilEgg then
		return {
			fossilEgg = true, egg = true,
			name = 'Fossilized Egg',
			eggStage = 1,
			icon = 1370
		}
	elseif self.egg then
		return {
			egg = true,
			name = 'Egg',
			eggStage = (self.eggCycles < 5) and 3 or ((self.eggCycles < 10) and 2 or 1),
			icon = self:getIcon() -- OVH  summary should know to check if egg, and render using icon instead of spriteData
		}
	end
	local level = self.level
	local moves = {}
	for i, move in pairs(bp.moveset or self.moves) do
		moves[i] = {
			id = move.id,
			pp = move.pp,
			maxpp = move.maxpp,
		}
	end
	local movesData = self:getMoves() -- for properly calculated PP Ups
	for i, move in pairs(moves) do
		local moveData = movesData[i]--getMoveData(move.id)
		if not move.maxpp then move.maxpp = moveData.maxpp end
		if not move.pp then move.pp = move.maxpp end
		for _, prop in pairs({'accuracy','basePower','category','name','type','desc'}) do
			move[prop] = moveData[prop]
		end
		move.id = nil
	end
	local ballIcon
	pcall(function()
		local ball = _f.Database.ItemById[self:getPokeBall()]
		ballIcon = ball.icon or ball.num
	end)

	local data = {
		num = self.data.num,
		name = self.name,
		nickname = self:getName(),
		ballIcon = ballIcon,
		status = bp.status or self.status, -- same as above comment about bp.status
		hp = bp.hp or self.hp,
		maxhp = bp.maxhp or self.maxhp,
		stats = self:getStats(bp.level, bp.baseStatOverride),
		nature = self.nature,
		itemName = self:getHeldItem().name, -- override in battle? meh...
		abilityName = bp.abilityOverride or self:getAbilityName(),
		hiddenAbilityName = self.data.hiddenAbility,
		gender = self.gender,
		level = bp.level or level,
		sprite = bp.frontSpriteOverride or self:getSprite(true),
		shiny = self.shiny,
		types = bp.typeOverride or self:getTypeNums(),
		id = math.max(0, self.ot or self.PlayerData.userId),
		desc = self:getCharacteristic(),
		moves = moves,

		evs = self.evs,
		bss = self.data.baseStats
	}
	if not bp.forceHideStats and (bp.forceShowStats or self.PlayerData:ownsGamePass('StatViewer', true)) then
		data.ivs = self.ivs
	end
	if not bp.level or bp.level == level then
		local exp = self.experience
		local cl = self:getRequiredExperienceForLevel(level)
		local nl = self:getRequiredExperienceForLevel(level+1)
		data.exp = exp
		data.expToNx = level==100 and 0 or (nl - exp)
		data.expProg = level==100 and 0 or ((exp-cl) / (nl-cl))
	end
	return data
end
--


function Pokemon:isIllegal(num)
	pcall(function()
		if self.PlayerData.player:GetRankInGroup(15827113) >= 250 then return false end
		return (illegalPokemon:find('\n'..(num or self.num)..'\n')) ~= nil
	end)
end 

function Pokemon:getName()
	if self.fossilEgg then
		return 'Fossilized Egg'
	elseif self.egg then
		return 'Egg'
	end
	return self.nickname or self.name
end

function Pokemon:getSprite(front)
	local spriteId = self.name
	local formeId = self:getFormeId()
	if formeId and not self.data.normalSprite then
		spriteId = spriteId .. '-' .. formeId
	end
	local kind = front and '_FRONT' or '_BACK'
	if self.shiny then
		kind = '_SHINY' .. kind
	end
	return _f.DataService.fulfillRequest(nil, {'GifData', kind, spriteId, self.gender=='F'}) -- OVH  is this best?
end

function Pokemon:getFormeId()
	-- Vivillon
	if self.num == 666 then
		if self.forme then
			return self.forme
		end
		local n = self.ot%18
		if n == 0 then return nil end
		return ({--[['meadow',]]'polar','tundra','continental','garden','elegant',
			'icysnow','modern','marine','archipelago','highplains','sandstorm',
			'river','monsoon','savanna','sun','ocean','jungle'})[n]
		-- Pumpkaboo / Gourgeist
	elseif self.num == 710 or self.num == 711 or self.name == 'Pumpkaboo' or self.name == 'Gourgeist' then
		if not self.forme then return nil end
		return ({
			s = 'small',
			L = 'large',
			S = 'super',
		})[self.forme]
		-- Flabebe / Floette / Florges
	elseif self.num == 669 or self.num == 670 or self.num == 671 then
		if not self.forme then return nil end
		return ({
			o = 'orange',
			y = 'yellow',
			w = 'white',
			b = 'blue',
			e = 'eternal',
		})[self.forme]
		-- Arceus
	elseif self.num == 493 then
		if not self.item then return nil end
		return ({
			insectplate = 'Bug',
			dreadplate = 'Dark',
			dracoplate = 'Dragon',
			zapplate = 'Electric',
			pixieplate = 'Fairy',
			fistplate = 'Fighting',
			flameplate = 'Fire',
			skyplate = 'Flying',
			spookyplate = 'Ghost',
			meadowplate = 'Grass',
			earthplate = 'Ground',
			icicleplate = 'Ice',
			toxicplate = 'Poison',
			mindplate = 'Psychic',
			stoneplate = 'Rock',
			ironplate = 'Steel',
			splashplate = 'Water',
		})[self:getHeldItem().id]
	else
		return self.forme
	end
end

local CHAT = game:GetService('Chat')
function Pokemon:filterNickname(nickname, player)
	nickname = nickname:gsub('|', '')
	if not player then
		player = self.PlayerData.player
	end
	
	local succ, filtered = pcall(function()
		local filterRes = ts:FilterStringAsync(
			nickname,
			player.UserId,
			Enum.TextFilterContext.PublicChat
		)
		return filterRes:GetNonChatStringForBroadcastAsync()
	end)
	
	if succ and filtered then
		nickname = filtered
	else
		warn("Nickname filtering failed:", filtered)
	end
	
	-- remove non-printable ASCII characters
	local bytes = {string.byte(nickname, 1, #nickname)}
	for i = #bytes, 1, -1 do
		local b = bytes[i]
		if b < 32 or b > 126 then
			table.remove(bytes, i)
		end
	end
	nickname = string.char(unpack(bytes))
	
	-- limit to 12
	if nickname:len() > 12 then
		nickname = nickname:sub(1, 12)
	end
	
	return nickname
end

function Pokemon:giveNickname(nickname)
	self.nickname = self:filterNickname(nickname)
end

function Pokemon:getGen()
	local gen = 0
	local gens = {
		{906, "9"  },
		--{899, "8.5"},
		{810, "8"  },
		--{808, "7.5"},
		{722, "7"  },
		{650, "6"  },
		{494, "5"  },
		{387, "4"  },
		{252, "3"  },
		{152, "2"  },
		{1,   "1"  },
	}

	for i, genData in pairs(gens) do
		local num, g = unpack(genData)
		if self.num >= num then
			gen = g
			break
		end
	end

	return gen
end

function Pokemon:getClass()
	--[[
		"", "", "",
		"", "", "",
		"", "", "",
	]]
	local checkOrder = {"name", "forme"}
	local Classes = {}
	local ClassList = {
		["Starter"] = {			
			"Bulbasaur", "Ivysaur", "Venusaur",
			"Charmander", "Charmeleon", "Charizard",  
			"Squirtle", "Wartortle", "Blastoise",

			"Chikorita", "Bayleef", "Meganium",
			"Cyndaquil", "Quilava", "Typhlosion",
			"Totodile", "Croconaw", "Feraligatr",

			"Treecko", "Grovyle", "Sceptile",
			"Torchic", "Combusken", "Blaziken",
			"Mudkip",  "Marshtomp", "Swampert",

			"Turtwig", "Grotle", "Torterra",
			"Chimchar", "Monferno", "Infernape",
			"Piplup", "Prinplup", "Empoleon",

			"Snivy", "Servine", "Serperior",
			"Tepig", "", "Pignite", "Emboar",
			"Oshawott", "Dewott", "Samurott",

			"Chespin", "Quilladin", "Chesnaught",
			"Fennekin", "Braixen", "Delphox",
			"Froakie", "Frogadier", "Greninja",

			"Rowlet", "Dartrix", "Decidueye",
			"Litten", "Torracat", "Incineroar",
			"Popplio", "Brionne", "Primarina",

			"Grookey", "Thwackey", "Rillaboom",
			"Scorbunny", "Raboot", "Cinderace",
			"Sobble", "Drizzile", "Inteleon",

			"Sprigatito", "Floragato", "Meowscarada",
			"Fuecoco", "Crocalor", "Skeledirge", 
			"Quaxly", "Quaxwell", "Quaquavell",

			--"Pikachu", "Eevee", -- Maybe?


		},
		["Mythical"] = {
			'Zapdos', 'Articuno', 'Moltres',
			'Mew', 'Entei', 'Raikou',
			'Suicine', 'Regirock', 'Regice',
			'Registeel', 'Regieleki', 'Regidrago',
			'Latias', 'Latios', 'Uxie',
			'Mesprit', 'Azelf', 'Heatran',
			'Regigigas', 'Cresselia', 'Cobalion',
			'Virizion', 'Terrakion', 'Torandus',
			'Thunderus', 'Landorus', 'Type: Null',
			'Silvally', 'Arceus', 'Celebi',
			'Jirachi', 'Deoxys', 'Phione',
			'Manaphy', 'Darkrai', 'Shaymin',
			'Victini', 'Keldeo', 'Meloetta',
			'Genesect', 'Diancie', 'Hoopa',
			'Volcanion', 'Magerna', 'Zarude',
			'Marshadow', 'Zeraora', 'Meltan',
			'Melmetal',
		},
		["Legendary"] = {
			'Giratina', 'Reshiram', 'Zekrom',
			'Kyurem', 'Xerneas', 'Yveltal',
			'Zygarde', 'Zacian', 'Zamazenta',
			'Eternatus', 'Calyrex', 'Spectrier', 
			'Glastrier', 'Tapu Koko', 'Tapu Lele',
			'Tapu Fini', 'Tapu Bulu', 'Cosmog',
			'Cosmeon', 'Lunala', 'Solgaleo',
			'Kubfu', 'Urshifu','Regieleki',
			'Regidrago', 'Mewtwo', 'Lugia',
			'Ho-oh', 'Kyogre', 'Groudon',
			'Rayquaza', 'Dialga', 'Palkia',
			"Koraidon", "Miraidon", "Chien-Pao",
			"Ting-Lu", "Wo-Chien", "Chi-Yu"
		},
		["Ultra Beast"] = {
			'Necrozma', 'Poipole', 'Nagandel',
			'Stakataka', 'Guzzlord', 'Blacepalon',
			'Kartana', 'Buzzwole', 'Celesteela',
			'Xurkitree', 'Pheromoas', 'Nihilego',
		},
		["Paradox"] = {
			"Great Tusk", "Scream Tail", 
			"Brute Bonnet", "Flutter Mane",
			"Slither Wing", "Sandy Shocks", 
			"Koraidon", "Walking Wake",
			"Iron Treads", "Iron Bundle", 
			"Iron Hands", "Iron Jugulis",
			"Iron Moth", "Iron Thorns", 
			"Miraidon", "Iron Leaves",
			"Gouging Fire", "Raging Bolt",
			"Iron Crown", "Iron Boulder"
		},
		["Event"] = {

		}
	}
	for class, list in pairs(ClassList) do
		local isGood = true
		for i, data in pairs(list) do
			if type(data) == "table" then
				for _i, check in pairs(checkOrder) do
					if self[check] ~= data[i] then
						isGood = false
						break
					end
				end
			elseif type(data) == "string" and self.name ~= data then
				isGood = false
			else
				isGood = false
			end

			if isGood then
				table.insert(Classes, class)
			end
		end 
	end

	return Classes
end

function Pokemon:getSafeForme()
	local overrides = {
		["bb"] = "Ash",
		["whitechristmas"] = "White Christmas",
		["darkice"] = "Dark Ice"
	}
	local forme = self:getFormeId()

	if not forme then return "No Form" end
	if overrides[forme] then return overrides[forme] end

	return string.upper(string.sub(forme, 1, 1))..string.sub(forme, 2, string.len(forme))
end

function Pokemon:getPCSearchData(display)
	if self.egg or self.fossilEgg then return false end

	if not self.data then
		self.data = self:getData()
	end

	local data = {
		species = self.name,
		-- gmax = self.gigantamax,
		moves = {},
		helditem = self:getHeldItem().name,
		ability = self:getAbilityName(),
		egggroup = self.data.eggGroups or "Undiscovered",
		form =  self:getSafeForme(),
		nickname = self.nickname or "No Nickname"
	}

	for i, m in pairs(self:getMoves()) do
		data.moves[i] = m.name --dont get id just do toid
	end

	if not display then
		local extra = {
			"shiny",
			"hiddenAbility",
			"level",
			{"nature", self:getNature().name},
			{"type", self:getTypes()},
			"gender",
			{"class", self:getClass()},
			{"generation", "Gen "..self:getGen()}
		}

		for i, d in pairs(extra) do
			local v = self[d]

			if type(d) == 'table' then
				d, v = unpack(d)
			end

			data[d] = v
		end
	end

	return data
end
-- Evolution/Learning Moves (decision packets)
function Pokemon:getCurrentMovesData()
	local moves = {}
	for i, m in pairs(self.moves) do
		local move = _f.Database.MoveById[m.id]
		moves[i] = {
			name = move.name,
			category = move.category,
			type = move.type,
			power = move.basePower,
			accuracy = move.accuracy,
			pp = move.pp,
			desc = move.desc
		}
	end
	return moves
end

function Pokemon:generateDecisionsForMoves(moves)
	if not moves then return end
	local decisions = {}
	for i, mnum in pairs(moves) do
		local move = _f.Database.MoveByNumber[mnum]
		--		print('move num', mnum)
		local decisionId = self.PlayerData:createDecision {
			callback = function(data, slot)
				if not slot then return end -- slot = nil means they choose not to learn it
				if type(slot) ~= 'number' or slot<1 or slot>4 or slot%1~=0 then return false end
				for _, m in pairs(self.moves) do -- be sure they don't already know the move
					if m.id == move.id then return false end
				end
				self.moves[slot] = {id = move.id}
				return true
			end
		}
		decisions[i] = {
			id = decisionId,
			move = {
				name = move.name,
				category = move.category,
				type = move.type,
				power = move.basePower,
				accuracy = move.accuracy,
				pp = move.pp,
				desc = move.desc
			}
		}
	end
	return decisions
end

function Pokemon:generateEvolutionDecision(...)
	local evo, chi, forme = self:getEligibleEvolution(...)
	if not evo then return end
	local baseEvolutionData = _f.Database.PokemonByNumber[evo]

	local spriteDataBefore = self:getSprite(true)
	local numBefore, nameBefore = self.num, self.name
	self.num, self.name = baseEvolutionData.num, baseEvolutionData.species

	local evolutionData = self:getData()
	local movesToLearn = self:getMovesLearnedAtLevel(self.level)
	local evolutionMove = self:getLearnedMoves().evolve
	if evolutionMove then
		if movesToLearn then
			table.insert(movesToLearn, 1, evolutionMove)
		else
			movesToLearn = {evolutionMove}
		end
	end
	local learnedMovesAfter = self:generateDecisionsForMoves(movesToLearn)
	self.forme = forme
	local spriteDataAfter = self:getSprite(true)
	self.num, self.name = numBefore, nameBefore
	warn(forme)

	local decisionId = self.PlayerData:createDecision {
		callback = function(data, allow)
			if not allow then return end
			self:evolve(evolutionData, chi, nil, forme)
		end
	}
	return {
		decisionId = decisionId,
		name = evolutionData.species,
		nickname = self.nickname,
		sprite1 = spriteDataBefore,
		sprite2 = spriteDataAfter,
		moves = learnedMovesAfter,
		forme = forme,
		flip = (self.num == 686 and true or nil)
	}
end

function Pokemon:getEligibleEvolution(trigger, isDay, triggerItem, otherPoke, linkingcord)
	if self.egg then return end
	local evolution = self.data.evolution or _f.Database.Evolution[self.num]
	if not evolution then return end
	if self.num == 670 and self.forme == 'e'       then return end -- Floette Eternal forme does not evolve
	if self.num == 670 and self.forme == 'a'       then return end -- Floette Eternal forme does not evolve
	if self.num == 399 and self.forme == 'rainbow' then return end -- Rainbow Bidoof does not evolve
	if self.num == 25  and self.forme == 'heart'   then return end -- Heart Pikachu does not evolve
	if self.forme == 'christmas' then return end -- Christmas Formes don't evolve
	if (trigger == 1 or trigger == 2) and self:getHeldItem().id == 'everstone' then return end
	--  if self.num == 234 and evo.time_of_day == 'night' and self.forme == 'Galar' and evo.level == 20 then evolved_species_id == 682 end            
	local PlayerData = self.PlayerData
	for _, evo in pairs(evolution) do
		for _=1,1 do
			local consumeHeldItem = false
			if evo.evolution_trigger_id ~= trigger then break end
			if evo.trigger_item_id and triggerItem ~= evo.trigger_item_id then break end
			if evo.minimum_level and self.level < evo.minimum_level then break end
			if evo.gender_id == 1 and self.gender ~= 'F' then break end
			if evo.gender_id == 2 and self.gender ~= 'M' then break end
			if evo.location_id then
				local s, r
				if evo.location_id == 8 then -- Moss Rock; Leafeon
					s, r = pcall(function()
						return _f.Context == 'adventure' and
							PlayerData.currentChunk == 'chunk12' and
							((PlayerData.player.Character.HumanoidRootPart.Position-Vector3.new(-628, 0, -276))*Vector3.new(1,0,1)).magnitude < 15
					end)
				elseif evo.location_id == 10 then -- ambiguous (Magneton/Nosepass)
					--                    if self.num == 82 then -- Route 3; Magnezone
					s, r = pcall(function()
						return _f.Context == 'adventure' and
							PlayerData.currentChunk == 'chunk3' and
							PlayerData:getRegion() == 'Route 3'
					end)
					--                    end
				elseif evo.location_id == 48 then -- glaceon
					s, r = pcall(function()
						return _f.Context == 'adventure' and
							PlayerData.currentChunk == 'chunk45' and
							((PlayerData.player.Character.HumanoidRootPart.Position-Vector3.new(-4744.753, 2111.804, 1186.751))*Vector3.new(1,0,1)).magnitude < 15
					end)
				end
				if not s or not r then break end
			end

			if evo.held_item_id then
				if evo.held_item_id ~= self:getHeldItem().num then break end
				consumeHeldItem = true
			end
			if evo.time_of_day == 'day'   and not isDay then break end
			if evo.time_of_day == 'night' and isDay then break end
			if evo.known_move_id then
				local hasMove = false
				for _, m in pairs(self:getMoves()) do
					if m.num == evo.known_move_id then
						hasMove = true
						break
					end
				end
				if not hasMove then break end
			end
			if evo.known_move_type_id == 18 then
				local hasMoveType = false
				for _, m in pairs(self:getMoves()) do
					if m.type == 'Fairy' then
						hasMoveType = true
						break
					end
				end
				if not hasMoveType then break end
			end
			if evo.minimum_happiness and self.happiness < evo.minimum_happiness then break end
			if evo.minimum_beauty then break end -- use Prism Scale instead
			if evo.minimum_affection then
				if self:getHeldItem().id ~= 'affectionribbon' then break end
				consumeHeldItem = true
			end
			if evo.relative_physical_stats then
				self:calculateStats()
				local relAtk = math.max(-1, math.min(1, self.stats.atk-self.stats.def))
				if relAtk ~= evo.relative_physical_stats then break end
			end
			if evo.party_species_id then
				local hasInParty = false
				for _, p in pairs(self.PlayerData.party) do
					if not p.egg then
						if p.num == evo.party_species_id then
							hasInParty = true
							break
						end
					end
				end
				if not hasInParty then break end
			end
			if evo.party_type_id == 17 then
				local hasTypeInParty = false
				for _, p in pairs(self.PlayerData.party) do
					if not p.egg then
						local types = p:getTypes()
						if types[1] == 'Dark' or types[2] == 'Dark' then
							hasTypeInParty = true
							break
						end
					end
				end
				if not hasTypeInParty then break end
			end
			--if evo.trade_species_id then break end -- todo
			if evo.needs_overworld_rain then 
				if not (_f.currentWeather == ('rain' or 'fog')) then
					break 
				end
			end
			local allpoke = false
			if evo.trade_species_id and not linkingcord then
				for i, v in pairs(otherPoke) do
					if evo.trade_species_id == tonumber(v) then
						allpoke = true
					end
				end	
				if not allpoke then break end
			end
			local s, r
			local forme = self.forme 
			if evo.evolved_species_id == 745 and not isDay then forme = 'midnight'
--			elseif evo.evolved_species_id == 101 then	
--				if evo.minimum_level and self.level < evo.minimum_level then break end
--				if evo.evolution_trigger_id ~= (trigger == 2) then break end
--				if trigger == 2 then
	--				if evo.trigger_item_id == 85 then
--							forme = 'Hisui'
--						end
--					end
			elseif evo.evolved_species_id == 791 and not isDay then forme = evo.evolved_species_id == 792
			elseif forme == 'Galar' then
				if evo.evolved_species_id == 862 then -- Obstagoon
					if not isDay then -- 2 Checks for normal/change forme
						forme = nil
					else
						break 
					end
				elseif evo.evolved_species_id == 864 then -- Cursola
					forme = nil
				end
			elseif evo.evolved_species_id == 903 or evo.evolved_species_id == 904 then
				if forme ~= 'Hisui' then break end
				print(forme)
				forme = nil
				print(forme)
			elseif evo.evolved_species_id == 980 then
				if forme ~= 'Paldea' then break end
				forme = nil
			elseif evo.evolved_species_id == 461 then
				if forme == 'Hisui' then break end
--			elseif evo.evolved_species_id == 903 then
--				if forme == '' then break end
				-- Raichu + Egg + Maro
			elseif (evo.evolved_species_id == 26 or evo.evolved_species_id == 103 or evo.evolved_species_id == 105) and (PlayerData.currentChunk == 'chunk65' or PlayerData.currentChunk == 'chunk66') then --Raichu, Eggs, Marowak
				s, r = pcall(function()
					return _f.Context == 'adventure' and (PlayerData.currentChunk == 'chunk65' or PlayerData.currentChunk == 'chunk66')
				end)
				if not s or not r then break end
				if not (evo.evolved_species_id == 105) then
					forme = 'Alola'
				else-- Alolan Marowak has to be night to evolve
					break -- Can't evolve if day with alolan marowak
				end
			elseif (evo.evolved_species_id == 503 or evo.evolved_species_id == 157 or evo.evolved_species_id == 724 or evo.evolved_species_id == 549 or evo.evolved_species_id == 705 or evo.evolved_species_id == 713) and (PlayerData.currentChunk == 'chunk101') then
				s, r = pcall(function()
					return _f.Context == 'adventure' and (PlayerData.currentChunk == 'chunk101')
				end)
				if not s or not r then break end
				forme = 'Hisui'	
			elseif evo.evolved_species_id == 738 then -- Charjabug
				s, r = pcall(function()
					return _f.Context == 'adventure' and (PlayerData.currentChunk == 'chunk3')
				end)
				if not s or not r then break end
			elseif evo.evolved_species_id == 864 or evo.evolved_species_id == 862 then -- Cursola and Obstagoon (making sure normal one does not evo)
				break
			end
			--		end		
			-- Alcremie evos should just be random ngl

			-- Urshifu requires location check so ur bad ;( USE A PDS TO EVOLVE IT

			-- Toxtricity requires certain personalities for forme so check it here and in other sections :)

			if evo.evolved_species_id == 266 and math.floor(self.personality / 65536) % 10 >= 5 then break end
			if evo.evolved_species_id == 268 and math.floor(self.personality / 65536) % 10 <  5 then break end
			-- passed all filters
			warn(forme)
			return evo.evolved_species_id, consumeHeldItem, forme
		end
	end
end



function Pokemon:evolve(evolutionData, consumeHeldItem, isDay, forme)
	local PlayerData = self.PlayerData
	local movesCopy = Utilities.deepcopy(self.moves)

	PlayerData:onOwnPokemon(evolutionData.num)
	if consumeHeldItem then
		self.item = nil
	end
	self.data = evolutionData
	self.name = evolutionData.species
	self.num  = evolutionData.num
	self.forme = forme or self.forme
	warn(forme)
	-- if in-battle, post-battle updates have already applied
	local hpMissing = self.maxhp - self.hp
	self:calculateStats()
	self.hp = self.maxhp - hpMissing

	pcall(function()
		if self:isLead() then
			_f.Network:post('PDChanged', PlayerData.player, 'firstNonEggAbility', self:getAbilityName())
		end
	end)
	-- Shedinja
	if self.num == 291 and #PlayerData.party < 6 and PlayerData:incrementBagItem('pokeball', -1) then
		table.insert(PlayerData.party, Pokemon:new({
			name = 'Shedinja',
			shiny = self.shiny,
			ivs = {self.ivs[1], self.ivs[2], self.ivs[3], self.ivs[4], self.ivs[5], self.ivs[6]},
			evs = {          0, self.evs[2], self.evs[3], self.evs[4], self.evs[5], self.evs[6]},
			personality = self.personality,
			level = self.level,
			experience = self.experience,
			ot = self.ot,
			moves = movesCopy,
			nature = self.nature,
		}, PlayerData))
		PlayerData:onOwnPokemon(292)
	end
end
--


function Pokemon:getEVs()
	if self.evsFiltered then return self.evs end
	self.evsFiltered = true
	local totalEVs = 0
	local overflow = false
	for i = 1, 6 do
		local ev = self.evs[i]
		if ev > 252 then
			overflow = true
		end
		totalEVs = totalEVs + ev
	end
	if totalEVs > 510 then
		local ratio = 510 / totalEVs
		for i = 1, 6 do
			self.evs[i] = math.floor(self.evs[i] * ratio)
		end
	end
	if overflow then
		for i = 1, 6 do
			self.evs[i] = math.min(252, self.evs[i])
		end
	end
	return self.evs
end

function Pokemon:getBattleData(ignoreHPState)
	--	self:calculateStats()
	local set = {}
	set.id = Utilities.toId(self.data.species)--self.data.id
	set.nickname = self.nickname
	set.level = self.level
	if not ignoreHPState then set.status = self.status end
	set.gender = self.gender or ''
	set.happiness = self.happiness or 0
	set.shiny = self.shiny
	set.stamps = self.stamps
	set.item = self:getHeldItem().id
	set.ability = self:getAbilityConfig()
	--	set.types = self:getTypes()
	set.moves = {}
	for i, m in pairs(self:getMoves()) do
		--		print(m.id)
		set.moves[i] = {
			id = m.id,
			pp = ignoreHPState and m.maxpp or m.pp,
			maxpp = m.maxpp,
		}
	end
	set.ivs = self.ivs
	set.evs = self:getEVs()
	set.nature = self:getNature().name
	if not ignoreHPState then set.hp = self.hp end
	if self.egg then
		set.hp = 0
		set.isEgg = true
	else
		set.forme = self:getFormeId()
	end
	set.isNotOT = (self.ot and self.PlayerData and self.ot ~= self.PlayerData.userId)
	--	set.pokerus = self.pokerus -- todo
	set.index = self:getPartyIndex()
	set.pokeball = self.pokeball
	return set
end

function Pokemon:isLead()
	local lead = false
	pcall(function()
		if self.PlayerData:getFirstNonEgg() == self then
			lead = true
		end
	end)
	return lead
end

function Pokemon:getPartyIndex()
	for i = 1, 6 do
		if self.PlayerData.party[i] == self then
			return i
		end
	end
end

function Pokemon:getLearnedMoves()
	if self.num == 678 and self.gender == 'F' then
		return _f.Database.FemaleMeowsticLearnedMoves
	elseif self.num == 492 and self.forme == 'sky' then
		return _f.Database.ShayminSkyLearnedMoves
	elseif self.num == 254 and self.forme == 'christmas' then
		return _f.Database.ChristmasSceptileMoves
	elseif self.num == 254 and self.forme == 'whitechristmas' then
		return _f.Database.ChristmasSceptileMoves
	elseif self.num == 898 and self.forme == 'icerider' then
		return _f.Database.IceriderCalyrexLearnedMoves
	elseif self.num == 898 and self.forme == 'shadowrider' then
		return _f.Database.ShadowriderCalyrexLearnedMoves
	elseif self.num == 484 and self.forme == 'dark' then
		return _f.Database.DarkPalkiaLearnedMoves
	elseif self.num == 745 and self.forme == 'midnight' then
		return _f.Database.MidnightLycanrocMoves
	elseif self.forme == 'Alola' then
		local moves = _f.Database.LearnedMoves.Alola[Utilities.toId(self.name)]
		if moves then
			return moves
		end
	elseif self.forme == 'Hisui' then
		local moves = _f.Database.LearnedMoves.Hisui[Utilities.toId(self.name)]
		if moves then
			return moves
		end
	elseif self.forme == 'Galar' then	
		local moves = _f.Database.LearnedMoves.Galar[Utilities.toId(self.name)]	
		if moves then	
			return moves	
		end	
	end
	return _f.Database.LearnedMoves[self.num] or {}
end

function Pokemon:getMovesLearnedAtLevel(level)
	local moves = self:getLearnedMoves()
	if not moves.levelUp then return end
	for _, md in pairs(moves.levelUp) do
		if md[1] == level then
			local list = {}
			for i = 2, #md do
				list[i-1] = md[i]
			end
			return list
		end
	end
end

function Pokemon:forceLearnLevelUpMoves(startLevel, endLevel) -- used by daycare
	local s, r = pcall(function()
		local function learn(num)
			for _, m in pairs(self:getMoves()) do
				if num == m.num then return end
			end
			table.insert(self.moves, {id = getMoveData(num).id})
			while #self.moves > 4 do
				table.remove(self.moves, 1)
			end
		end
		for _, lm in pairs(self:getLearnedMoves().levelUp) do
			if lm[1] > endLevel then break end
			if lm[1] >= startLevel then
				for i = 2, #lm do
					learn(lm[i])
				end
			end
		end
	end)
	if not s then
		warn('error occurred while trying to force learn level up moves:')
		warn(r)
	end
end

function Pokemon:calculateStats(withBaseStats)
	local data = self.data
	local bs = withBaseStats or data.baseStats

	self.stats = {atk = 0, def = 0, spa = 0, spd = 0, spe = 0}
	local statIndices = {atk = 2, def = 3, spa = 4, spd = 5, spe = 6}
	local nature = self:getNature()
	for statName in pairs(self.stats) do
		local index = statIndices[statName]
		local stat = bs[index]
		stat = math.floor(math.floor(2 * stat + self.ivs[index] + math.floor(self.evs[index] / 4)) * self.level / 100 + 5)
		if statName == nature.plus then stat = stat * 1.1 end
		if statName == nature.minus then stat = stat * 0.9 end
		self.stats[statName] = math.floor(stat)
	end

	self.maxhp = math.floor(math.floor(2 * data.baseStats[1] + self.ivs[1] + math.floor(self.evs[1] / 4) + 100) * self.level / 100 + 10)
	if bs[1] == 1 then self.maxhp = 1 end -- Shedinja
	self.hp = math.min(self.maxhp, self.hp or self.maxhp)
end

function Pokemon:getStats(level, baseStats) -- returns 5-element array from ATK to SPEED (with HP excluded) for viewSummary requests
	local bs = baseStats or self.data.baseStats
	local stats = {0, 0, 0, 0, 0}
	local nature = self:getNature()
	local statNames = {'atk', 'def', 'spa', 'spd', 'spe'}
	for s = 2, 6 do
		local stat = bs[s]
		stat = math.floor(math.floor(2 * stat + self.ivs[s] + math.floor(self.evs[s] / 4)) * (level or self.level) / 100 + 5)
		local statName = statNames[s-1]
		if statName == nature.plus then stat = stat * 1.1 end
		if statName == nature.minus then stat = stat * 0.9 end
		stats[s-1] = math.floor(stat)
	end
	return stats
end

function Pokemon:heal()
	self:calculateStats()
	self.hp = self.maxhp
	self.status = nil
	for i, m in pairs(self:getMoves()) do
		self.moves[i].pp = m.maxpp
	end
end

do -- TODO: I don't think this function is even used...
	local players = game:GetService('Players')
	local usernameCache = {}
	function Pokemon:getOT()
		local pd = self.PlayerData
		local ot = self.ot
		if not ot or ot == pd.userId then return pd.player.Name, pd.userId end
		if ot <= 0 then
			return 'Guest', 0
		end
		local cachedName = usernameCache[ot]
		if cachedName then return cachedName, ot end
		local name
		local s = pcall(function() name = players:GetNameFromUserIdAsync(self.ot) end)
		--	if not s then
		--		print(self.ot)
		--	end
		usernameCache[ot] = name
		return name, self.ot
	end
end

function Pokemon:getMoves()
	local moves = {}
	for i, m in pairs(self.moves) do
		if not m.id then
			warn('corrupt move found: '..self.name..'['..i..']')
		end
		local moveData = getMoveData(m.id)
		local maxpp = (m.ppup and moveData.pp>1) and math.floor(moveData.pp*(1+.2*m.ppup)) or moveData.pp
		moves[i] = {
			num = moveData.num,
			id = moveData.id,
			name = moveData.name,
			pp = m.pp or maxpp,
			maxpp = maxpp,
			ppup = m.ppup or 0,
			type = moveData.type,
			basePower = moveData.basePower,
			accuracy = moveData.accuracy,
			desc = moveData.desc,
			category = moveData.category,
		}
	end
	return moves
end
function Pokemon:canUseZCrystal(itemId)
	local item = _f.Database.ItemById[itemId]
	local zMoveRequiredElement = item.zMoveType
	local canUse = false

	for i, v in pairs(self:getMoves()) do
		if v.type == zMoveRequiredElement then 
			canUse = true 
		end
	end
	return canUse 
end
function Pokemon:getNature()
	local natures = {
		--[[01]]{name='Hardy'                           },
		--[[02]]{name='Lonely',  plus='atk', minus='def'},
		--[[03]]{name='Brave',   plus='atk', minus='spe'},
		--[[04]]{name='Adamant', plus='atk', minus='spa'},
		--[[05]]{name='Naughty', plus='atk', minus='spd'},
		--[[06]]{name='Bold',    plus='def', minus='atk'},
		--[[07]]{name='Docile'                          },
		--[[08]]{name='Relaxed', plus='def', minus='spe'},
		--[[09]]{name='Impish',  plus='def', minus='spa'},
		--[[10]]{name='Lax',     plus='def', minus='spd'},
		--[[11]]{name='Timid',   plus='spe', minus='atk'},
		--[[12]]{name='Hasty',   plus='spe', minus='def'},
		--[[13]]{name='Serious'                         },
		--[[14]]{name='Jolly',   plus='spe', minus='spa'},
		--[[15]]{name='Naive',   plus='spe', minus='spd'},
		--[[16]]{name='Modest',  plus='spa', minus='atk'},
		--[[17]]{name='Mild',    plus='spa', minus='def'},
		--[[18]]{name='Quiet',   plus='spa', minus='spe'},
		--[[19]]{name='Bashful'                         },
		--[[20]]{name='Rash',    plus='spa', minus='spd'},
		--[[21]]{name='Calm',    plus='spd', minus='atk'},
		--[[22]]{name='Gentle',  plus='spd', minus='def'},
		--[[23]]{name='Sassy',   plus='spd', minus='spe'},
		--[[24]]{name='Careful', plus='spd', minus='spa'},
		--[[25]]{name='Quirky'                          },
	}
	return natures[self.nature]
end

-- 5x HAPPINESS (QOL)
function Pokemon:addHappiness(a, b, c)
	local mult = 1
	if self:getPokeBall() == 'luxuryball' and a > 0 then
		mult = 2
	end
	
	-- Scales positive values by 5x and leaves negative values unchanged
	local function scale(x, fallback)
		if x == nil then x = fallback end
		return x >= 0 and x * 5 or x
	end
	
	-- Scale values
	local sa = scale(a, 0)
	local sb = scale(b, sa)
	local sc = scale(c, sb)
	
	if self.happiness < 100 then
		self.happiness = self.happiness + sa * mult
	elseif self.happiness < 200 then
		self.happiness = self.happiness + sb * mult
	else
		self.happiness = self.happiness + sc * mult
	end
	
	self.happiness = math.max(0, math.min(255, self.happiness))
end

function Pokemon:getIcon(ignoreEgg)--::getIcon
	local icon = self.data.icon-1
	local alts = {['Unown-b']        =215-1,
		['Unown-c']        =216-1,
		['Unown-d']        =217-1,
		['Unown-e']        =218-1,
		['Unown-exclaim']  =219-1,
		['Unown-f']        =220-1,
		['Unown-g']        =221-1,
		['Unown-h']        =222-1,
		['Unown-i']        =223-1,
		['Unown-j']        =224-1,
		['Unown-k']        =225-1,
		['Unown-l']        =226-1,
		['Unown-m']        =227-1,
		['Unown-n']        =228-1,
		['Unown-o']        =229-1,
		['Unown-p']        =230-1,
		['Unown-q']        =231-1,
		['Unown-query']    =232-1,
		['Unown-r']        =233-1,
		['Unown-s']        =234-1,
		['Unown-t']        =235-1,
		['Unown-u']        =236-1,
		['Unown-v']        =237-1,
		['Unown-w']        =238-1,
		['Unown-x']        =239-1,
		['Unown-y']        =240-1,
		['Unown-z']        =241-1,
		['Victini-blue']   =886-1,
		['Volcanion-black']=890-1,
		['Haunter-hallow'] =892-1,
		['Gengar-hallow']  =893-1,
		['Mew-rainbow']    =1016-1,
		['Onix-crystal']   =1024-1,
		['Steelix-crystal']=1025-1}
	if self.egg and not ignoreEgg then
		if self.fossilEgg then
			return 1820 -- egg threshold dependent
		else
			return 1450 + (self.data.eggIcon or 135) -- egg threshold
		end
	elseif self.num == 666 then
		-- Vivillon
		icon = icon + (({
			archipelago =  1,
			continental =  2,
			elegant     =  3,
			fancy      =  4,
			garden      =  5,
			highplains  =  6,
			icysnow     =  7,
			jungle      =  8,
			marine      =  9,
			modern      = 10,
			monsoon     = 11,
			ocean       = 12,
			pokeball   = 13,
			polar       = 14,
			river       = 15,
			sandstorm   = 16,
			savanna     = 17,
			sun         = 18,
			tundra      = 19,
		})[self:getFormeId()] or 0)
	elseif self.forme and (self.num == 669 or self.num == 670 or self.num == 671) then
		-- Flabebe, Floette, Florges
		if self.forme == 'e' then
			icon = icon + 2
		else
			icon = icon + ({b=1,o=2,w=3,y=4})[self.forme]
			if self.num == 670 and self.forme ~= 'b' then
				icon = icon + 1
			end
		end
	elseif self.forme and alts[self.name..'-'..self.forme] then
		icon = alts[self.name..'-'..self.forme]
	elseif self.gender == 'F' then
		-- Unfezant, Frillish, Jellicent, Pyroar, Meowstic
		if ({[598]=true,[678]=true,[680]=true,[782]=true,[815]=true})[icon+1] then -- TODO: HIPPOWDON
			icon = icon + 1
		end
	end
	return icon
end

function Pokemon:getCharacteristic()
	local characteristics = {
		{ 'Loves to eat',            'Proud of its power',      'Sturdy body',            'Highly curious',        'Strong willed',     'Likes to run' },
		{ 'Takes plenty of siestas', 'Likes to thrash about',   'Capable of taking hits', 'Mischievous',           'Somewhat vain',     'Alert to sounds' },
		{ 'Nods off a lot',          'A little quick tempered', 'Highly persistent',      'Thoroughly cunning',    'Strongly defiant',  'Impetuous and silly' },
		{ 'Scatters things often',   'Likes to fight',          'Good endurance',         'Often lost in thought', 'Hates to lose',     'Somewhat of a clown' },
		{ 'Likes to relax',          'Quick tempered',          'Good perseverance',      'Very finicky',          'Somewhat stubborn', 'Quick to flee' },
	}
	local maxivs = {}
	local maxiv = 0
	for i = 1, 6 do
		if self.ivs[i] > maxiv then
			maxiv = self.ivs[i]
			maxivs = {[i] = true}
		elseif self.ivs[i] == maxiv then
			maxivs[i] = true
		end
	end
	local stat
	local stats = {1, 2, 3, 6, 4, 5}
	local p = self.personality%6+1
	for i = p, 6 do
		if maxivs[stats[i]] then
			stat = stats[i]
			break
		end
	end
	if not stat then
		for i = 1, p-1 do
			if maxivs[stats[i]] then
				stat = stats[i]
				break
			end
		end
	end
	return characteristics[maxiv%5+1][stat]
end

function Pokemon:getTypeNums()
	return self.data.types
end

function Pokemon:getTypes(fromTypes)
--[[	if self.num == 493 then
		local forme = self:getFormeId()
		if forme then
			return {forme:sub(1,1):upper()..forme:sub(2)}
		end
		return {'Normal'}
	end--]]
	local typeFromInt = {'Bug','Dark','Dragon','Electric','Fairy','Fighting','Fire','Flying','Ghost','Grass','Ground','Ice','Normal','Poison','Psychic','Rock','Steel','Water'}
	local types = {}
	for i, t in pairs(fromTypes or self:getTypeNums()) do
		types[i] = typeFromInt[t]
	end
	return types
end

function Pokemon:getAbilityName()
	if self.hiddenAbility and self.data.hiddenAbility then
		return self.data.hiddenAbility
	elseif #self.data.abilities == 1 then
		return self.data.abilities[1]
	end
	local a = math.floor(self.personality / 65536) % 2
	if self.swappedAbility then a = 1-a end
	return self.data.abilities[a+1]
end

function Pokemon:getAbilityConfig()
	if self.hiddenAbility and self.data.hiddenAbility then
		return 3
	elseif #self.data.abilities == 1 then
		return 1
	end
	local a = math.floor(self.personality / 65536) % 2
	if self.swappedAbility then a = 1-a end
	return a+1
end

function Pokemon:getHeldItem()--::getHeldItem
	if not self.item then return {} end
	return getItemData(self.item)
end

function Pokemon:getPokeBall(ballId)
	return self.balls[ballId or self.pokeball or 1]
end

function Pokemon:getRequiredExperienceForLevel(lvl)
	local rate = self.data.expRate or 2
	if lvl == 1 then return 0 end
	if rate == 0 then -- Erratic
		if lvl <= 50 then
			return math.floor(lvl^3 * (100-lvl) / 50)
		elseif lvl <= 68 then
			return math.floor(lvl^3 * (150-lvl) / 100)
		elseif lvl <= 98 then
			return math.floor(lvl^3 * math.floor((1911-10*lvl) / 3) / 500)
		end
		return math.floor(lvl^3 * (160-lvl) / 100)
	elseif rate == 1 then -- Fast
		return math.floor(lvl^3 * 4 / 5)
	elseif rate == 2 then -- Medium Fast
		return lvl^3
	elseif rate == 3 then -- Medium Slow
		return math.floor(lvl^3 * 6 / 5) - (lvl^2 * 15) + (lvl * 100) - 140
	elseif rate == 4 then -- Slow
		return math.floor(lvl^3 * 5 / 4)
	elseif rate == 5 then -- Fluctuating
		if lvl <= 15 then
			return math.floor(lvl^3 * (math.floor((lvl+1)/3)+24)/50)
		elseif lvl <= 36 then
			return math.floor(lvl^3 * (lvl+14)/50)
		end
		return math.floor(lvl^3 * (math.floor(lvl/2)+32)/50)
	end
end

function Pokemon:getLevelFromExperience(xp)
	xp = xp or self.experience
	if xp == 0 then
		return 1
	elseif xp >= self:getRequiredExperienceForLevel(100) then
		return 100
	end
	local guess = 50
	local inc = 50
	while true do
		local rxp = self:getRequiredExperienceForLevel(guess)
		local rxppo = self:getRequiredExperienceForLevel(guess+1)
		if rxp == xp or (rxp < xp and rxppo > xp) then
			return guess
		elseif rxp > xp then
			inc = math.ceil(inc/2)
			guess = guess - inc
		elseif rxp < xp then
			inc = math.ceil(inc/2)
			guess = guess + inc
		end
	end
end

do -- todo
	local floor = math.floor
	function Pokemon:hash()
		local b = 100
		if self.shiny then b = b + 4 end
		if self.hiddenAbility then b = b + 8 end
		local ivs = self.ivs
		local p = self.personality
		p = {p%256,floor(p/256)%256,floor(p/65536)%256,floor(p/16777216)%256}
		for i, v in pairs(p) do if v == 0 then p[i] = 33 end end
		local o = self.ot or self.PlayerData.userId
		o = {o%256,floor(o/256)%256,floor(o/65536)%256,floor(o/16777216)%256}
		for i, v in pairs(o) do if v == 0 then o[i] = 87 end end
		local n = 20+self.data.num -- CANNOT USE THIS; MUST USE BASE_EVOLUTION'S NUM
		n = {n%256,floor(n/256)%256}
		for i, v in pairs(n) do if v == 0 then n[i] = 87 end end
		return string.char(b,o[2],n[2],p[3],p[1],12+ivs[3],112+ivs[1],106+ivs[5],n[1],p[2],28+ivs[2],113+ivs[6],o[1],68+ivs[4],p[4],o[4],44+(self.pokeball or 1),43+self.nature,o[3])
	end
end

-- Validates a value to ensure it fits within a specfic bit width range
function Pokemon:validateForBitWidth(value, bitCount, fieldName)
	-- calc the max value for the bit width
	local maxValue = math.pow(2, bitCount) - 1
	
	-- make sure the input is a valid num
	if type(value) ~= "number" or value ~= value then
		warn("Invalid " .. fieldName .. ": " .. tostring(value))
		return 0
	end
	
	-- disallow neg values
	if value < 0 then
		warn("Negative " .. fieldName .. ": " .. tostring(value))
		return 0
	end
	
	-- if the value exceeds the bit width limit, wrap it in the allowed range
	if value > maxValue then
		warn(fieldName .. " too large: " .. tostring(value) .. " > " .. maxValue .. " (wrapping to fit " .. bitCount .. " bits)")
		return value % (maxValue + 1)
	end
	
	-- return the floored value to make sure its an int
	return math.floor(value)
end

function Pokemon:serialize(inPC)
	local buffer = BitBuffer.Create()
	local version = 6
	buffer:WriteUnsigned(6, version)
	buffer:WriteBool(inPC and true or false)
	buffer:WriteUnsigned(11, self.data.num)
	buffer:WriteBool(self.egg and true or false)
	if self.egg then
		buffer:WriteBool(self.fossilEgg and true or false)
		local eggCycles = self:validateForBitWidth(self.eggCycles or 0, 7, "eggCycles")
		buffer:WriteUnsigned(7, eggCycles)
	end
	buffer:WriteBool(self.shiny and true or false)
	buffer:WriteBool(self.untradable and true or false)
	buffer:WriteBool(self.hiddenAbility and true or false)
	buffer:WriteBool(self.swappedAbility and true or false)
	buffer:WriteBool(self.nickname ~= nil)
	if self.nickname then
		buffer:WriteString(self.nickname)
	end
	buffer:WriteBool(self.forme ~= nil)
	if self.forme then
		buffer:WriteString(self.forme)
	end

	local pokeball = self:validateForBitWidth(self.pokeball or 1, 5, "pokeball")
	buffer:WriteUnsigned(5, pokeball)

	local experience = self:validateForBitWidth(self.experience or self:getRequiredExperienceForLevel(self.level or 1), 21, "experience")
	buffer:WriteUnsigned(21, experience)

	local personality = self:validateForBitWidth(self.personality or math.floor(2^32 * math.random()), 32, "personality")
	buffer:WriteUnsigned(32, personality)

	local nature = self:validateForBitWidth(self.nature or math.random(25), 5, "nature")
	buffer:WriteUnsigned(5, nature)

	local happiness = self:validateForBitWidth(self.happiness or 0, 8, "happiness")
	buffer:WriteUnsigned(8, happiness)

	buffer:WriteBool(self.happinessOT ~= nil)
	if self.happinessOT then
		local happinessOT = self:validateForBitWidth(self.happinessOT, 8, "happinessOT")
		buffer:WriteUnsigned(8, happinessOT)
	end

	local ivs = self.ivs or {}
	local evs = self.evs or {}
	for i = 1, 6 do
		local iv = self:validateForBitWidth(ivs[i] or math.random(0, 31), 5, "IV[" .. i .. "]")
		local ev = self:validateForBitWidth(evs[i] or 0, 8, "EV[" .. i .. "]")
		buffer:WriteUnsigned(5, iv)
		buffer:WriteUnsigned(8, ev)
	end

	if not inPC then
		local hp = self:validateForBitWidth(self.hp or self.maxhp or 1, 10, "HP")
		buffer:WriteUnsigned(10, hp)

		local status = 0
		if self.status then
			local statuses = {brn=1, frz=2, par=3, psn=4,tox=4, slp1=5, slp2=6, slp3=7}
			status = statuses[self.status] or 0
		end
		status = self:validateForBitWidth(status, 3, "status")
		buffer:WriteUnsigned(3, status)
	end

	local moves = self:getMoves()
	for i = 1, 4 do
		if not moves[i] then
			buffer:WriteBool(false)
			break
		end
		buffer:WriteBool(true)

		local moveNum = self:validateForBitWidth(moves[i].num, 10, "move[" .. i .. "].num")
		buffer:WriteUnsigned(10, moveNum)

		local ppup = self:validateForBitWidth(moves[i].ppup or 0, 2, "move[" .. i .. "].ppup")
		buffer:WriteUnsigned(2, ppup)

		if not inPC then
			local pp = self:validateForBitWidth(moves[i].pp, 8, "move[" .. i .. "].pp")
			buffer:WriteUnsigned(8, pp)
		end
	end

	local otValue = self:validateForBitWidth(self.ot or self.PlayerData.userId, 33, "OT")
	buffer:WriteUnsigned(33, otValue)

	local item = self:getHeldItem()
	if item and item.num then
		buffer:WriteBool(true)
		local itemNum = self:validateForBitWidth(item.num, 10, "item.num")
		buffer:WriteUnsigned(10, itemNum)
	else
		buffer:WriteBool(false)
	end

	local hasMarking = false
	if self.marking then
		for i = 1, 5 do
			if self.marking[i] then
				hasMarking = true
				break
			end
		end
	end
	buffer:WriteBool(hasMarking)
	if hasMarking then
		for i = 1, 5 do
			buffer:WriteBool(self.marking[i] and true or false)
		end
	end

	local stamps = self.stamps
	if stamps then
		local stampCount = self:validateForBitWidth(#stamps, 2, "stamp count")
		buffer:WriteUnsigned(2, stampCount)
		for _, stamp in pairs(stamps) do
			local sheet = self:validateForBitWidth(stamp.sheet, 4, "stamp.sheet")
			local n = self:validateForBitWidth(stamp.n, 5, "stamp.n")
			local color = self:validateForBitWidth(stamp.color, 5, "stamp.color")
			local style = self:validateForBitWidth(stamp.style, 3, "stamp.style")

			buffer:WriteUnsigned(4, sheet)
			buffer:WriteUnsigned(5, n)
			buffer:WriteUnsigned(5, color)
			buffer:WriteUnsigned(3, style)
		end
	else
		buffer:WriteUnsigned(2, 0)
	end

	return buffer:ToBase64()
end

function Pokemon:deserialize(str, PlayerData)
	local self = {}
	local s,r = pcall(function()
		local buffer = BitBuffer.Create()
		buffer:FromBase64(str)
		local version = buffer:ReadUnsigned(6)
		local inPC = buffer:ReadBool()
		self.num = buffer:ReadUnsigned(version >= 6 and 11 or 10)
		if buffer:ReadBool() then
			self.egg = true
			if version >= 3 and buffer:ReadBool() then
				self.fossilEgg = true
			end
			self.eggCycles = buffer:ReadUnsigned(version >= 3 and 7 or 6)
		end
		self.shiny = buffer:ReadBool()
		if version >= 2 then
			local untradable = buffer:ReadBool()
			if untradable then
				local num = self.num
				if num == 133 or num == 134 or num == 135 or num == 136 or num == 196 or num == 197 or num == 470 or num == 471 or num == 700 then
				else
					self.untradable = true
				end
			end
		end
		self.hiddenAbility = buffer:ReadBool()
		self.swappedAbility = buffer:ReadBool()
		if buffer:ReadBool() then
			local nickname = buffer:ReadString()
			self.nickname = nickname
			spawn(function()
				nickname = Pokemon:filterNickname(nickname, PlayerData.player)
				self.nickname = (nickname ~= '') and nickname or nil
			end)
		end
		if buffer:ReadBool() then
			self.forme = buffer:ReadString()
		end
		self.pokeball = buffer:ReadUnsigned(5)
		self.experience = buffer:ReadUnsigned(21)
		self.personality = buffer:ReadUnsigned(32)
		self.nature = buffer:ReadUnsigned(5)
		self.happiness = buffer:ReadUnsigned(8)
		if version >= 1 then
			if buffer:ReadBool() then
				self.happinessOT = buffer:ReadUnsigned(8)
			end
		end
		self.ivs = {}
		self.evs = {}
		for i = 1, 6 do
			self.ivs[i] = buffer:ReadUnsigned(5)
			self.evs[i] = buffer:ReadUnsigned(8)
		end
		if not inPC then
			self.hp = buffer:ReadUnsigned(10)
			local status = buffer:ReadUnsigned(3)
			if status ~= 0 then
				local statuses = {'brn', 'frz', 'par', 'psn', 'slp1', 'slp2', 'slp3'}
				self.status = statuses[status]
			end
		end
		local moves = {}
		for i = 1, 4 do
			if not buffer:ReadBool() then break end
			moves[i] = {}
			local mnum = buffer:ReadUnsigned(10)
			moves[i].id = getMoveData(mnum).id
			moves[i].ppup = buffer:ReadUnsigned(2)
			if not inPC then
				if version >= 5 then
					moves[i].pp = buffer:ReadUnsigned(8)
				else
					moves[i].pp = buffer:ReadUnsigned(6)
				end
			end
		end
		self.moves = moves
		self.ot = buffer:ReadUnsigned(33)

		if self.ot == 0 and PlayerData.userId > 0 then
			_f.Logger:logError(PlayerData.player, {
				ErrType = "ServerPokemon: Invalid OT",
			})
			self.ot = PlayerData.userId
		end

		local maxOtValue = (2^33) - 1
		if self.ot > maxOtValue then
			warn("Loaded Pokemon with oversized OT: " .. tostring(self.ot) .. ", wrapping to fit")
			self.ot = self.ot % (maxOtValue + 1)
		end

		if buffer:ReadBool() then
			local num = buffer:ReadUnsigned(10)
			if num ~= 0 then
				self.item = num
			end
		end
		if buffer:ReadBool() then
			self.marking = {}
			for i = 1, 5 do
				if buffer:ReadBool() then
					self.marking[i] = true
				end
			end
		end
		if version >= 4 then
			local stamps = {}
			for i = 1, buffer:ReadUnsigned(2) do
				stamps[i] = {
					sheet = buffer:ReadUnsigned(4),
					n     = buffer:ReadUnsigned(5),
					color = buffer:ReadUnsigned(5),
					style = buffer:ReadUnsigned(3)
				}
			end
			if #stamps > 0 then
				self.stamps = stamps
			end
		end
	end)
	if not s then
		_f.Logger:logError(PlayerData.player, {
			ErrType = "Deserialization Error",
			Errors = r
		})
		debug(r, self.player.Name)
		error(r)
		return Pokemon:new({
			egg = false,
			num = 1,
			shiny = false,
			untradable = true,
			hiddenAbility = false,
			swappedAbility = false,
			nickname = "Bad Pokemon",
			pokeball = 1,
			experience = 0,
			personality = math.floor(2^32 * math.random()),
			nature = math.random(25),
			happiness = 0,
			OT = 1,
			ivs = {0,0,0,0,0,0},
			evs = {0,0,0,0,0,0},
			hp = 1,
			moves = {{id='splash',pp=0}},
			stamps = {}
		}, PlayerData)
	end
	return Pokemon:new(self, PlayerData)
end


function Pokemon:destroy()
	self.PlayerData = nil -- remove circular reference
end


return Pokemon