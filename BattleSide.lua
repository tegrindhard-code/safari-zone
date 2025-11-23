local undefined, null, class, jsonEncode; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	undefined = util.undefined
	null = util.null
	class = util.class
	Not = util.Not
	jsonEncode = util.jsonEncode
	shallowcopy = util.shallowcopy
end

local weightedRandom = require(script.Parent.Parent).Utilities.weightedRandom

local BattlePokemon = require(script.Parent.BattlePokemon)
local _debug = game:GetService("RunService"):IsStudio()
local function dprint(...)
	if _debug then print(...) end
end

local BattleSide = class({
	className = 'BattleSide',

	isActive = false,
	pokemonLeft = 0,
	faintedLastTurn = false,
	faintedThisTurn = false,
	totalFainted = 0,
	currentRequest = '',
	--	decision = nil,
	--	foe = nil,
	--	megaAdornment = nil,

}, function(self, name, battle, n, team, megaAdornment)
	self.battle = battle
	self.n = n
	self.name = name
	self.megaAdornment = megaAdornment
	self.pokemon = {}
	self.active = {null}
	self.totalFained = 0
	self.sideConditions = {}

	self.id = 'p'..n

	if battle.gameType == 'doubles' then
		self.active = {null, null}
	elseif battle.gameType == 'triples' or battle.gameType == 'rotation' then
		self.active = {null, null, null}
	end

	--	self.team = team
	local pl = 0
	for i = 1, math.min(#team, 6) do
		local p = BattlePokemon:new(nil, team[i], self)
		if not p.index then
			p.index = i
		end
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

function BattleSide:toString()
	return self.id .. ': ' .. self.name
end
function BattleSide:start()
	local pos = 1
	for i, p in pairs(self.pokemon) do
		if p.hp > 0 then
			self.battle:switchIn(p, pos)
			pos = pos + 1
			if pos > #self.active then break end
		end
	end
end
function BattleSide:getData(context) -- for pokemon in request.side (for request.active, see BattlePokemon:getRequestData())
	local data = {
		--		name = self.name,
		id = self.id,
		nActive = #self.active,
		--		pokemon = {}
	}
	if context == 'switch' then
		local h = {}
		data.healthy = h
		for i, pokemon in pairs(self.pokemon) do
			h[i] = not pokemon.egg and pokemon.hp > 0
			--			local pp = {}
			--			for i, m in pairs(pokemon.moveset) do
			--				pp[i] = m.pp
			--			end
			--			table.insert(data.pokemon, {
			--				ident = pokemon.fullname,
			--				level = pokemon.level,
			--				status = pokemon.status,
			--				hp = pokemon.hp,
			--				maxhp = pokemon.maxhp,
			--				active = (pokemon.position <= #self.active),
			--				moves = pokemon.moves,
			--				pp = pp,
			--				item = pokemon.item,
			--				pokeball = pokemon.pokeball,
			--				index = pokemon.index,
			--				isEgg = pokemon.isEgg,
			--			})
		end
	end
	return data
end
function BattleSide:getRelevantDataChanges() -- for post-battle updates
	local data = {
		pokemon = {}
	}
	if self.battle.pvp then return data end
	for i, pokemon in pairs(self.pokemon) do
		local d = {
			hp = pokemon.hp,
			status = pokemon.status,
			moves = {},
			index = pokemon.index,
			evs = {pokemon.evs.hp, pokemon.evs.atk, pokemon.evs.def, pokemon.evs.spa, pokemon.evs.spd, pokemon.evs.spe},
		}
		if pokemon.statusData and pokemon.statusData.time then
			if pokemon.statusData.time <= 0 then
				d.status = nil
			else
				d.status = d.status .. math.min(3, pokemon.statusData.time)
			end
		end
		for i, move in pairs(pokemon.moveset) do
			d.moves[i] = {
				id = move.move,
				pp = move.pp,
			}
		end
		table.insert(data.pokemon, d)
	end
	return data
end
function BattleSide:canSwitch()
	for _, pokemon in pairs(self.pokemon) do
		if not pokemon.isActive and not pokemon.fainted then
			return true
		end
	end
	return false
end
function BattleSide:randomActive()
	local actives = {}
	for _, p in pairs(self.active) do
		if p ~= null and not p.fainted then
			table.insert(actives, p)
		end
	end
	if #actives == 0 then return null end
	return actives[math.random(#actives)]
end
function BattleSide:addSideCondition(status, source, sourceEffect)
	status = self.battle:getEffect(status)
	if self.sideConditions[status.id] then
		if not status.onRestart then return false end
		return self.battle:singleEvent('Restart', status, self.sideConditions[status.id], self, source, sourceEffect)
	end
	self.sideConditions[status.id] = {id = status.id, target = self}
	if source then
		self.sideConditions[status.id].source = source
		self.sideConditions[status.id].sourcePosition = source.position
	end
	if status.duration then
		self.sideConditions[status.id].duration = status.duration
	end
	if status.durationCallback then
		self.sideConditions[status.id].duration = self.battle:call(status.durationCallback, self, source, sourceEffect)
	end
	if not self.battle:singleEvent('Start', status, self.sideConditions[status.id], self, source, sourceEffect) then
		self.sideConditions[status.id] = nil
		return false
	end
	self.battle:update()
	return true
end
function BattleSide:getSideCondition(status)
	status = self.battle:getEffect(status)
	if not self.sideConditions[status.id] then return null end
	return status
end
function BattleSide:removeSideCondition(status)
	status = self.battle:getEffect(status)
	if not self.sideConditions[status.id] then return false end
	self.battle:singleEvent('End', status, self.sideConditions[status.id], self)
	self.sideConditions[status.id] = nil
	self.battle:update()
	return true
end
function BattleSide:send(...)
	local sideUpdate = {...}
	for i, su in pairs(sideUpdate) do
		if type(su) == 'function' then
			sideUpdate[i] = su(self)
		end
	end
	self.battle:send('sideupdate', self.id, unpack(sideUpdate))
end
function BattleSide:emitCallback(...)
	-- todo: what about when an npc trainer receives this request
	if self.name == '#Wild' then
		--		require(game.ReplicatedStorage.Utilities).print_r({...})
		return
	end
	self.battle:sendToPlayer(self.id, 'callback', self.id, ...)
end
function BattleSide:getDifficulty()
	if _debug then return 6 end
	return self.difficulty or 1
end
function BattleSide:AIChooseMove(request)
	if request.requestType ~= 'move' then
		self.battle:debug('non-move request sent to AI foe side')
		return
	end
	
	local choices = {}
	
	for n, a in pairs(request.active) do
		local pokemon = self.active[n]
		local enabledMoves = pokemon:getEnabledMoves()
		local battle = self.battle
		local move, mega = nil, ''
		
		-- determine mega/zmove
		if a.canMegaEvo then
			mega = ' mega'
		elseif a.canZMove then
			mega = ' zmov'
		end
		
		local chance = {}
		for _, m in pairs(enabledMoves) do
			chance[m] = 0
		end
		
		if self.name ~= '#Wild' then
			local s, r = pcall(function()
				-- try slot 1 first, fallback for double battle
				local target = self.foe.active[1] or self.foe.active[2] or self.foe.active[3]
				if not target or target == null then return end

				-- Manual AI Strategy callback
				if pokemon.aiStrategy then
					local chosenName = pokemon.aiStrategy(battle, self, pokemon, target)
					if chosenName then
						for _, m in pairs(enabledMoves) do
							if pokemon.moves[m] == chosenName and not pokemon:pranksterCheck(chosenName, target) then
								move = m
								break
							end
						end
					end
				end

				-- Shedinja/Wonder Guaed Clause
				if not move and target:hasAbility('wonderguard') then
					local superEffective, fallbackMoves = {}, {}
					for _, m in pairs(enabledMoves) do
						local moveData = battle:getMoveCopy(pokemon.moves[m])
						if moveData.basePower and moveData.basePower > 0 then
							local effectiveness = 1
							for _, t in pairs(target:getTypes()) do
								effectiveness *= (battle.data.TypeChart[t][moveData.type] or 1)
							end
							if effectiveness > 1 then
								table.insert(superEffective, m)
							end
						else
							table.insert(fallbackMoves, m)
						end
					end
					if #superEffective > 0 then
						move = superEffective[math.random(#superEffective)]
					else
						move = fallbackMoves[math.random(#fallbackMoves)]
					end
				end

				-- advanced ai logic
			--[[	if not move then
					-- define variables and tables
					local priorityMoves = {
						"quickattack", "aquajet", "extremespeed", "jetpunch", "accelerock",
						"bulletpunch", "iceshard", "machpunch", "shadowsneak", "suckerpunch",
						"vacuumwave", "watershuriken", "feint", "zippyzap"
					}
					local healMoves = {
						"healorder", "milkdrink", "moonlight", "morningsun", "recover",
						"roost", "shoreup", "slackoff", "softboiled", "strengthsap", "synthesis"
					}
					local setupMoves = {
						"bulkup", "swordsdance", "honeclaws", "dragondance", "nastyplot",
						"calmmind", "coil", "quiverdance", "shellsmash", "tailglow", "geomancy",
						"growth", "agility", "rockpolish", "workup", "curse", "bellydrum",
						"shiftgear", "irondefense", "victorydance"
					}
					local contraryMoves = {
						"armorcannon", "closecombat", "leafstorm", "makeitrain", "overheat",
						"spinout", "superpower", "vcreate"
					}
					
					-- function to compute est dmg
					local function getEstimatedDamage(m)
						local moveData = battle:getMoveCopy(pokemon.moves[m])
						moveData = battle:runEvent('ModifyMove', pokemon, target, move, moveData)
						local damage = battle:getDamage(pokemon, target, moveData, true) or 0
						local hitRes = battle:runEvent('Try', moveData, nil, pokemon, target, moveData)
						if Not(hitRes) and not (moveData.id == 'suckerpunch' and not Not(target.lastMOve) and battle:getMoveCopy(target.lastMove).category ~= 'Status') then
							damage = 0
						end
						if moveData.multihit then
							damage = damage * (type(moveData.multihit) == 'table' and moveData.multihit[1] or moveData.multihit)
						end
						if moveData.flags.charge and not pokemon:hasItem('powerherp') and not (
							(battle:isWeather({'desolateland', 'sunnyday'}) and (moveData.id == 'solarbeam' or moveData.id == 'solarblade')) or
							(battle:isWeather({'primordialsea', 'raindance'}) and moveData.id == 'electroshot')
						) then
							damage /= 1.5
						end
						if moveData.flags.recharge and self.foe.pokemonLeft > 1 then
							damage /= 2
						end
						if table.find(contraryMoves, moveData.id) and not pokemon:hasAbility('contrary') and pokemon.hp > pokemon.maxhp / 2 then
							damage /= 2
						end
						if moveData.priority > 0 and battle:isTerrain('psychicterrain') then
							damage = 0
						end
						if pokemon.activeTurns >= 2 and (moveData.id == 'firstimpression' or moveData.id == 'fakeout') then
							damage = 0
						end
						
						return moveData, damage
					end
					
					-- priorty KO clause
					for _, v in pairs(pokemon:getEnabledMoves()) do
						local moveData, damage = getEstimatedDamage(v)
						if table.find(priorityMoves, moveData.id) and not battle:isTerrain('psychicterrain') and (
							damage > target.hp or (pokemon.hp < pokemon.maxhp / 4 and damage > 0)
						) then
							move = v
							break
						end
					end
					
					-- Outspeed KO clause
					if not move then
						for _, v in pairs(pokemon:getEnabledMoves()) do
							local _, damage = getEstimatedDamage(v)
							if damage >= target.hp and pokemon:getStat('spe') > target:getStat('spe') and not battle:getPseudoWeather('trickroom') then
								move = v
								break
							end
						end
					end
					
					-- Hard Switch
					if not move and target.lastMove ~= '' and self.pokemonLeft > 1 and pokemon.hp <= pokemon.maxhp * .6 and not pokemon.trapped and pokemon.activeTurns > 1 and pokemon:positiveBoosts() < 2 then
						self.switchQueue[n] = self.active[n]
						if self:AIChooseSwitch(choices, target) then
							return 'switch'
						end
					end
					
					-- Heal / Pivot / Boom clause
					if not move and pokemon.hp <= pokemon.maxhp / 2 then
						for _, v in pairs(pokemon:getEnabledMoves()) do
							local moveData = battle:getMoveCopy(pokemon.moves[v])
							if (moveData.heal and moveData.heal[1] == 1 and moveData.heal[2] == 2) or table.find(healMoves, moveData.id) then
								move = v
								break
							elseif moveData.selfSwitch and self.pokemonLeft > 2 and not pokemon:pranksterCheck(moveData, target) then
								move = v
								break
							elseif moveData.basePower > 0 and moveData.selfdestruct and self.pokemonLeft > 1 then
								move = v
								break
							end
						end
					end
					
					-- Setup clause
					if not move and pokemon.activeTurns <= 1 and pokemon.hp > pokemon.maxhp / 1.5 then
						for _, v in pairs(pokemon:getEnabledMoves()) do
							local moveData = battle:getMoveCopy(pokemon.moves[v])
							if table.find(setupMoves, moveData.id) then
								move = v
								break
							end
						end
					end
					
					-- Status clause
					if not move and target.activeTurns <= 2 and target.status == '' and not (pokemon:hasAbility('prankster') and target:hasType('Dark')) and pokemon.hp > pokemon.maxhp / 1.5 then
						for _, v in pairs(pokemon:getEnabledMoves()) do
							local moveData = battle:getMoveCopy(pokemon.moves[v])
							if (not target:hasType('Grass') and (moveData.id == 'spore' or moveData.id == 'sleeppowder')) or (target:hasType('Grass') and moveData.id == 'darkvoid') then
								move = v
								break
							elseif (pokemon:hasAbility('corrosion') or not target:hasType({'Poison', 'Steel'})) and moveData.id == 'toxic' then
								move = v
								break
							elseif not target:hasType('Fire') and moveData.id == 'willowisp' then
								move = v
								break
							elseif not target:hasType({'Electric', 'Ground'}) and (moveData.id == 'glare' or moveData.id == 'thunderwave') then
								move = v
								break
							end
						end
					end
					
					-- KO / Highest dmg clause
					if not move then
						local maxPPMove, maxPP, maxDamageMove, maxDamage = nil, 0, nil, 0
						local chance, estDamage = {}, {}
						
						for _, v in pairs(pokemon:getEnabledMoves()) do chance[v] = 1 end
						
						for _, v in pairs(pokemon:getEnabledMoves()) do
							local moveData, damage = getEstimatedDamage(v)
							estDamage[v] = damage
							if damage > 0 then
								local pko = damage / target.hp
								chance[v] = math.max(0, (pko - .25) * 4 + 1)
								if damage >= target.hp and moveData.pp > maxPP then
									maxPP = moveData.pp
									maxPPMove = v
								end
								if damage > maxDamage then
									maxDamage = damage
									maxDamageMove = v
								end
							else
								chance[v] = 0
							end
						end
						
						if maxPPMove then
							move = maxPPMove
						elseif maxDamageMove then
							move = maxDamageMove
						else
							for _, v in pairs(pokemon:getEnabledMoves()) do
								if chance[v] and (not move or chance[v] > chance[move]) then
									move = v
								end
							end
						end
					end
				end ]]
			end)
			if not s then print('NPC Battle AI encountered error:', r, debug.traceback()) end
			if r == 'switch' then return end
		end

		if not move then
			local moveLength = #enabledMoves
			move = enabledMoves[math.random(moveLength > 0 and moveLength or 1)] or 1
		end

		-- Prevent invalid Z-Moves
		if mega:find('zmov') then
			local pokemon = self.active[n]
			local moveCopy = self.battle.data.Movedex[pokemon:getMoves()[move].id] -- Ugliest move fetching ever
			local item = pokemon:getItem()
			if item.zMoveType ~= moveCopy.type then
				mega = ''
			end
		end

		choices[n] = 'move ' .. move .. mega
	end
	--print(choices)
	self.battle:choose(nil, self.id, choices, self.battle.rqid)
end
function BattleSide:AIForceSwitch(request)
	--	require(game.ReplicatedStorage.Utilities).print_r(request)
	--	for i, p in pairs(self.pokemon) do
	--		if not p.isActive and p.hp > 0 then
	--			self.battle:choose(nil, self.id, {'switch '..i}, self.battle.rqid)
	--			return
	--		end
	--	end

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
	--	require(game.ReplicatedStorage.Utilities).print_r(choices)
	self.battle:choose(nil, self.id, choices, self.battle.rqid)
end
function BattleSide:emitRequest(request)
	if request.forceSwitch or request.foeAboutToSendOut then
		request.requestType = 'switch'
	elseif request.teamPreview then
		request.requestType = 'team'
	elseif request.wait then
		request.requestType = 'wait'
	elseif request.active then
		request.requestType = 'move'
	end
	if (self.name == '#Wild' or self.battle.isTrainer) and self.n == 2 then
		if request.requestType == 'move' then
			self:AIChooseMove(request)
		elseif request.requestType == 'switch' then
			self:AIForceSwitch(request)
		else
			--			print('NOTICE: battle ai received request of type:', request.requestType)
		end
		return
	end
	local d = self.battle:getDataForTransferToPlayer(self.id, true)
	if d and #d > 0 then
		request.qData = d
	end
	self.battle:sendToPlayer(self.id, 'request', self.id, self.battle.rqid, request)
end
function BattleSide:resolveDecision()
	if self.decision then
		--		self.battle:debug('decision resolved previously: auto-returning')
		return self.decision
	end
	local decisions = {}

	local cr = self.currentRequest
	self.battle:debug('resolving:', cr)
	if cr == 'move' then
		for _, pokemon in pairs(self.active) do
			if pokemon ~= null and not pokemon.fainted then
				local lockedMove = pokemon:getLockedMove()
				if lockedMove then
					table.insert(decisions, {
						choice = 'move',
						pokemon = pokemon,
						targetLoc = self.battle:runEvent('LockMoveTarget', pokemon) or 0,
						move = lockedMove
					})
				else
					local moveid = 'struggle'
					for _, m in pairs(pokemon:getMoves()) do
						if not m.disabled then
							moveid = m.id
							break
						end
					end
					table.insert(decisions, {
						choice = 'move',
						pokemon = pokemon,
						targetLoc = 0,
						move = moveid
					})
				end
			end
		end
	elseif cr == 'switch' then
		local canSwitchOut = {}
		for i, pokemon in pairs(self.active) do
			if pokemon ~= null and pokemon.switchFlag then
				table.insert(canSwitchOut, i)
			end
		end

		local canSwitchIn = {}
		for i = #self.active+1, #self.pokemon do
			if self.pokemon[i] ~= null and not self.pokemon[i].fainted then
				table.insert(canSwitchIn, i)
			end
		end

		--		local willPass = canSwitchOut.splice(math.min(#canSwitchOut, #canSwitchIn))
		for i, s in pairs(canSwitchOut) do
			table.insert(decisions, {
				choice = self.foe.currentRequest == 'switch' and 'instaswitch' or 'switch',
				pokemon = self.active[s],
				target = self.pokemon[canSwitchIn[i]]
			})
		end
		for i = math.min(canSwitchOut, canSwitchIn), canSwitchOut do
			table.insert(decisions, {
				choice = 'pass',
				pokemon = self.active[canSwitchOut[i]],
				priority = 102
			})
		end
	elseif cr == 'teampreview' then
		local team = {}
		for i = 1, #self.pokemon do
			team[i] = i
		end
		table.insert(decisions, {
			choice = 'team',
			side = self,
			team = team
		})
	end
	return decisions
end
function BattleSide:destroy()
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



return BattleSide