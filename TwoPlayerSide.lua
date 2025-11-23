--NOT NOTES: seems like everything is going GGs except the notmyhalf move bs not sure why I will check it later tho fr
local _f = require(script.Parent.Parent)

local undefined, null, subclass, split, trim, indexOf, Not, deepcopy, toId, shallowcopy; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	undefined = util.undefined
	null = util.null
	subclass = util.subclass
	split = util.split
	trim = util.trim
	indexOf = util.indexOf
	Not = util.Not
	deepcopy = util.deepcopy
	toId = util.toId
	shallowcopy = util.shallowcopy
end

local weightedRandom = require(script.Parent.Parent).Utilities.weightedRandom
local BattlePokemon = require(script.Parent.BattlePokemon)

-- 2v2do: mega evolution for both trainers

local TwoPlayerSide = subclass(require(script.Parent.BattleSide), {
	className = 'TwoPlayerSide',

	isTwoPlayerSide = true,
	isSecondPlayerNpc = false,
}, function(self, player1, player2, battle, n, team1, team2, mg)
	assert(battle.gameType == 'doubles', 'Battle must be of type Double to implement TwoPlayerSide')

	self.battle = battle
	self.n = n
	self.names = {player1.Name, player2.Name}
	self.name = player1.Name .. ' and ' .. player2.Name
	self.pokemon = {}
	self.active = {null, null}
	self.sideConditions = {}

	self.megaAdornment = {}

	if mg and next(mg) ~= nil then
		self.megaAdornment = mg
	end

	pcall(function()
		local bd = _f.PlayerDataService[player1]:getBagDataById('megakeystone', 5)
		if bd and bd.quantity > 0 then
			self.megaAdornment[1] = 'true'
		end
	end)
	pcall(function()
		local bd = _f.PlayerDataService[player2]:getBagDataById('megakeystone', 5)
		if bd and bd.quantity > 0 then
			self.megaAdornment[2] = 'true'
		end
	end)

	self.id = 'p'..n

	--	self.teams = {team1, team2}
	local pl = 0
	for i = 1, math.min(#team1, 6) do
		local p = BattlePokemon:new(nil, team1[i], self)
		p.teamn = 1
		p.canMegaEvo = battle:canMegaEvo(p)
		if battle.is2v2 or not p.index then
			p.index = i
		end
		table.insert(self.pokemon, p)
		p.fainted = p.hp == 0
		if p.hp > 0 then
			pl = pl + 1
		end
	end
	self.nPokemonFromTeam1 = #team1
	local index = #team1
	for i = 1, math.min(#team2, 6) do
		local p = BattlePokemon:new(nil, team2[i], self)
		p.teamn = 2
		p.canMegaEvo = battle:canMegaEvo(p)
		--		if not p.index then
		index = index + 1
		p.index = index
		--		end
		table.insert(self.pokemon, p)
		p.fainted = p.hp == 0
		if p.hp > 0 then
			pl = pl + 1
		end
	end
	self.pokemonLeft = pl--#self.pokemon
	for i = 1, #self.pokemon do
		self.pokemon[i].position = i
	end

	return self
end)

function TwoPlayerSide:toString()
	return self.id .. ': ' .. self.names[1] .. ' & ' .. self.names[2]
end
function TwoPlayerSide:start()
	local function sendOutForTeamN(teamn)
		for i, p in pairs(self.pokemon) do
			if p.hp > 0 and p.teamn == teamn then
				self.battle:switchIn(p, teamn)
				if teamn == 2 then
					local i = p.index
					table.remove(self.pokemon, i)
					table.insert(self.pokemon, 2, p)
				end
				return
			end
		end
	end
	for i = 1, 2 do sendOutForTeamN(i) end
	for i, p in pairs(self.pokemon) do
		p.position = i
	end
end
function TwoPlayerSide:getData(context)
	local data = {
		--		name = self.name,
		id = self.id,
		nActive = 2,
		nTeamActive = 1,
		nTeam1 = self.nPokemonFromTeam1
		--		pokemon = {}
	}
	local indexFix = {}
	local h
	if context == 'switch' then
		h = {}
		data.healthy = h
	end
	for i, pokemon in pairs(self.pokemon) do
		--		if self.battle.is2v2 and pokemon.teamn == 2 then
		--			indexFix[pokemon.index] = i -- - self.nPokemonFromTeam1
		--		else
		indexFix[pokemon.index] = i
		--		end

		if h then h[i] = not pokemon.egg and pokemon.hp > 0 end
--[[		local pp = {}
		for i, m in pairs(pokemon.moveset) do
			pp[i] = m.pp
		end
		table.insert(data.pokemon, {
			ident = pokemon.fullname,
			level = pokemon.level,
			status = pokemon.status,
			hp = pokemon.hp,
			maxhp = pokemon.maxhp,
			active = (pokemon.position <= #self.active),
			moves = pokemon.moves,
			pp = pp,
			item = pokemon.item,
			pokeball = pokemon.pokeball,
			canMegaEvo = pokemon.canMegaEvo and true or false,
			index = pokemon.index,
			isEgg = pokemon.isEgg,
			teamn = pokemon.teamn,
		})]]
	end
	data.indexFix = indexFix
	return data
end
function TwoPlayerSide:getRelevantDataChanges()
	local blackout = false
	if self.isSecondPlayerNpc then
		blackout = true
		for _, p in pairs(self.pokemon) do
			if p.hp > 0 and p.teamn == 1 then
				blackout = false
				break
			end
		end
	end
	return {blackout = blackout}
end
function TwoPlayerSide:canSwitch(position)
	if position then
		for _, pokemon in pairs(self.pokemon) do
			if not pokemon.isActive and not pokemon.fainted and pokemon.teamn == position then
				return true
			end
		end
	else
		for pos, a in pairs(self.active) do
			if a ~= null and a.switchFlag then
				for _, pokemon in pairs(self.pokemon) do
					if not pokemon.isActive and not pokemon.fainted and pokemon.teamn == pos then
						return true
					end
				end
			end
		end
	end
	return false
end
-- inherited
--randomActive
--addSideCondition
--getSideCondition
--removeSideCondition

-- not sure whether these need to be custom
--send
--emitCallback

-- todo (?)
--AIChooseMove

function TwoPlayerSide:AAIChooseMove(request) --Sadly cannot be done so we rely on client  

	if request.requestType ~= 'move' then
		self.battle:debug('non-move request sent to AI foe side')
		return
	end
	local choices = {}

	for n = 1, #request.active do --this should do the trick fr
		local a = request.active[n]
		if a then

			--  warn('\n--------------------------\nN IS 2 OR SMTH\n-----------------------', n)
			--         print('n is 2 W')
			-- get valid moves
			local enabledMoves = {}
			for i, m in pairs(a.moves) do
				if not m.disabled and (not m.pp or m.pp > 0) then
					table.insert(enabledMoves, i)
				end
			end
			-- always Mega-evolve if available
			local mega = ''
			if a.canMegaEvo then
				mega = ' mega'
			end
			local zmove = ''
			if a.canZMove then 
				mega = ' zmov'
			end
			-- if npc trainer, then try to use some logic to decide move
			local move
			local newt = 1 -- for now, assume target is always slot 1 (THIS COULD HILARIOUSLY AFFECT DOUBLES W/ JAKE/TESS) 
			if self.name ~= '#Wild' then
				local s, r = pcall(function()
					local battle = self.battle
					local pokemon = self.active[n] --always assume slot 2 because 2v2s right?
					--       print(pokemon.name , 'POKE NAME')

					newt = math.random(1, #self.foe.active)

					local target = self.foe.active[newt]

					if target == null then target = self.foe.active[2] end
					if target == null then target = self.foe.active[3] end
					if target == null then target = nil end


					-- check for a manually designed strategy
					if pokemon.aiStrategy then
						local trymovenamed = pokemon.aiStrategy(battle, self, pokemon, target)
						if trymovenamed then
							for _, m in pairs(enabledMoves) do
								if pokemon.moves[m] == trymovenamed then
									--								print('ai strategy successful')
									move = m
									break
								end
							end
						end
					end
					-- special Shedinja logic
					if not move and target.ability == 'wonderguard' then
						local superEffectiveMoves = {}
						local nonDamageMoves = {}
						for _, m in pairs(enabledMoves) do
							local moveId = pokemon.moves[m]
							local moveData = battle:getMove(moveId)
							if moveData.baseDamage > 0 then
								local effectiveness = 1
								for _, t in pairs(target:getTypes()) do
									effectiveness = effectiveness * (battle.data.TypeChart[t][moveData.type] or 1)
								end
								if effectiveness > 1 then
									table.insert(superEffectiveMoves, m)
								end
							else
								table.insert(nonDamageMoves, m)
							end
						end
						if #superEffectiveMoves > 0 then
							move = superEffectiveMoves[math.random(#superEffectiveMoves)]
						else
							-- TODO: switch to something that can defeat Shedinja
							move = nonDamageMoves[math.random(#nonDamageMoves)]
						end
					end
					--
					if not move then
						local chance = {0, 0, 0, 0}
						for _, m in pairs(enabledMoves) do
							chance[m] = 1
						end
						local difficulty = self.difficulty or 1
						--					print('difficulty', difficulty)
						local d_alpha = math.max(0, math.min(1, difficulty/4))
						local estDamage = {0, 0, 0, 0}
						for _, m in pairs(enabledMoves) do
							local moveId = pokemon.moves[m]
							local moveData = battle:getMove(moveId)
							-- don't heal if it won't help (excludes absorb etc. that still deal damage)
							if moveData.flags.heal and (not moveData.basePower or moveData.basePower < 1) and pokemon.hp == pokemon.maxhp then
								chance[m] = 0
								-- don't bother setting weather if it's already set
							elseif moveData.weather and battle:isWeather(moveData.weather) then
								chance[m] = 0
							end
							-- avoid known fail states
							if moveId == 'helpinghand' and #self.active < 2 then
								chance[m] = 0
							end
							-- status logic
							if moveData.status and target.status ~= '' then
								chance[m] = target.status=='slp' and .25 or 0
							elseif moveData.status == 'slp' then
								chance[m] = 1 + .01*((tonumber(moveData.accuracy) or 100)-30)
							end
							if moveId == 'spore' and target:hasType('Grass') then
								chance = 0
							end
							-- estimate damage dealt by this move
							local effectiveBaseDamage = moveData.baseDamage or 0
							if effectiveBaseDamage > 0 then
								-- SPECIFICS (for gym leaders, etc)
								if pokemon.ability == 'technician' and effectiveBaseDamage <= 60 then
									effectiveBaseDamage = effectiveBaseDamage * 1.5
								end
								if moveId == 'venoshock' and (target.status == 'psn' or target.status == 'tox') then
									effectiveBaseDamage = effectiveBaseDamage * 2
								end
								-- END SPECIFICS
								-- consider charging moves as being half as powerful
								if moveData.flags.charge and pokemon.item ~= 'powerherb' and not (moveId == 'solarbeam' and battle:isWeather({'sunnyday', 'desolateland'})) then
									effectiveBaseDamage = effectiveBaseDamage / 2
									-- same with recharging moves (unless it's the opponent's last pokemon)
								elseif moveData.flags.recharge and self.foe.pokemonLeft > 1 then
									effectiveBaseDamage = effectiveBaseDamage / 2
								end
								-- factor in move's accuracy
								if type(moveData.accuracy) == 'number' then
									effectiveBaseDamage = effectiveBaseDamage * 100 / moveData.accuracy
								end
								-- factor in crit chance
								if moveData.willCrit then
									effectiveBaseDamage = effectiveBaseDamage * 1.5
								elseif moveData.critRatio and moveData.critRatio > 1 then
									effectiveBaseDamage = effectiveBaseDamage * (1.5 / (({16, 8, 2, 1})[math.min(4, moveData.critRatio)]))
								end
								-- factor in STAB
								if pokemon:hasType(moveData.type) then
									effectiveBaseDamage = effectiveBaseDamage * (moveData.stab or 1.5)
								end

								if target then
									local minDamage, maxDamage
									if moveData.damage == 'level' then
										minDamage, maxDamage = pokemon.level, pokemon.level
									elseif moveData.damage then
										minDamage, maxDamage = moveData.damage, moveData.damage
									else
										local category = battle:getCategory(moveData)
										local defensiveCategory = moveData.defensiveCategory or category

										local level = pokemon.level

										local attackStat = (category == 'Physical') and 'atk' or 'spa'
										local defenseStat = (defensiveCategory == 'Physical') and 'def' or 'spd'
										local statTable = {atk='Atk', def='Def', spa='SpA', spd='SpD', spe='Spe'}
										local attack, defense

										local atkBoosts = moveData.useTargetOffensive and target.boosts[attackStat]   or pokemon.boosts[attackStat]
										local defBoosts = moveData.useSourceDefensive and pokemon.boosts[defenseStat] or target.boosts[defenseStat]
										if moveData.ignoreOffensive or (moveData.ignoreNegativeOffensive and atkBoosts < 0) then atkBoosts = 0 end
										if moveData.ignoreDefensive or (moveData.ignorePositiveDefensive and defBoosts > 0) then defBoosts = 0 end

										if moveData.useTargetOffensive then attack = target:calculateStat(attackStat, atkBoosts)
										else attack = pokemon:calculateStat(attackStat, atkBoosts) end

										if moveData.useSourceDefensive then defense = pokemon:calculateStat(defenseStat, defBoosts)
										else defense = target:calculateStat(defenseStat, defBoosts) end

										local effectiveness = 1
										for _, t in pairs(target:getTypes()) do
											effectiveness = effectiveness * (battle.data.TypeChart[t][moveData.type] or 1)
										end
										local maxDamage = math.floor(math.floor(math.floor(2 * level / 5 + 2) * effectiveBaseDamage * attack / defense) / 50) + 2
										maxDamage = math.floor(maxDamage * effectiveness)
										local minDamage = math.floor(.85 * maxDamage)
									end
									estDamage[m] = maxDamage + (minDamage-maxDamage)*d_alpha
								end
							end
						end
						-- check if there are moves that can (estimatedly) KO the opponent
						local movesThatCouldKO = {}
						local hp = target.hp
						for _, m in pairs(enabledMoves) do
							if estDamage[m] > hp then
								table.insert(movesThatCouldKO, m)
							end
						end
						if #movesThatCouldKO > 0 and math.random(4) < difficulty+1 then
							if #movesThatCouldKO > 1 then
								-- sort
								-- for now, it only bases it on what has most PP
								table.sort(movesThatCouldKO, function(a, b)
									return pokemon.moveset[a].pp > pokemon.moveset[b].pp
								end)
							end
							move = movesThatCouldKO[1]
						end
						-- set damaging moves' chances
						for _, m in pairs(enabledMoves) do
							if estDamage[m] > 0 then
								local pko = estDamage[m]/hp
								chance[m] = math.max(0, (pko-.25)*4+1)
							end
						end
						-- choose random move based on determined chance
						for _, c in pairs(chance) do
							-- make sure there is at least one value > 0
							if c > 0 then
								move = weightedRandom({1, 2, 3, 4}, function(i) return chance[i] end)
								break
							end
						end
						-- if selected move is Solar Beam AND you know Sunny Day AND it's not already sunny, USE Sunny Day!
						if pokemon.moves[move] == 'solarbeam' and not battle:isWeather({'sunnyday', 'desolateland'}) then
							for _, m in pairs(enabledMoves) do
								if pokemon.moves[m] == 'sunnyday' then
									move = m
								end
							end
						end
						-- TODO: detect when you can't damage opponent and switch pokemon

					end
				end)
				if not s then print('NPC Battle AI encountered error:', r) end
			end
			-- default to random move if nothing else
			if not move then
				move = enabledMoves[math.random(#enabledMoves)]
			end
			--
			choices[1] = 'pass'
			choices[n] = 'move '..move..newt --mega -- should do the trick tho i need to test "mega"
			print(choices[n])
		end 
	end

	print(choices)

	self.battle:choose(nil, self.id, choices, self.battle.rqid)
end
function TwoPlayerSide:AIForceSwitch(request)
	local alreadySwitched = {}
	local function getValidPokemonIndex()
		for i, p in pairs(self.pokemon) do
			if not alreadySwitched[i] and not p.isActive and p.hp > 0 then
				return i
			end
		end
	end

	local fs = request.forceSwitch
	local choices = {}
	for i = 1, #fs do
		if fs[i] then
			local s = getValidPokemonIndex()
			if s then
				choices[i] = 'switch '..s
				alreadySwitched[s] = true
			else
				choices[i] = 'pass'
			end
		else
			choices[i] = 'pass'
		end
	end

	self.battle:choose(nil, self.id, choices, self.battle.rqid)
end

function TwoPlayerSide:emitRequest(request)
	local sendToTeam1, sendToTeam2 = true, true
	if request.forceSwitch or request.foeAboutToSendOut then
		request.requestType = 'switch'
		if (self.active[1] ~= null and not self.active[1].fainted and not self.active[1].switchFlag) or not self:canSwitch(1) then
			sendToTeam1 = false
		end
		if (self.active[2] ~= null and not self.active[2].fainted and not self.active[2].switchFlag) or not self:canSwitch(2) then
			sendToTeam2 = false
		end
	elseif request.teamPreview then
		request.requestType = 'team'
	elseif request.wait then
		request.requestType = 'wait'
	elseif request.active then
		request.requestType = 'move'
	end

	if self.battle.isTrainer and self.n == 1 then--and self.n == 1 then
		if request.requestType == 'switch' then --this will overwrite the norm bs
			self:AIForceSwitch(request)
			--elseif request.requestType == 'move' then --NOT NOTES: it only makes decision for 2 and if I leave 1 emtpy it will return empty sooo
			--    self:AIChooseMove(request)
			return
		end   
	end

	local d = self.battle:getDataForTransferToPlayer(self.id, true)
	if d and #d > 0 then
		request.qData = d
	end
	if sendToTeam1 then
		self.battle:sendToPlayer(self.id, 'request', self.id, self.battle.rqid, request)
	else
		local r = shallowcopy(request)
		r.requestType = 'wait'
		self.battle:sendToPlayer(self.id, 'request', self.id, self.battle.rqid, r)
	end
	if sendToTeam2 then
		self.battle:sendToPlayer('p'..(self.n+2), 'request', self.id, self.battle.rqid, request)
	else
		local r = shallowcopy(request)
		r.requestType = 'wait'
		self.battle:sendToPlayer('p'..(self.n+2), 'request', self.id, self.battle.rqid, r)
	end
end

function TwoPlayerSide:destroy()
	-- deallocate ourself

	-- deallocate children and get rid of references to them
	for i = 1, #self.pokemon do
		if self.pokemon[i] then self.pokemon[i]:destroy() end
		self.pokemon[i] = nil
	end
	self.pokemon = nil
	for i = 1, #self.active do
		self.active[i] = nil
	end
	self.active = nil

	if self.decision and self.decision ~= true then
		self.decision.side = nil
		self.decision.pokemon = nil
	end
	self.decision = nil

	-- get rid of some possibly-circular references
	self.battle = nil
	self.foe = nil
end

return TwoPlayerSide