return function(_p)--local _p = require(script.Parent)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write
	local storage = game:GetService('ReplicatedStorage')
	local ContextActionService = game:GetService("ContextActionService")

	local hmMoveIds = {cut=true, surf=true, fly=true, rockclimb=true, rocksmash=true}
	local moveAnims = require(script.MoveAnimations)(_p)
	local Tools = require(script.Parent.Battle.Tools)

	local BattleGui = {
		moveAnimations = moveAnims
	}
	local roundedFrame, Menu; function BattleGui:init()
		roundedFrame = _p.RoundedFrame
		Menu = _p.Menu
	end
	local pname
	local state
	local gui = {}

	local SUPER_EFFECTIVE = 2
	local NOT_VERY_EFFECTIVE = 0.5
	local DOES_NOT_AFFECT = 0

	local typeChart = {
		Bug = {
			Fighting = NOT_VERY_EFFECTIVE,
			Fire = SUPER_EFFECTIVE,
			Flying = SUPER_EFFECTIVE,
			Grass = NOT_VERY_EFFECTIVE,
			Ground = NOT_VERY_EFFECTIVE,
			Rock = SUPER_EFFECTIVE,
		},
		Dark = {
			Bug = SUPER_EFFECTIVE,
			Dark = NOT_VERY_EFFECTIVE,
			Fairy = SUPER_EFFECTIVE,
			Fighting = SUPER_EFFECTIVE,
			Ghost = NOT_VERY_EFFECTIVE,
			Psychic = DOES_NOT_AFFECT,
		},
		Dragon = {
			Dragon = SUPER_EFFECTIVE,
			Electric = NOT_VERY_EFFECTIVE,
			Fairy = SUPER_EFFECTIVE,
			Fire = NOT_VERY_EFFECTIVE,
			Grass = NOT_VERY_EFFECTIVE,
			Ice = SUPER_EFFECTIVE,
			Water = NOT_VERY_EFFECTIVE,
		},
		Electric = {
			par = DOES_NOT_AFFECT,

			Electric = NOT_VERY_EFFECTIVE,
			Flying = NOT_VERY_EFFECTIVE,
			Ground = SUPER_EFFECTIVE,
			Steel = NOT_VERY_EFFECTIVE,
		},
		Fairy = {
			Bug = NOT_VERY_EFFECTIVE,
			Dark = NOT_VERY_EFFECTIVE,
			Dragon = DOES_NOT_AFFECT,
			Fighting = NOT_VERY_EFFECTIVE,
			Poison = SUPER_EFFECTIVE,
			Steel = SUPER_EFFECTIVE,
		},
		Fighting = {
			Bug = NOT_VERY_EFFECTIVE,
			Dark = NOT_VERY_EFFECTIVE,
			Fairy = SUPER_EFFECTIVE,
			Flying = SUPER_EFFECTIVE,
			Psychic = SUPER_EFFECTIVE,
			Rock = NOT_VERY_EFFECTIVE,
		},
		Fire = {
			brn = DOES_NOT_AFFECT,

			Bug = NOT_VERY_EFFECTIVE,
			Fairy = NOT_VERY_EFFECTIVE,
			Fire = NOT_VERY_EFFECTIVE,
			Grass = NOT_VERY_EFFECTIVE,
			Ground = SUPER_EFFECTIVE,
			Ice = NOT_VERY_EFFECTIVE,
			Rock = SUPER_EFFECTIVE,
			Steel = NOT_VERY_EFFECTIVE,
			Water = SUPER_EFFECTIVE,
		},
		Flying = {
			Bug = NOT_VERY_EFFECTIVE,
			Electric = SUPER_EFFECTIVE,
			Fighting = NOT_VERY_EFFECTIVE,
			Grass = NOT_VERY_EFFECTIVE,
			Ground = DOES_NOT_AFFECT,
			Ice = SUPER_EFFECTIVE,
			Rock = SUPER_EFFECTIVE,
		},
		Ghost = {
			trapped = DOES_NOT_AFFECT,

			Bug = NOT_VERY_EFFECTIVE,
			Dark = SUPER_EFFECTIVE,
			Fighting = DOES_NOT_AFFECT,
			Ghost = SUPER_EFFECTIVE,
			Normal = DOES_NOT_AFFECT,
			Poison = NOT_VERY_EFFECTIVE,
		},
		Grass = {
			powder = DOES_NOT_AFFECT,

			Bug = SUPER_EFFECTIVE,
			Electric = NOT_VERY_EFFECTIVE,
			Fire = SUPER_EFFECTIVE,
			Flying = SUPER_EFFECTIVE,
			Grass = NOT_VERY_EFFECTIVE,
			Ground = NOT_VERY_EFFECTIVE,
			Ice = SUPER_EFFECTIVE,
			Poison = SUPER_EFFECTIVE,
			Water = NOT_VERY_EFFECTIVE,
		},
		Ground = {
			sandstorm = DOES_NOT_AFFECT,

			Electric = DOES_NOT_AFFECT,
			Grass = SUPER_EFFECTIVE,
			Ice = SUPER_EFFECTIVE,
			Poison = NOT_VERY_EFFECTIVE,
			Rock = NOT_VERY_EFFECTIVE,
			Water = SUPER_EFFECTIVE,
		},
		Ice = {
			hail = DOES_NOT_AFFECT,
			frz = DOES_NOT_AFFECT,

			Fighting = SUPER_EFFECTIVE,
			Fire = SUPER_EFFECTIVE,
			Ice = NOT_VERY_EFFECTIVE,
			Rock = SUPER_EFFECTIVE,
			Steel = SUPER_EFFECTIVE,
		},
		Normal = {
			Fighting = SUPER_EFFECTIVE,
			Ghost = DOES_NOT_AFFECT,
		},
		Poison = {
			psn = DOES_NOT_AFFECT,
			tox = DOES_NOT_AFFECT,

			Bug = NOT_VERY_EFFECTIVE,
			Fairy = NOT_VERY_EFFECTIVE,
			Fighting = NOT_VERY_EFFECTIVE,
			Grass = NOT_VERY_EFFECTIVE,
			Ground = SUPER_EFFECTIVE,
			Poison = NOT_VERY_EFFECTIVE,
			Psychic = SUPER_EFFECTIVE,
		},
		Psychic = {
			Bug = SUPER_EFFECTIVE,
			Dark = SUPER_EFFECTIVE,
			Fighting = NOT_VERY_EFFECTIVE,
			Ghost = SUPER_EFFECTIVE,
			Psychic = NOT_VERY_EFFECTIVE,
		},
		Rock = {
			sandstorm = DOES_NOT_AFFECT,

			Fighting = SUPER_EFFECTIVE,
			Fire = NOT_VERY_EFFECTIVE,
			Flying = NOT_VERY_EFFECTIVE,
			Grass = SUPER_EFFECTIVE,
			Ground = SUPER_EFFECTIVE,
			Normal = NOT_VERY_EFFECTIVE,
			Poison = NOT_VERY_EFFECTIVE,
			Steel = SUPER_EFFECTIVE,
			Water = SUPER_EFFECTIVE,
		},
		Steel = {
			psn = DOES_NOT_AFFECT,
			tox = DOES_NOT_AFFECT,
			sandstorm = DOES_NOT_AFFECT,

			Bug = NOT_VERY_EFFECTIVE,
			Dragon = NOT_VERY_EFFECTIVE,
			Fairy = NOT_VERY_EFFECTIVE,
			Fighting = SUPER_EFFECTIVE,
			Fire = SUPER_EFFECTIVE,
			Flying = NOT_VERY_EFFECTIVE,
			Grass = NOT_VERY_EFFECTIVE,
			Ground = SUPER_EFFECTIVE,
			Ice = NOT_VERY_EFFECTIVE,
			Normal = NOT_VERY_EFFECTIVE,
			Poison = DOES_NOT_AFFECT,
			Psychic = NOT_VERY_EFFECTIVE,
			Rock = NOT_VERY_EFFECTIVE,
			Steel = NOT_VERY_EFFECTIVE,
		},
		Water = {
			Electric = SUPER_EFFECTIVE,
			Fire = NOT_VERY_EFFECTIVE,
			Grass = SUPER_EFFECTIVE,
			Ice = NOT_VERY_EFFECTIVE,
			Steel = NOT_VERY_EFFECTIVE,
			Water = NOT_VERY_EFFECTIVE,
		},
	}

	local typeColors = {
		Bug = Color3.new(.54, .69, .2),
		Dark = Color3.new(.44, .33, .25),
		Dragon = Color3.new(.44, .4, .9),
		Electric = Color3.new(1, 1, .4),
		Fairy = Color3.new(.92, .45, .92),
		Fighting = Color3.new(.65, .32, .26),
		Fire = Color3.new(.95, .26, .12),
		Flying = Color3.new(.55, .8, 1),
		Ghost = Color3.new(.5, 0, 1),
		Grass = Color3.new(.4, 1, .4),
		Ground = Color3.new(.65, .51, .2),
		Ice = Color3.new(.4, 1, 1),
		Normal = Color3.new(.85, .85, .85),
		Poison = Color3.new(.8, .4, 1),
		Psychic = Color3.new(1, .44, .81),
		Rock = Color3.new(.66, .47, .23),
		Steel = Color3.new(.4, .4, .4),
		Water = Color3.new(0, .5, 1),
		Crystal = Color3.new(0, .75, 1), --1,0,1
	}
	BattleGui.typeColors = typeColors
	function BattleGui:animWeather(weather)
		--print('Weather is: ', weather)
		local i, a, v
		local mo = 0.9
		if weather == 'raindance' or weather == 'primordialsea' then	
			--OG had this weird ass setup
		elseif weather == 'sandstorm' then
			i = 389508322
			a = 300/225
			local angle = math.rad(30)
			v = Vector2.new(math.cos(angle), math.sin(angle)) * 2
			mo = 0.6
		elseif weather == 'sunnyday' or weather == 'desolateland' then
			i = 15462027084
			a = 100/75
			mo = 0.3
		elseif weather == 'hail' then
			i = 5589653911
			a = 1
		else
			return
		end
		local rainFrame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 60),
			Position = UDim2.new(0.0, 0, 0.0, -60),
			Parent = Utilities.gui,
		}
		local rain = _p.Rain:start(rainFrame, i, a, v)
		Utilities.Tween(.5, nil, function(a)
			rain:setTransparency(1-a*mo)
		end)
		wait(1)
		Utilities.Tween(.5, nil, function(a)
			rain:setTransparency(1-(1-a)*mo)
		end)
		rain:destroy()
		rainFrame:Destroy()		
	end
	function BattleGui:animCapture(poke, pokeballId, shakes, critical, sbCount)
		local caught = (critical and shakes == 1) or shakes == 4
		poke.sprite:animCaptureAttempt(pokeballId, shakes, critical, caught, sbCount)
		if sbCount then
			_p.Battle.currentBattle.SBCount = sbCount
		end
		if caught then
			self:message('Gotcha! ' .. (poke.species or poke.name) .. ' was caught!')
			wait(1)
			return true
		end

		self:message(({'Oh no! The Pokemon broke free!','Aww! It appeared to be caught!','Aargh! Almost had it!','Gah! It was so close, too!'})[shakes+1])

		if BattleGui.updateSafariBalls and not caught then
			BattleGui.updateSafariBalls()
		end	

		if sbCount == 0 and not caught then
			self:message("You're all out of Safari Balls!")
		end
		return false
	end
	function BattleGui:animStatus(status, poke)
		if moveAnims.status[status] then
			moveAnims.status[status](poke)
		else
			task.wait(.5)
		end
	end
	function BattleGui:animAbility(poke, abilityName)
		local n = poke.side.n
		local posYS, posYO = 0.0, 0
		if #poke.side.active == 1 then
			posYO = poke.statbar.main--[[.gui]].AbsolutePosition.y + poke.statbar.main--[[.gui]].AbsoluteSize.y + 20
		else
			posYS = (n==1 and .45 or .4)-.1/292*110
		end
		local gui = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://'..({13607072331, 5359278538})[n],
			Size = UDim2.new(.2, 0, .2/292*110, 0),-- 292x110
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Parent = Utilities.gui,
		}
		write(poke:getShortName()..'\'s') {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.3, 0),
				Position = UDim2.new(0.5, 0, 0.15, 0),
				ZIndex = 2,
				Parent = gui,
			},
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Center,
		}
		write(abilityName) {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.3, 0),
				Position = UDim2.new(0.5, 0, 0.55, 0),
				ZIndex = 2,
				Parent = gui,
			},
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Center,
		}
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			gui.Position = n==1 and UDim2.new(0.0, -gui.AbsoluteSize.X*(1-a), posYS, posYO) or UDim2.new(1.0, -gui.AbsoluteSize.X*a, posYS, posYO)
		end)
		wait(.1)
		delay(1, function()
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				gui.Position = n==1 and UDim2.new(0.0, -gui.AbsoluteSize.X*a, posYS, posYO) or UDim2.new(1.0, -gui.AbsoluteSize.X*(1-a), posYS, posYO)
			end)
			gui:Destroy()
		end)
	end
	function BattleGui:animBoost(poke, good)
		local p = poke.sprite.part
		local dir = good and 1 or -1
		Utilities.sound(good and 301970798 or 301970736, .3, nil, 5)
		spawn(function()
			local angles = {}
			local offset = math.random()*math.pi
			for i = 1, 6 do
				angles[i] = math.pi*2/6*i+offset
			end
			for i = 1, 6 do
				local theta = table.remove(angles, math.random(#angles))--math.random()*math.pi*2
				_p.Particles:new {
					Position = p.Position + Vector3.new(math.cos(theta)*(p.Size.x/2+1), -p.Size.Y*.5*dir, math.sin(theta)*(p.Size.x/2+1)),
					Size = Vector2.new(.4, .4/70*291),
					Velocity = Vector3.new(0, 10*dir, 0),
					Acceleration = false,
					Color = good and Color3.new(.4, .8, 1) or Color3.new(1, .4, .4),
					Lifetime = .5,
					Image = 287588544,--284111368,
				}
				task.wait(.125)
			end
		end)
	end
	function BattleGui:animHit(target, source, type, soundid, effectiveness, suppressParticles)
		effectiveness = effectiveness or 1
		local to = target.sprite.part.Position
		local from = source and source.sprite.part.Position or to+Vector3.new(0, 0, target.side.n==1 and -1 or 1)
		local color = typeColors[type or 'Normal']
		local p, s = Utilities.extents(to, 2)
		local smack = create 'ImageLabel' {
			Name = 'SmackAnim',
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5363596813',
			ImageColor3 = color,
			Parent = Utilities.gui,
		}
		Utilities.sound(soundid or _p.musicId.NormalDamage, .75, effectiveness == 1 and .5 or .6, 5)
		if not suppressParticles then
			local diffsides = source and source.side ~= target.side
			local rotateFudge = (diffsides and #target.side.active==1) and 0.25 or 0
			_p.Particles:new {
				N = 6 * effectiveness,
				Position = to,
				Velocity = (CFrame.new(from, to)*CFrame.Angles(0, rotateFudge, 0)).lookVector*20 + Vector3.new(0, 8, 0),
				VelocityVariation = 30,
				Acceleration = Vector3.new(0, -30, 0),
				Color = color,
				Image = {15879358908, 15879364918},
				Size = 0.25,
				Lifetime = .75,
			}
		end
		Utilities.Tween(.25, nil, function(a)
			smack.ImageTransparency = 1-a
			local s = s * (.5+a/2)
			smack.Size = UDim2.new(0.0, s, 0.0, s)
			smack.Position = UDim2.new(0.0, p.x-s/2, 0.0, p.y-s/2)
		end)
		smack:Destroy()
	end
	function BattleGui:animMove(battle, pokemon, move, targets)
		if pokemon.species == 'Marshadow' then
			--pokemon.sprite:animateAttack() 
		end
		if not moveAnims[move.id] and move.category == 'Status' then return end
		local effectives, soundids = {}, {}
		for _, a in pairs(battle.actionQueue) do
			if a == '|' then break end
			local args, kwargs = battle:parseAction(a)
			local arg1 = args[1]
			if not arg1 or arg1 == 'move' then
				break
			elseif arg1 == '-immune' or arg1 == '-miss' or arg1 == '-fail' then
				local target = battle:getPokemon(args[2])
				if target then
					for i = #targets, 1, -1 do
						if targets[i] == target then
							table.remove(targets, i)
						end
					end
				end
				if arg1 == '-fail' then
					if move.category == 'Status' then return end
				end
				if not kwargs.noreset then
					pcall(function() pokemon.sprite:animReset() end)
				end
			elseif arg1 == '-supereffective' then
				local target = battle:getPokemon(args[2])
				if target then
					effectives[target] = 2
					soundids[target] = _p.musicId.SuperEffective
				end
			elseif arg1 == '-resisted' then
				local target = battle:getPokemon(args[2])
				if target then
					effectives[target] = .5
					soundids[target] = _p.musicId.NotEffective
				end
			end
			local spriteId = pokemon.spriteSpecies or pokemon.species or pokemon.name
			if spriteId == 'Marshadow' then
				pcall(function()
					--pokemon.sprite:animateAttack()
				end)
			end
		end
		if moveAnims[move.id] then
			local targetMeta = {effectiveness=effectives,soundId=soundids}
			local continue = moveAnims[move.id](pokemon, targets, battle, move, targetMeta)
			if continue == 'sound' then -- TODO: this could be better; for now, ONLY RETURN THIS if the move has a single target
				local s, e
				for t, id in pairs(soundids) do
					s = id
					e = effectives[t]
					break
				end
				if not s then e = 1 end
				Utilities.sound(s or 5718021014, .75, e == 1 and .5 or .6, 5)
				return
			end
			if not continue then return end
		end
		local fns = {}
		for _, target in pairs(targets) do
			if target ~= pokemon then
				table.insert(fns, function()
					local s, r = pcall(function()
						self:animHit(target, pokemon, move.type, soundids[target], effectives[target])
					end)
					if not s then error('BATTLE BROKE ON MOVE: '..move.name..'; PLEASE REPORT THIS! ('..r..')') end
				end)
			end
		end
		if #fns == 1 then
			fns[1]()
		elseif #fns > 1 then
			Utilities.Sync(fns)
		end
	end
	function BattleGui:prepareMove(battle, pokemon, move, target)
		if not moveAnims.prepare[move.id] then return end
		if not target then
			target = pokemon.side.foe.active[1]
		end
		if target.isNull then
			target = pokemon
		end
		local prepareMessage
		--	if not battle.fastForward then
		prepareMessage = moveAnims.prepare[move.id](pokemon, target, battle, move, battle.fastForward)
		--	end
		if prepareMessage and not battle.fastForward then
			self:message(prepareMessage)
		end
	end

--[[do
--	600x200
--	original 287129499
--	1024x412   350
--	blue 575586255
--	bronze 575586347
--	black/white 575586398
--	green 575586482
	local yPos1 = 0.8
	local yPos2 = 0.7
	local mbcOffset = 0.275
	local relSize = 1-mbcOffset
	local msgBox = create 'Frame' {
		Name = 'BattleMsg',
		BackgroundTransparency = 1.0,
		Parent = Utilities.frontGui,
		ZIndex = 2,

		create 'Frame' {
			Name = 'container',
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, relSize, 0),
			Position = UDim2.new(0.0, 0, mbcOffset, 0),
			ClipsDescendants = true,
			ZIndex = 2
		}
	}
	local msgImg = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://575586398',
		ImageTransparency = 1.0,
		Size = UDim2.new(1.0, 0, 1.0, 0),
		Position = UDim2.new(0.0, 0, -0.05, 0),
		Parent = msgBox
	}
	local msgQueue = {}
	local font = Utilities.AvenirFont--require(game:GetService('ReplicatedStorage').Utilities.FontDisplayService.FontCreator).load('Avenir')
	local thread
	local processingMsg = false
	local msgsDone = Utilities.Signal()
	local function fadeInMsgBox()
		Utilities.fastSpawn(function()
			local thisThread = {}
			thread = thisThread
			Utilities.Tween(.125, nil, function(a)
				if thread ~= thisThread then return false end
				msgImg.ImageTransparency = 1-a
			end)
		end)
	end
	local function fadeOutMsgBox()
		Utilities.fastSpawn(function()
			local thisThread = {}
			thread = thisThread
			Utilities.Tween(.125, nil, function(a)
				if thread ~= thisThread then return false end
				msgImg.ImageTransparency = a
			end)
		end)
	end
	local answer
	local function processMessages()
		local boxHeightFill = 0.6
		local line1Pos = 0.3125
		local line2Pos = line1Pos + boxHeightFill/(font.baseHeight*2+font.lineSpacing)*(font.baseHeight+font.lineSpacing)
		local lineHeight = boxHeightFill/(font.baseHeight*2+font.lineSpacing)*font.baseHeight
		
		fadeInMsgBox()
		
		while #msgQueue > 0 do
			local line = 0
			local lines = {}
			msgBox.Size = UDim2.new(1.0, 0, 0.3, 0)
			msgBox.Position = UDim2.new(0.0, 0, yPos1, 0)
			
			local str = table.remove(msgQueue, 1)
			local overflow
			local yesorno = false
			repeat
--				if type(str) ~= 'string' then
--					print(type(str), str)
--				end
				if str:sub(1, 5):lower() == '[y/n]' then
					yesorno = true
					answer = nil
					str = str:sub(6)
				elseif not yesorno then
					answer = nil
				end
				line = line + 1
				if not overflow then
					msgBox:TweenPosition(UDim2.new(0.0, 0, yPos1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .5, true)
				elseif line >= 2 then
					msgBox:TweenPosition(UDim2.new(0.0, 0, yPos2, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .5, line==2)
				end
				local lf = Utilities.Create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.76, 0, lineHeight/relSize, 0),
					Position = UDim2.new(0.12, 0, ((line==1 and line1Pos or line2Pos)-mbcOffset)/relSize, 0),
					ZIndex = 2, Parent = msgBox.container
				}
				lines[line] = lf
				if line > 2 then
					local l1 = lines[line-2]
					local l2 = lines[line-1]
					local offset = line2Pos-line1Pos
					Utilities.fastSpawn(function()
						Utilities.Tween(.5, 'easeOutCubic', function(a)
							l1.Position = UDim2.new(0.12, 0, (line1Pos-a*offset-mbcOffset)/relSize, 0)
							l2.Position = UDim2.new(0.12, 0, (line2Pos-a*offset-mbcOffset)/relSize, 0)
						end)
						l1:Destroy()
					end)
					wait(.2)
				end
				overflow = write(str) {
					Size = lf.AbsoluteSize.Y,
					Frame = lf,
					Color = Color3.new(1, 1, 1),
					WritingToChatBox = true,
					AnimationRate = 35, -- ht / sec
				}
				
				if yesorno and not overflow then
					yesorno = false
					answer = BattleGui:promptYesOrNo()
				elseif line > 1 and overflow then
					wait(.5)
				elseif line ~= 1 or not overflow then
					wait(1)
				end
				str = overflow
			until not overflow
			msgBox.container:ClearAllChildren()
		end
		
		fadeOutMsgBox()
	end
	function BattleGui:message(...)
		for _, c in pairs({...}) do
			table.insert(msgQueue, c)
		end
		if not processingMsg then
			processingMsg = true
			processMessages()
			processingMsg = false
			msgsDone:fire()
		else
			while processingMsg do
				msgsDone:wait()
			end
		end
		return answer
	end
end]]
	do -- original code
		local mbcOffset = 0.275
		local relSize = 1-mbcOffset
		local msgBox = create 'ImageLabel' {
			Name = 'BattleMsg',
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://3206713449', -- 6517571793
			ImageTransparency = 1.0,
			Parent = Utilities.frontGui,

			create 'Frame' {
				Name = 'container',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, relSize, 0),
				Position = UDim2.new(0.0, 0, mbcOffset, 0),
				ClipsDescendants = true,
			}
		}
		local msgQueue = {}
		local font = Utilities.AvenirFont--require(game:GetService('ReplicatedStorage').Utilities.FontDisplayService.FontCreator).load('Avenir')
		local thread
		local processingMsg = false
		local msgsDone = Utilities.Signal()
		local function fadeInMsgBox()
			Utilities.fastSpawn(function()
				local thisThread = {}
				thread = thisThread
				Utilities.Tween(.125, nil, function(a)
					if thread ~= thisThread then return false end
					msgBox.ImageTransparency = 1-a
				end)
			end)
		end
		local function fadeOutMsgBox()
			Utilities.fastSpawn(function()
				local thisThread = {}
				thread = thisThread
				Utilities.Tween(.125, nil, function(a)
					if thread ~= thisThread then return false end
					msgBox.ImageTransparency = a
				end)
			end)
		end
		local answer
		local function processMessages()
			local boxHeightFill = 0.6
			local line1Pos = 0.3125
			local line2Pos = line1Pos + boxHeightFill/(font.baseHeight*2+font.lineSpacing)*(font.baseHeight+font.lineSpacing)
			local lineHeight = boxHeightFill/(font.baseHeight*2+font.lineSpacing)*font.baseHeight

			fadeInMsgBox()

			while #msgQueue > 0 do
				local line = 0
				local lines = {}
				msgBox.Size = UDim2.new(1.0, 0, 0.3, 0)
				msgBox.Position = UDim2.new(0.0, 0, 0.8, 0)

				local str = table.remove(msgQueue, 1)
				local overflow
				local yesorno = false
				repeat
					--				if type(str) ~= 'string' then
					--					print(type(str), str)
					--				end
					if str:sub(1, 5):lower() == '[y/n]' then
						yesorno = true
						answer = nil
						str = str:sub(6)
					elseif not yesorno then
						answer = nil
					end
					line = line + 1
					if not overflow then
						msgBox:TweenPosition(UDim2.new(0.0, 0, 0.8, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .5, true)
					elseif line >= 2 then
						msgBox:TweenPosition(UDim2.new(0.0, 0, 0.7, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .5, line==2)
					end
					local lf = Utilities.Create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.76, 0, lineHeight/relSize, 0),
						Position = UDim2.new(0.12, 0, ((line==1 and line1Pos or line2Pos)-mbcOffset)/relSize, 0),
						Parent = msgBox.container,
					}
					lines[line] = lf
					if line > 2 then
						local l1 = lines[line-2]
						local l2 = lines[line-1]
						local offset = line2Pos-line1Pos
						Utilities.fastSpawn(function()
							Utilities.Tween(.5, 'easeOutCubic', function(a)
								l1.Position = UDim2.new(0.12, 0, (line1Pos-a*offset-mbcOffset)/relSize, 0)
								l2.Position = UDim2.new(0.12, 0, (line2Pos-a*offset-mbcOffset)/relSize, 0)
							end)
							l1:Destroy()
						end)
						wait(.2)
					end
					overflow = write(str) {
						Size = lf.AbsoluteSize.Y,
						Frame = lf,
						Color = Color3.new(1, 1, 1),
						WritingToChatBox = true,
						AnimationRate = 35, -- ht / sec
					}

					if yesorno and not overflow then
						yesorno = false
						answer = BattleGui:promptYesOrNo()
					elseif line > 1 and overflow then
						wait(.5)
					elseif line ~= 1 or not overflow then
						wait(1)
					end
					str = overflow
				until not overflow
				msgBox.container:ClearAllChildren()
			end

			fadeOutMsgBox()
		end
		function BattleGui:message(...)
			for _, c in pairs({...}) do
				table.insert(msgQueue, c)
			end
			if not processingMsg then
				processingMsg = true
				processMessages()
				processingMsg = false
				msgsDone:fire()
			else
				while processingMsg do
					msgsDone:wait()
				end
			end
			return answer
		end
	end
	--
	--[[
	do
		local sig, yon
		local yes
		local selectionGroup
		function BattleGui:promptYesOrNo()
			local isTouch = Utilities.isTouchDevice()
			if not yon then
				sig = Utilities.Signal() --Color3.new(.2, .2, .2),
				yon = roundedFrame:new({
					Name = 'YesOrNoPrompt',
					BackgroundColor3 = Color3.new(.2, .2, .2),
					Size = UDim2.new(0.15, 0, 0.3, 0),
					Position = UDim2.new(0.7, 0, 0.45, 0),
					Parent = Utilities.frontGui
				})
				
				yes = create("ImageButton")({
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, 0.25, 0),
					Position = UDim2.new(0.1, 0, 0.175, 0),
					ZIndex = 2,
					Parent = yon.gui,
					MouseButton1Click = function()
						--yon.Visible = false
						sig:fire(true)
					end,
				})
				
				local no = create("ImageButton")({
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, 0.25, 0),
					Position = UDim2.new(0.1, 0, 0.575, 0),
					ZIndex = 2,
					Parent = yon.gui,
					MouseButton1Click = function()
						--yon.Visible = false
						sig:fire(false)
					end,
				})
				
				if isTouch then
					yes.Size = UDim2.new(0.8, 0, 0.35, 0)
					no.Size = UDim2.new(0.8, 0, 0.35, 0)
					
					write("Yes")({
						Frame = Utilities.Create("Frame")({
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 5 / 7, 0),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 0, 0.5, 0),
							ZIndex = 40,
							Parent = yes
						}),
						Scaled = true
					})
					
					write("No")({
						Frame = Utilities.Create("Frame")({
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 5 / 7, 0),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 0, 0.5, 0),
							ZIndex = 40,
							Parent = no
						}),
						Scaled = true
					})
				else
					write("Yes")({
						Frame = yes,
						Scaled = true
					})
					write("No")({
						Frame = no,
						Scaled = true
					})
				end
				
				selectionGroup = _p.GamepadManager:CreateSelectionGroup(yes, no)
				selectionGroup:CreateDefaultSelectionAdornment()
			end
			
			if not isTouch then
				selectionGroup:PushFocus(yes)
			end
			yon.Visible = true
			ContextActionService:BindActionAtPriority("LegacyBattleAnswerNoShortcut", function(_, inputState, inputObject)
				if inputState == Enum.UserInputState.Begin and inputObject.UserInputType == _p.activeGamepad then
					sig:fire(false)
				end
			end, false, 3006, Enum.KeyCode.ButtonB)
			local sigWait = sig:wait()
			ContextActionService:UnbindAction("LegacyBattleAnswerNoShortcut")
			yon.Visible = false
			
			if not isTouch then
				selectionGroup:PopFocus()
			end
			
			return sigWait
		end
	end
	]]

	do
		local sig, yon
		function BattleGui:promptYesOrNo()
			if not yon then
				sig = Utilities.Signal()
				yon = roundedFrame:new {
					Name = 'YesOrNoPrompt',
					BackgroundColor3 = Color3.new(.2, .2, .2),
					Size = UDim2.new(0.15, 0, 0.3, 0),
					Position = UDim2.new(0.7, 0, 0.45, 0),
					Parent = Utilities.frontGui,
				}
				write 'Yes' {
					Frame = create 'ImageButton' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.8, 0, 0.25, 0),
						Position = UDim2.new(0.1, 0, 0.175, 0),
						ZIndex = 2,
						Parent = yon.gui,
						MouseButton1Click = function()
							yon.Visible = false
							sig:fire(true)
						end,
					},
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Center,
				}
				write 'No' {
					Frame = create 'ImageButton' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.8, 0, 0.25, 0),
						Position = UDim2.new(0.1, 0, 0.575, 0),
						ZIndex = 2,
						Parent = yon.gui,
						MouseButton1Click = function()
							yon.Visible = false
							sig:fire(false)
						end,
					},
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Center,
				}
			end
			yon.CornerRadius = Utilities.gui.AbsoluteSize.Y*.05
			yon.Visible = true
			return sig:wait()
		end
	end

	BattleGui.toggleRemainingPartyGuis = require(script.RemainingPartyGui)(_p)
	BattleGui.toggleFC = require(script.FieldCheck)(_p)
	--local transition = {
	--	
	--}

	local ClickFns = {}

	function BattleGui:mainChoices(...)

		local args = {...}
		local rqPokemon, slot, nActive, moveLocked, isFirstValid, alreadySwitched, alreadyChoseMega, zMoveUsed, alreadyChoseUltra, alreadyChoseDmax = ...
		local battle = _p.Battle.currentBattle
		--local taunt, pokemon, ballLocked, ballId

		--if battle.isSafari then
		--	taunt, pokemon, ballLocked, ballId = rqPokemon, slot, nActive, moveLocked
		--end

		self.choicePack = args
		state = 'animating'
		self.isFirstUserPokemon = isFirstValid

		self.mainButtonClicked = function(name)
			if state ~= 'canchoosemain' then return end
			state = 'choosing'
			if name == 'Fight' then
				if moveLocked then
					self.inputEvent:fire('move 1')
					self:exitButtonsMain()
				else
					self:fightChoices(self.moves, rqPokemon, slot, nActive, alreadyChoseMega, zMoveUsed, alreadyChoseUltra, alreadyChoseDmax)
				end
			else
				pcall(function()
					gui.mega.selected = false
					gui.mega:Pause()
					gui.zmove.selected = false
					gui.zmove:pause()
					gui.ultra.selected = false
					gui.ultra:pause()
					gui.dynamax.selected = false
					gui.dynamax:Pause()
					gui.gigantamax.selected = false
					gui.gigantamax:Pause()
				end)

				local battleKind = battle.kind
				if name == 'Run' then
					if battleKind == 'pvp' or battleKind == '2v2' then

						spawn(function() self:exitButtonsMain() end)

						if self:message('[y/n]Are you sure you want to forfeit this match?') then
							local battle = _p.Battle.currentBattle
							battle:send('forfeit', battle.sideId)
							battle:setIdle()
						else
							return self:mainChoices(unpack(args)) --
						end
					elseif battleKind == 'wild' then
						spawn(function() self:exitButtonsMain() end)
						spawn(function() self:toggleRemainingPartyGuis(false) end)
						spawn(function() self:toggleFC(false) end)
						local escaped = _p.Network:get('BattleFunction', _p.Battle.currentBattle.battleId, 'tryRun')
						if escaped == 'partial' then
							self:message('You can\'t escape!')
							return self:mainChoices(unpack(args)) --
						elseif battle.cantRun then
							self:message("You cannot run from this battle!")
							return self:mainChoices(unpack(args))
						elseif escaped then
							self.pickup = false
							self:message('You got away safely!')
							battle.ended = true
							battle.BattleEnded:fire()
						else
							self:message('You couldn\'t escape!')
							self:send('choose', self.sideId, {'pass'}, self.lastRequest.rqid)
							wait()
							self:setIdle()
						end
					else
						self:message('There\'s no running from a Trainer battle!')
						state = 'canchoosemain'
					end
				elseif name == 'Pokemon' then
					if battle.isRaid then
						self:message('You can\'t switch in a Raid battle!')
						return self:mainChoices(unpack(args))
					end
					local switched = self:switchPokemon(nil, nil, alreadySwitched, slot)
					if not switched then
						return self:mainChoices(unpack(args))
					end
				elseif name == 'Bag' or name == 'Berry' then
					if _p.Battle.currentBattle.kind == 'pvp' or _p.Battle.currentBattle.kind == '2v2' or _p.Battle.currentBattle.noBag then
						self:message('You can\'t use that now.')
						state = 'canchoosemain'
						return
					end
					local sig = Utilities.Signal()
					spawn(function() self:exitButtonsMain() end)
					Menu.bag:open(sig)
					local res = sig:wait()
					if res == 'cancel' then
						return self:mainChoices(unpack(args)) --
					else
						self.inputEvent:fire(res)
						Menu.bag:close()
					end
				else
					if battle.isSafari and battleKind == 'wild' then
						if name == 'Ball' then
							spawn(function() self:exitButtonsMain() end)
							self.inputEvent:fire('useitem safariball')
						elseif name == 'Go Near' then
							spawn(function() self:exitButtonsMain() end)
							self.inputEvent:fire('gonear')
						end
					end
				end
			end
		end
		local fight, bag, pokemon, run, container

		local function onButtonClicked(name)
			self.mainButtonClicked(name)
		end

		local function writeTextForBtn(label, name, textColor)
			local fIcon = {"Fight", "Ball"}

			if table.find(fIcon, name) then
				create 'Frame' {
					Name = 'FighterIcon',
					BackgroundTransparency = 1.0,
					Size = name == 'Ball' and UDim2.new(0.27, 0, 0.7, 0) or UDim2.new(0.7/522*130/3*4, 0, 0.7, 0),
					Position = name == 'Ball' and UDim2.new(0.5, 0, 0.25, 0) or UDim2.new(0.125, 0, 0.1, 0),
					Parent = label,
				}
			end

			if name == 'Ball' then
				BattleGui.updateSafariBalls = function()
					local n = battle.SBCount
					if label:FindFirstChild("txt2") then
						label:FindFirstChild("txt2"):Destroy()
					end
					write("x"..n) {
						Frame = create 'Frame' {
							Name = 'txt2',
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.05, 0, 0.3, 0),
							Position = UDim2.new(0.73, 0, 0.4, 0),
							Parent = label,
							ZIndex = 8,
						},
						Scaled = true,
					}
				end
				BattleGui.updateSafariBalls()
			end

			write(name) {
				Frame = create 'Frame' {
					Name = 'txt',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.5, 0),
					Position = name  == "Ball" and UDim2.new(-0.1, 0, 0.25, 0) or UDim2.new(0.0, 0, 0.25, 0),
					Parent = label,
					ZIndex = 8,
				},
				Scaled = true,
				Color = textColor,
			}
			table.insert(ClickFns, label.Button.MouseButton1Click:Connect(function()
				onButtonClicked(name)
			end))
		end

		local btnData = {
			fight = {
				battle.isSafari and "Ball" or "Fight", 
				Color3.new(1, .4, .4), 
				Color3.new(.4, .15, .15)
			},
			bag = {
				battle.isSafari and "Berry" or "Bag",
				Color3.new(1, .8, .4), 
				Color3.new(.4, .25, .15),
			}, 
			pokemon = {
				battle.isSafari and "Go Near" or "Pokemon",
				Color3.new(.4, 1, .8), 
				Color3.new(.15, .4, .25)
			}, 
			run = {
				"Run",
				Color3.new(.4, .8, 1), 
				Color3.new(.15, .25, .4)
			}	
		}

		if gui.main then
			local main = gui.main
			fight, bag, pokemon, run, container = main.fight, main.bag, main.pokemon, main.run, main.container

			for i, v in pairs(ClickFns) do
				v:Disconnect()
				ClickFns[i] = nil
			end

			for k, v in pairs(btnData) do
				local btn = main[k]
				btn.txt:Destroy()
				for i, v in pairs({"txt2"}) do
					if btn:FindFirstChild(v) then
						btn:FindFirstChild(v):Destroy()
					end
				end
				writeTextForBtn(btn, v[1], v[3])
			end
		else
			container = create 'Frame' {
				Name = 'BattleGui',
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Size = UDim2.new(.25, 0, .25/522*130, 0),
				Parent = Utilities.gui,
			}
			local function b(name, labelColor, textColor)
				local label = create 'ImageLabel' { -- 522 x 130
					Name = name,
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://5348186988',
					ImageRectSize = Vector2.new(393, 99),
					ImageColor3 = labelColor,
					Size = UDim2.new(1.0, 0, 1.0, 0),
					ZIndex = 7,
					Parent = container,

					create 'ImageButton' {
						Name = 'Button',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.6, 0, 1.0, 0),
						Position = UDim2.new(0.2, 0, 0.0, 0),
					}
				}

				writeTextForBtn(label, name, textColor)				

				return label
			end

			gui.main = {
				--fight = fight,
				--bag = bag,
				--pokemon = pokemon,
				--run = run,
				container = container,
			}

			for k, v in pairs(btnData) do
				gui.main[k] = b(unpack(v))
			end

			fight = gui.main.fight
			bag = gui.main.bag
			pokemon = gui.main.pokemon
			run = gui.main.run

			--fight = b(battle.isSafari and 'Ball' or 'Fight', Color3.new(1, .4, .4), Color3.new(.4, .15, .15))
			--bag = b(battle.isSafari and 'Berry' or 'Bag', Color3.new(1, .8, .4), Color3.new(.4, .25, .15))
			--pokemon = b(battle.isSafari and 'Go Near' or 'Pokemon', Color3.new(.4, 1, .8), Color3.new(.15, .4, .25))
			--run = b('Run', Color3.new(.4, .8, 1), Color3.new(.15, .25, .4))
		end
		local cancel = create 'ImageLabel' { -- 522 x 130
			Name = 'Cancel',
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5348186988',
			ImageRectSize = Vector2.new(393, 99),
			ImageColor3 = Color3.new(.25, 1, 1),
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Parent = container,
			Visible = false,

			create 'ImageButton' {
				Name = 'Button',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.6, 0, 1.0, 0),
				Position = UDim2.new(0.2, 0, 0.0, 0),
				MouseButton1Click = function()
					if state == 'canchoosemain' then
						--print('cancel to previous')
						self:cancelToPreviousPokemon()
					elseif state == 'canchoosemove' then
						self:cancelToMain()
					elseif state == 'canchoosetarget' then
						self:cancelToMoves()
					end
				end,
			}
		}
		write 'Cancel' {
			Frame = create 'Frame' {
				Name = 'txt',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.5, 0),
				Position = UDim2.new(0.0, 0, 0.25, 0),
				Parent = cancel,
			},
			Scaled = true,
			Color = Color3.new(.1, .4, .4),
		}
		gui.cancel = cancel

		local origin = UDim2.new(.65, 0, 0.0, 0)
		local pfn
		if Utilities.isPhone() then
			origin = UDim2.new(.5, 0, .7, 0)
			container.Size = UDim2.new(.35, 0, .35/522*130, 0)
			pfn = function()
				container.Position = origin + UDim2.new(-container.Size.X.Scale/2, 0, 0.0, -container.AbsoluteSize.Y/2)
			end
		else
			pfn = function(depth)
				container.Position = origin + UDim2.new(-container.Size.X.Scale/2, 0, 0.0, Utilities.gui.AbsoluteSize.Y-container.AbsoluteSize.Y*1.75)
				spawn(function()
					-- fix Windows Restore bug
					if (not depth or depth < 5) and container.AbsolutePosition.Y + container.AbsoluteSize.Y*1.5 > Utilities.gui.AbsoluteSize.Y then
						pfn((depth or 1) + 1)
					end
				end)
			end
		end
		Utilities.gui.Changed:connect(function(prop)
			if prop ~= 'AbsoluteSize' then return end
			--			print(Utilities.gui.AbsoluteSize)
			pfn()
		end)
		pfn()

		container.Parent = Utilities.gui
		fight.Visible, bag.Visible, pokemon.Visible, run.Visible = true, true, true, true
		if isFirstValid then
			if _p.Battle.currentBattle.kind == 'pvp' or _p.Battle.currentBattle.kind == '2v2' then
				bag.Visible = false
				if run.Name ~= 'Forfeit' then
					run.Name = 'Forfeit'
					run.txt:ClearAllChildren()
					write 'Forfeit' {
						Frame = run.txt,
						Scaled = true,
						Color = Color3.new(.15, .25, .4),
					}
				end
			else
				if run.Name ~= 'Run' and run == gui.run then
					run.Name = 'Run'
					run.txt:ClearAllChildren()
					write 'Run' {
						Frame = run.txt,
						Scaled = true,
						Color = Color3.new(.15, .25, .4),
					}
				end
			end
		else
			if _p.Battle.currentBattle.kind == 'pvp' or _p.Battle.currentBattle.kind == '2v2' then
				bag.Visible = false
			end
			run.Visible = false
			run = gui.cancel
			run.Visible = true
		end

		pcall(function() self.fighterIcon.Parent = nil end)
		fight.FighterIcon:ClearAllChildren()
		pcall(function()
			self.fighterIcon.ZIndex = 9
			self.fighterIcon.Parent = fight.FighterIcon
		end)
		container.Visible = true
		spawn(function() self:toggleRemainingPartyGuis(true) end)
		spawn(function() self:toggleFC(true) end)
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			container.Visible = true -- temp fix for double battle input bug
			local o = 1-a
			fight.Position = UDim2.new(0.0, 0, -135/130/2, 0) + UDim2.new(0.0, 0, 0.0, -(container.AbsolutePosition.Y+fight.AbsoluteSize.Y+36)*o)
			run.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+run.AbsoluteSize.Y)*o)
			bag.Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -(container.AbsolutePosition.X+bag.AbsoluteSize.X)*o, 0.0, 0)
			pokemon.Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+pokemon.AbsoluteSize.Y)*o, 0.0, 0)
		end)
		state = 'canchoosemain'
	end
	function BattleGui:animBerryThrow(rate, poke, berryName, berryColor)
		local pname = (poke.species or poke.name)
		local berry = poke.sprite:animThrowBerry(berryColor)

		self:message(_p.PlayerData.trainerName..' threw a '..berryName..' towards the wild '..pname..'...')
		if rate > 1 then
			poke.sprite:animSpriteJump(nil, rate > 2 and 2 or 1)
		end	
		berry:Destroy()
		local text = string.gsub(({
			"The wild @sp completely ignored it.",
			"The wild @sp is curious...",
			"The wild @sp is enthralled!",
		})[rate], "@sp", pname)
		self:message(text)
	end

	function BattleGui:chooseMoveTarget(moveNum, move, rqPokemon, userPosition, nActive)
		state = 'animating'
		if gui.zmove.selected then
			pcall(function()
				move.target = rqPokemon.canZMove[moveNum].target or move.target
			end)
		elseif gui.dynamax.selected or gui.gigantamax.selected or rqPokemon.currentDyna then
			pcall(function()
				move.target = rqPokemon.maxMoves[moveNum].target or move.target
			end)
		end

		--// Targets: { foe, foe, foe, me, ally, ally}, 0: unable 1: can 2: must
		local validTargets = ({
			normal 			   = {1, 1, 0, 0, 1, 0},
			allAdjacentFoes    = {2, 2, 2, 0, 0, 0},
			self 			   = {0, 0, 0, 1, 0, 0},
			all 			   = {2, 2, 2, 2, 2, 2},
			allAdjacent 	   = {2, 2, 0, 0, 2, 0},
			allySide 		   = {0, 0, 0, 2, 2, 2},
			any 			   = {1, 1, 1, 0, 1, 1},
			scripted 		   = {0, 0, 0, 1, 0, 0},
			randomNormal	   = {0, 0, 0, 1, 0, 0},
			foeSide 		   = {2, 2, 2, 0, 0, 0},
			adjacentAlly	   = {0, 0, 0, 0, 1, 0},
			allyTeam 		   = {0, 0, 0, 2, 2, 2},
			adjacentFoe 	   = {1, 1, 0, 0, 0, 0},
			adjacentAllyOrSelf = {0, 0, 0, 1, 1, 0}
		})[move.target]

		local function getTokenForPosition(bn)
			if nActive == 2 then
				if bn == 2 or bn == 5 then return 0 end
				local p = bn + (bn%3==0 and -1 or 0)
				if userPosition == 2 then
					p = (p>3 and 9 or 3) - p
				end
				return validTargets[p]
			elseif nActive == 3 then
				-- todo
			end
			return 0
		end

		local main = gui.main
		local cancel = gui.cancel
		local container = gui.targetContainer
		local targets = gui.targets
		local moves = gui.moves
		local selectedMove = moves[moveNum]


		self.onTargetClicked = function(n)
			if state ~= 'canchoosetarget' then return end
			if getTokenForPosition(n) > 0 then
				state = 'animating'
				local t = n>3 and 3-n or 4-n
				if nActive == 2 then
					if t == 3 then t = 2
					elseif t == -3 then t = -2 end
				end
				--self.inputEvent:fire('move '..moveNum..(gui.mega.selected and ' mega ' or ' ')..t)
				local option = ''
				if gui.mega.selected then option = ' mega ' elseif gui.zmove.selected then option = ' zmov ' elseif gui.ultra.selected then option = ' ultra ' elseif (gui.dynamax.selected or gui.gigantamax.selected) then option = ' dynamax ' elseif (rqPokemon.currentDyna) then option = ' maxmove ' end
				--print("MOVENUM:", moveNum)
				self.inputEvent:fire('move '..moveNum..option..t)

				Utilities.Tween(.6, 'easeOutCubic', function(a)
					selectedMove.Position = UDim2.new(0.0, 0, -135/130/2, 0) + UDim2.new(0.0, 0, 0.0, -(container.AbsolutePosition.Y+selectedMove.AbsoluteSize.Y+36)*a)
					local l = (container.AbsolutePosition.X+targets[1].AbsoluteSize.X)*a
					targets[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
					targets[4].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
					local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+targets[3].AbsoluteSize.Y)*a
					targets[3].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
					targets[6].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
					-- todo 2, 5
					cancel.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+cancel.AbsoluteSize.Y)*a)
				end)
				gui.mega.selected = false
				gui.mega:Pause()
				gui.zmove.selected = false
				gui.zmove:Pause()
				gui.ultra.selected = false
				gui.ultra:Pause()
				gui.dynamax.selected = false
				gui.dynamax:Pause()
				gui.gigantamax.selected = false
				gui.gigantamax:Pause()
				container.Parent = nil
			end
		end

		if not targets then
			container = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 1.0, 0),
			}
			targets = {false, false, false, false, false, false}
			for i = 1, 6 do
				targets[i] = create 'ImageLabel' { -- 522 x 130
					Name = 'Move'..i,
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://5348186988',
					ImageRectSize = Vector2.new(393, 99),--ImageRectSize = 393,99,
					ImageColor3 = BrickColor.new('Bright orange').Color,
					Size = UDim2.new(1.0, 0, 1.0, 0),
					ZIndex = 2, Parent = container,

					create 'ImageButton' {
						Name = 'Button',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.6, 0, 1.0, 0),
						Position = UDim2.new(0.2, 0, 0.0, 0),
						ZIndex = 7,
						MouseButton1Click = function()
							if state ~= 'canchoosetarget' then return end
							self.onTargetClicked(i)
						end,
					},
					create 'Frame' {
						Name = 'NameContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.4, 0),
						Position = UDim2.new(0.5+0.7/522*130/3*4/4, 0, 0.3, 0),
						ZIndex = 3,
					},
					create 'ImageLabel' { -- 537x140
						Name = 'HighlightIcon',
						Image = 'rbxassetid://13607101727',
						ImageColor3 = BrickColor.new('Cyan').Color,
						BackgroundTransparency = 1.0,
						Size = UDim2.new(537/522, 0, 140/130, 0),
						Position = UDim2.new(-6/522, 0, -5/130, 0),
					},
				}
			end
			gui.targets = targets
			gui.targetContainer = container
		end
		container.Parent = main.container
		targets[4].ImageColor3 = BrickColor.new('Dark green').Color
		targets[5].ImageColor3 = BrickColor.new('Dark green').Color
		targets[6].ImageColor3 = BrickColor.new('Dark green').Color
		local function updateTargetButton(bNum, pokemon)
			local token = getTokenForPosition(bNum)
			local button = targets[bNum]
			local transparency = token>0 and 0.0 or 0.5
			button.NameContainer:ClearAllChildren()
			button.ImageTransparency = transparency
			button.HighlightIcon.Visible = token==2
			if not pokemon or pokemon.isNull then return end
			local f = write(pokemon:getShortName()) {
				Frame = button.NameContainer,
				Scaled = true,
				Color = Color3.new(button.ImageColor3.r*.35, button.ImageColor3.g*.35, button.ImageColor3.b*.35),
				Transparency = transparency
			}.Frame
			local icon = pokemon:getIcon()
			if icon then
				local s = .5/.3
				icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
				icon.Size = UDim2.new(-s/3*4, 0, s, 0)
				icon.Position = UDim2.new(0.0, 0, -(s-1)/2, 0)
				icon.ImageTransparency = transparency
				icon.Parent = f
			end
		end
		if nActive == 2 then
			targets[2].Visible = false
			targets[5].Visible = false
			targets[3+userPosition+(userPosition==2 and 1 or 0)].ImageColor3 = BrickColor.new('Bright green').Color
			local battle = _p.Battle.currentBattle
			updateTargetButton(1, battle.yourSide.active[2])
			updateTargetButton(3, battle.yourSide.active[1])
			updateTargetButton(4, battle.mySide.active[1])
			updateTargetButton(6, battle.mySide.active[2])
		else
			targets[2].Visible = true
			targets[5].Visible = true
			targets[3+userPosition].ImageColor3 = BrickColor.new('Bright green').Color
			local battle = _p.Battle.currentBattle
			updateTargetButton(1, battle.yourSide.active[3])
			updateTargetButton(2, battle.yourSide.active[2])
			updateTargetButton(3, battle.yourSide.active[1])
			updateTargetButton(4, battle.mySide.active[1])
			updateTargetButton(5, battle.mySide.active[2])
			updateTargetButton(6, battle.mySide.active[3])
		end
		local fight, ms, zm, ub, dm, gm = main.fight, gui.mega.spriteLabel, gui.zmove.spriteLabel, gui.ultra.spriteLabel, gui.dynamax.spriteLabel, gui.gigantamax.spriteLabel
		local spx, spy = selectedMove.Position.X.Scale, selectedMove.Position.Y.Scale
		local epy = -135/130/2

		-- transition the targets (& chosen move) in after choosing the move; other moves out
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			local o = 1-a
			fight.Position = UDim2.new(0.0, 0, -135/130/2, 0) + UDim2.new(0.0, 0, 0.0, -(container.AbsolutePosition.Y+fight.AbsoluteSize.Y+36)*a)
			local l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*a
			moves[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			moves[3].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*a
			moves[2].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			moves[4].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			ms.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)
			zm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y+36)*a)
			ub.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y+36)*a)
			dm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y+36)*a)
			gm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y+36)*a)

			selectedMove.Position = UDim2.new(spx*o, 0, spy + (epy-spy)*a, 0)
			l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*o
			targets[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			targets[4].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*o
			targets[3].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			targets[6].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			-- todo 2, 5
		end)

		self.selectedMoveNum = moveNum
		state = 'canchoosetarget'
	end

	function BattleGui:cancelToPreviousPokemon()
		self.inputEvent:fire('back')
		self:exitButtonsMain()
		pcall(function()
			gui.mega.selected = false
			gui.mega:Pause()
			gui.zmove.selected = false
			gui.zmove:Pause()
			gui.ultra.selected = false
			gui.ultra:Pause()
			gui.dynamax.selected = false
			gui.dynamax:Pause()
			gui.gigantamax.selected = false
			gui.gigantamax:Pause()
		end)
	end

	function BattleGui:cancelToMoves()
		state = 'animating'
		local moveNum = self.selectedMoveNum
		local targets = gui.targets
		local moves = gui.moves
		local main = gui.main
		local container = main.container
		local fight, ms, zm, ub, dm, gm = main.fight, gui.mega.spriteLabel, gui.zmove.spriteLabel, gui.ultra.spriteLabel, gui.dynamax.spriteLabel, gui.gigantamax.spriteLabel
		local selectedMove = moves[moveNum]
		local spx, spy = selectedMove.Position.X.Scale, selectedMove.Position.Y.Scale
		local p = ({Vector2.new(-424/522, -134/130),
			Vector2.new(424/522, -134/130),
			Vector2.new(-424/522, 0.0),
			Vector2.new(424/522, 0.0),
		})[moveNum]
		local epx, epy = p.X, p.Y
		-- transition back to moves from target selection after canceling
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			local o = a; a = 1-a
			fight.Position = UDim2.new(0.0, 0, -135/130/2, 0) + UDim2.new(0.0, 0, 0.0, -(container.AbsolutePosition.Y+fight.AbsoluteSize.Y+36)*a)
			local l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*a
			moves[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			moves[3].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*a
			moves[2].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			moves[4].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			ms.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)
			zm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y+36)*a)
			ub.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y+36)*a)
			dm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y+36)*a)
			gm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y+36)*a)

			selectedMove.Position = UDim2.new(spx + (epx-spx)*o, 0, spy + (epy-spy)*o, 0)
			l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*o
			targets[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			targets[4].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*o
			targets[3].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			targets[6].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			-- todo 2, 5
		end)
		state = 'canchoosemove'
	end

	function BattleGui:exitButtonsMain()
		state = 'animating'
		local main = gui.main
		local fight, bag, pokemon, run, container = main.fight, main.bag, main.pokemon, main.run, main.container
		if not run.Visible then
			run = gui.cancel
		end
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			fight.Position = UDim2.new(0.0, 0, -135/130/2, 0) + UDim2.new(0.0, 0, 0.0, -(container.AbsolutePosition.Y+fight.AbsoluteSize.Y+36)*a)
			run.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+run.AbsoluteSize.Y)*a)
			bag.Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -(container.AbsolutePosition.X+bag.AbsoluteSize.X)*a, 0.0, 0)
			pokemon.Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+pokemon.AbsoluteSize.Y)*a, 0.0, 0)
		end)
		container.Visible = false
		state = 'idle'
	end
	function BattleGui:updateButtonForZMove(button, move, zmove)
		local battle = _p.Battle.currentBattle
		button.MoveNameContainer:ClearAllChildren()
		button.TypeContainer:ClearAllChildren()
		button.PPContainer:ClearAllChildren()
		button.Effectiveness.Visible = false

		if not move or not zmove then-- changed '' to false due to roblox behaviour change to ''
			button.ImageColor3 = Color3.new(0.5, 0.5, 0.5)
			button.ImageTransparency = 0.5
			return
		end
		local tc = typeColors[move.type]
		if not move.effective then
			local effect = {}
			for ind,val in pairs(_p.Pokemon:getTypes(battle.yourSide.active[1].types)) do
				if move.category == 'Status' or not typeChart[val][move.type] then
					button.Effectiveness.Visible = false
				else
					effect[ind] = typeChart[val][move.type]
				end
			end
			move.effective = effect
		end
		if move.effective and _p.Menu.options.typeArrows then
			local maxEffectiveness = -1
			for _, e in pairs(move.effective) do
				if typeof(e) == "table" then
					for _, e in pairs(e) do
						maxEffectiveness = math.max(maxEffectiveness, e)
					end
				else
					maxEffectiveness = math.max(maxEffectiveness, e)
				end
			end
			if maxEffectiveness > -1 and maxEffectiveness ~= 1 then
				button.Effectiveness.Visible = true
				if maxEffectiveness < 0.3 then
					button.Effectiveness.ImageRectOffset = Vector2.new(300, 0)
				elseif maxEffectiveness < 0.6 then
					button.Effectiveness.ImageRectOffset = Vector2.new(300, 300)
				elseif maxEffectiveness > 3.5 then
					button.Effectiveness.ImageRectOffset = Vector2.new(0, 0)
				elseif maxEffectiveness > 1.5 then
					button.Effectiveness.ImageRectOffset = Vector2.new(0, 300)
				else
					button.Effectiveness.Visible = false
				end
			end
		end
		button.ImageColor3 = tc
		button.ImageTransparency = 0
		if zmove.move:sub(1, 2) == "Z-" then
			write(zmove.move)({
				Frame = create("Frame")({               				
					BackgroundTransparency = 1,	
					Size = UDim2.new(0, 0, 0.8, 0),
					Position = UDim2.new(0, 0, 0.6, 0),
					Parent = button.MoveNameContainer
				}),
				Scaled = true
			})
		else
			local name1 = zmove.move
			local name2
			local len = name1:len()
			local splitPosition, dif
			local start = 1
			while true do
				local s = name1:find(" ", start, true)
				if not s then
					break
				end
				local tdif = math.abs(len - s - s + 1)
				if not dif or dif > tdif then
					splitPosition, dif = s, tdif
				end
				start = s + 1
			end
			if splitPosition then
				name2 = name1:sub(splitPosition + 1)
				name1 = name1:sub(1, splitPosition - 1)
			end
			write(name1)({
				Frame = create("Frame")({				
					BackgroundTransparency = 1,					
					Size = UDim2.new(0, 0, 0.8, 0),
					Position = UDim2.new(0, 0, 0.1, 0),
					Parent = button.MoveNameContainer
				}),
				Scaled = true
			})
			if name2 then
				write(name2)({
					Frame = create("Frame")({
						BackgroundTransparency = 1,						
						Size = UDim2.new(0, 0, 0.8, 0),
						Position = UDim2.new(0, 0, 1.1, 0),
						Parent = button.MoveNameContainer
					}),
					Scaled = true
				})
			end
		end
	end
	function BattleGui:updateButtonForMaxMove(button, move, maxMove)
		local battle = _p.Battle.currentBattle
		button.MoveNameContainer:ClearAllChildren()
		button.TypeContainer:ClearAllChildren()
		button.PPContainer:ClearAllChildren()
		button.Effectiveness.Visible = false

		if not move or maxMove == '' then
			button.ImageColor3 = Color3.new(0.5, 0.5, 0.5)
			button.ImageTransparency = 0.5
			return
		end
		local tc = typeColors[move.type]
		button.ImageColor3 = tc
		button.ImageTransparency = 0

		--Effectiveness Arrows
		pcall(function()
			if not move.effective and _p.Battle.currentBattle.p2.active[1] then
				local effect = {}
				for ind, val in pairs(_p.Pokemon:getTypes(battle.yourSide.active[1].types)) do
					if move.category == 'Status' or not typeChart[val][move.type] then
						button.Effectiveness.Visible = false
					else
						effect[ind] = typeChart[val][move.type]
					end
				end
				move.effective = effect
			end

			if move.effective and move.category ~= 'Status' and _p.Menu.options.typeArrows then
				local maxEffectiveness = 1
				for _, e in pairs(move.effective) do
					if typeof(e) == "number" then
						maxEffectiveness = maxEffectiveness * e
						--print("MaxEffective is: ", maxEffectiveness)
					end
				end

				if maxEffectiveness ~= 1 then
					button.Effectiveness.Visible = true
					if maxEffectiveness < 0.5 then
						button.Effectiveness.ImageRectOffset = Vector2.new(300, 0)
					elseif maxEffectiveness < 1 then
						button.Effectiveness.ImageRectOffset = Vector2.new(300, 300)
					elseif maxEffectiveness > 1 and maxEffectiveness <= 2 then
						button.Effectiveness.ImageRectOffset = Vector2.new(0, 300)
					elseif maxEffectiveness > 2 then
						button.Effectiveness.ImageRectOffset = Vector2.new(0, 0)
					else
						button.Effectiveness.Visible = false
					end
				end
			end
		end)

		local name1 = maxMove.name
		local name2
		local len = name1:len()
		local splitPosition, dif
		local start = 1
		while true do
			local s = name1:find(" ", start, true)
			if not s then
				break
			end
			local tdif = math.abs(len - s - s + 1)
			if not dif or dif > tdif then
				splitPosition, dif = s, tdif
			end
			start = s + 1
		end
		if splitPosition then
			name2 = name1:sub(splitPosition + 1)
			name1 = name1:sub(1, splitPosition - 1)
		end
		write(name1)({
			Frame = create("Frame")({				
				BackgroundTransparency = 1,					
				Size = UDim2.new(0, 0, 0.8, 0),
				Position = UDim2.new(0, 0, 0.1, 0),
				Parent = button.MoveNameContainer
			}),
			Scaled = true
		})
		if name2 then
			write(name2)({
				Frame = create("Frame")({
					BackgroundTransparency = 1,						
					Size = UDim2.new(0, 0, 0.8, 0),
					Position = UDim2.new(0, 0, 1.1, 0),
					Parent = button.MoveNameContainer
				}),
				Scaled = true
			})
		end
	end

	function BattleGui:updateButtonForMove(button, move, og, hptype)
		local battle = _p.Battle.currentBattle
		button.MoveNameContainer:ClearAllChildren()
		button.TypeContainer:ClearAllChildren()
		button.PPContainer:ClearAllChildren()
		button.Effectiveness.Visible = false

		if not move or move == '' then
			button.ImageColor3 = Color3.new(.5, .5, .5)
			button.ImageTransparency = 0.5

			return
		end
		if move.move == "Hidden Power" and hptype then
			move.type = hptype
		end
		local tc = typeColors[move.type]

		--Effectiveness Arrows
		pcall(function()
			if not move.effective and _p.Battle.currentBattle.p2.active[1] then
				local effect = {}
				for ind, val in pairs(_p.Pokemon:getTypes(battle.yourSide.active[1].types)) do
					if move.category == 'Status' or not typeChart[val][move.type] then
						button.Effectiveness.Visible = false
					else
						effect[ind] = typeChart[val][move.type]
					end
				end
				move.effective = effect
			end

			if move.effective and move.category ~= 'Status' and _p.Menu.options.typeArrows then
				local maxEffectiveness = 1
				for _, e in pairs(move.effective) do
					if typeof(e) == "number" then
						maxEffectiveness = maxEffectiveness * e
						--print("MaxEffective is: ", maxEffectiveness)
					end
				end

				if maxEffectiveness ~= 1 then
					button.Effectiveness.Visible = true
					if maxEffectiveness < 0.5 then
						button.Effectiveness.ImageRectOffset = Vector2.new(300, 0)
					elseif maxEffectiveness < 1 then
						button.Effectiveness.ImageRectOffset = Vector2.new(300, 300)
					elseif maxEffectiveness > 1 and maxEffectiveness <= 2 then
						button.Effectiveness.ImageRectOffset = Vector2.new(0, 300)
					elseif maxEffectiveness > 2 then
						button.Effectiveness.ImageRectOffset = Vector2.new(0, 0)
					else
						button.Effectiveness.Visible = false
					end
				end
			end
		end)

		button.ImageColor3 = tc 
		button.ImageTransparency = 0.0
		if not og then
			button.Position = UDim2.new(-1,0,0,0)
		end
		write(move.move or move.name or move) {
			Frame = button.MoveNameContainer,
			Scaled = true,
		}
		write(move.type) {
			Frame = button.TypeContainer,
			Color = Color3.new(tc.r*1.2, tc.g*1.2, tc.b*1.2),
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
		}
		write('PP '..move.pp..'/'..move.maxpp) {
			Frame = button.PPContainer,
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}
	end

	function BattleGui:fightChoices(moveset, rqPokemon, slot, nActive, alreadyChoseMega, zMoveUsed, alreadyChoseUltra, alreadyChoseDmax)
		state = 'animating'
		self.onMoveClicked = function(m)
			local move = self.moves[m]
			if not move then return end
			if move.pp <= 0 then
				state = 'canteven'
				self:message('There\'s no PP left for this move!')
				state = 'canchoosemove'
				return
			elseif move.disabled and not (gui.dynamax.selected or gui.gigantamax.selected) then
				state = 'canteven'
				self:message('This move cannot be used!')
				state = 'canchoosemove'
				return
			end
			if nActive > 1 then
				self:chooseMoveTarget(m, move, rqPokemon, slot, nActive)
			else
				local option = ''
				if gui.mega.selected then option = ' mega' elseif gui.zmove.selected then option = ' zmov' elseif gui.ultra.selected then option = ' ultra' elseif (gui.dynamax.selected or gui.gigantamax.selected) then option = ' dynamax' elseif (rqPokemon.currentDyna) then option = ' maxmove' end
				self.inputEvent:fire('move '..m..option)
				self:exitButtonsMoveChosen()
			end
		end
		local main = gui.main
		local container = main.container
		local moves, mega, cancel, zmove, ultra, dynamax, gigantamax = gui.moves, gui.mega, gui.cancel, gui.zmove, gui.ultra, gui.dynamax, gui.gigantamax


		if not moves then

			moves = {false, false, false, false}
			for i = 1, 4 do
				moves[i] = create 'ImageLabel' { -- 522 x 130
					Name = 'Move'..i,
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://5348186988',
					ImageRectSize = Vector2.new(393, 99),
					Size = UDim2.new(1.0, 0, 1.0, 0),
					Parent = container,

					create 'ImageButton' {
						Name = 'Button',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.6, 0, 1.0, 0),
						Position = UDim2.new(0.2, 0, 0.0, 0),
						ZIndex = 7,
						MouseButton1Click = function()
							if state ~= 'canchoosemove' then return end
							if moves[i].ImageTransparency == 0.5 then return end
							self.onMoveClicked(i)
						end,
					},
					create 'Frame' {
						Name = 'MoveNameContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.4, 0),
						Position = UDim2.new(0.5, 0, 0.09, 0),
						ZIndex = 8,
					},
					create 'Frame' {
						Name = 'TypeContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.25, 0),
						Position = UDim2.new(0.4, 0, 0.585, 0),
						ZIndex = 8,
					},
					create 'Frame' {
						Name = 'PPContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.25, 0),
						Position = UDim2.new(0.5, 0, 0.585, 0),
						ZIndex = 8,
					},
					create("ImageLabel")({
						Name = "Effectiveness",
						BackgroundTransparency = 1,
						Visible = false,
						Image = "rbxassetid://131625090461846",--2923101222
						ImageRectSize = Vector2.new(300, 300),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(0.7, 0, 0.7, 0),
						AnchorPoint = Vector2.new(i % 2 == 1 and 0 or 1, 0),
						Position = UDim2.new(i % 2 == 1 and 0.05 or 0.95, 0, 0.1, 0),
						ZIndex = 2
					})
				}
			end
			gui.moves = moves
			-- #ZMove
			zmove = _p.AnimatedSprite:new({
				sheets = {
					{id = 845490260, rows = 10}
				},
				nFrames = 20,
				fWidth = 393,
				fHeight = 99,
				framesPerRow = 2,
				button = true
			})
			zmove:RenderFirstFrame()
			zmove.selected = false
			local s = zmove.spriteLabel
			s.Size = UDim2.new(1, 0, 1, 0)
			s.Visible = false
			s.Parent = container
			local zWrittenWord = write("Z-Power")({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0.4, 0),
					Position = UDim2.new(0, 0, 0.3, 0),
					ZIndex = 8,
					Parent = s
				}),
				Scaled = true
			})
			local zLetters = {}
			local zPos = {}
			for _, l in pairs(zWrittenWord.Labels) do
				local p = (l.AbsolutePosition.X - s.AbsolutePosition.X) / s.AbsoluteSize.X
				zLetters[l] = p
				zPos[l] = l.Position
			end	
			local st = tick()
			function zmove.updateCallback(a)
				if a then
					local ta = math.min(1, (tick() - st) * 3)
					for l, p in pairs(zLetters) do
						local o = (a + p) % 1
						l.Position = zPos[l] + UDim2.new(0, 0, 0.2 * ta * math.sin(o * math.pi * 2), 0)
					end
				else
					local c = Color3.new(1, 1, 1)
					for l in pairs(zLetters) do
						l.Position = zPos[l]
					end
				end
			end

			s.MouseButton1Click:connect(function()
				if zmove.paused then
					zmove.selected = true
					zmove:Play()
					self.ZMoveUpdate()

				else
					zmove.selected = false
					zmove:Pause()
					self.moveUpdate(true)
					zmove.updateCallback(nil)

				end
			end)
			gui.zmove = zmove
			-- #Ultra
			ultra = _p.AnimatedSprite:new({
				sheets = {
					{id = 845490260, rows = 10}
				},
				nFrames = 20,
				fWidth = 393,
				fHeight = 99,
				framesPerRow = 2,
				button = true
			})
			ultra:RenderFirstFrame()
			ultra.selected = false
			local s = ultra.spriteLabel
			s.Size = UDim2.new(1, 0, 1, 0)
			s.Visible = false
			s.Parent = container
			local ultraWrittenWord = write("Ultra Burst")({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0.4, 0),
					Position = UDim2.new(0, 0, 0.3, 0),
					ZIndex = 8,
					Parent = s
				}),
				Scaled = true,
				Color = Color3.fromRGB(255, 154, 0),

			})
			local ultraLetters = {}
			local zPos = {}
			for _, l in pairs(ultraWrittenWord.Labels) do
				local p = (l.AbsolutePosition.X - s.AbsolutePosition.X) / s.AbsoluteSize.X
				ultraLetters[l] = p
				zPos[l] = l.Position
			end	
			local st = tick()
			function ultra.updateCallback(a)
				if a then
					local ta = math.min(1, (tick() - st) * 3)
					for l, p in pairs(ultraLetters) do
						local o = (a + p) % 1
						l.Position = zPos[l] + UDim2.new(0, 0, 0.2 * ta * math.sin(o * math.pi * 2), 0)
					end
				else
					local c = Color3.new(1, 1, 1)
					for l in pairs(ultraLetters) do
						l.Position = zPos[l]
					end
				end
			end

			s.MouseButton1Click:connect(function()
				if ultra.paused then
					ultra.selected = true
					ultra:Play()

				else
					ultra.selected = false
					ultra:Pause()					
					ultra.updateCallback(nil)

				end
			end)
			gui.ultra = ultra
			-- #Dynamax/Gmax
			-- {id = (rqPokemon.canDynamax = 1 and 6458144706 or 6458176889) , rows = 10}

			dynamax = _p.AnimatedSprite:new({
				sheets = {
					{id = 136938232437874, rows = 10} --Need to make change depending on Gmax/Dmax
				},
				nFrames = 20,
				fWidth = 393,
				fHeight = 99,
				framesPerRow = 2,
				button = true
			})
			dynamax:RenderFirstFrame()
			dynamax.selected = false
			local s = dynamax.spriteLabel
			s.Size = UDim2.new(1, 0, 1, 0)
			s.Visible = false
			s.Parent = container
			local dynamaxWrittenWord = write("Dynamax")({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0.4, 0),
					Position = UDim2.new(0, 0, 0.3, 0),
					ZIndex = 8,
					Parent = s
				}),
				Scaled = true,
				Color = Color3.fromRGB(68, 0, 255),
			})
			s.MouseButton1Click:connect(function()
				if dynamax.paused then
					dynamax.selected = true
					dynamax:Play()
					self.maxMoveUpdate()
				else
					dynamax.selected = false
					dynamax:Pause()	
					self.moveUpdate(true)

				end
			end)
			gui.dynamax = dynamax

			gigantamax = _p.AnimatedSprite:new({
				sheets = {
					{id = 74907392243945, rows = 10} --Need to make change depending on Gmax/Dmax
				},
				nFrames = 20,
				fWidth = 393,
				fHeight = 99,
				framesPerRow = 2,
				button = true
			})
			gigantamax:RenderFirstFrame()
			gigantamax.selected = false
			local s = gigantamax.spriteLabel
			s.Size = UDim2.new(1, 0, 1, 0)
			s.Visible = false
			s.Parent = container
			local gigantamaxWrittenWord = write("Gigantamax")({ 
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0.4, 0),
					Position = UDim2.new(0, 0, 0.3, 0),
					ZIndex = 8,
					Parent = s
				}),
				Scaled = true,
				Color = Color3.fromRGB(92, 0, 7),
			})
			s.MouseButton1Click:connect(function()
				if gigantamax.paused then
					gigantamax.selected = true
					gigantamax:Play()
					self.maxMoveUpdate()

				else
					gigantamax.selected = false
					gigantamax:Pause()	
					self.moveUpdate(true)

				end
			end)
			gui.gigantamax = gigantamax
			-- #MEGA
			mega = _p.AnimatedSprite:new{sheets={{id=5348186988,rows=10}},nFrames=20,fWidth=393,fHeight=99,framesPerRow=2,button=true}
			mega:RenderFirstFrame()
			mega.selected = false
			local s = mega.spriteLabel
			s.Size = UDim2.new(1, 0, 1, 0) -- 0.9 = 1
			s.Visible = false
			s.Parent = container
			local megaWrittenWord = write 'Mega' { --Mega
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					--				Size = UDim2.new(1.0, 0, 0.5, 0),
					--				Position = UDim2.new(0.0, 0, 0.25, 0),
					Size = UDim2.new(0.0, 0, 0.38, 0),
					Position = UDim2.new(0.5, 0, 0.09, 0),
					ZIndex = 8, Parent = s,
				}, Scaled = true,
			}
			local letters = {}
			local evolutionWrittenWord = write 'Evolution' { --Evolution
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.275, 0),
					Position = UDim2.new(0.5, 0, 0.585, 0),
					ZIndex = 8, Parent = s,
				}, Scaled = true,
			}
			--		assert(container.Parent ~= nil, ':l')
			for _, l in pairs(megaWrittenWord.Labels) do
				local p = (l.AbsolutePosition.X - s.AbsolutePosition.X) / s.AbsoluteSize.X
				letters[l] = p
			end
			for _, l in pairs(evolutionWrittenWord.Labels) do
				local p = (l.AbsolutePosition.X - s.AbsolutePosition.X) / s.AbsoluteSize.X
				letters[l] = p
			end
			mega.updateCallback = function(a)
				if a then
					local hue_center = a+.25
					for l, p in pairs(letters) do
						l.ImageColor3 = Color3.fromHSV((hue_center + (p-.5)*.4)%1, .75, 1)
					end
				else
					local c = Color3.new(1, 1, 1)--Color3.fromRGB(255, 102, 75)--BrickColor.new('Crimson').Color
					for l in pairs(letters) do
						l.ImageColor3 = c
					end
				end
			end
			s.MouseButton1Click:connect(function()
				if mega.paused then
					mega.selected = true
					mega:Play()

				else
					mega.selected = false
					mega:Pause()
					mega.updateCallback(nil)
				end
			end)
			gui.mega = mega
		end
		local zMoves = rqPokemon.canZMove
		local maxMoves = rqPokemon.maxMoves

		local fight, bag, pokemon, run = main.fight, main.bag, main.pokemon, main.run
		local moveCancel = run.Visible
		cancel.Visible = true
		function self.moveUpdate(og)
			for i = 1, 4 do
				self:updateButtonForMove(moves[i], moveset[i], og, rqPokemon.hpType)
				moves[i].Visible = true
			end
		end
		function self.ZMoveUpdate() 
			for i = 1, 4 do
				self:updateButtonForZMove(moves[i], moveset[i], zMoves[i])
				moves[i].Visible = true
			end
		end
		function self.maxMoveUpdate() 
			for i = 1, 4 do
				local s,r = pcall(function()
					self:updateButtonForMaxMove(moves[i], moveset[i], maxMoves[i])
				end)
				if not s then
					print("Error: ", r)
				end
				moves[i].Visible = true
			end
		end
		if rqPokemon.currentDyna then
			self.maxMoveUpdate() 
		else
			self.moveUpdate()	
		end

		if rqPokemon and rqPokemon.canMegaEvo and not alreadyChoseMega then
			mega.spriteLabel.Visible = true
			--		mega:Play(1)
			mega.updateCallback(nil)
		else
			mega.spriteLabel.Visible = false
			--		mega:Pause()
		end
		if rqPokemon and rqPokemon.canDynamax and not alreadyChoseDmax then
			dynamax.spriteLabel.Visible = true
			--		mega:Play(1)
		else
			dynamax.spriteLabel.Visible = false
			--		mega:Pause()
		end
		if rqPokemon and rqPokemon.gigantamax and not alreadyChoseDmax then
			gigantamax.spriteLabel.Visible = true
			--		mega:Play(1)
		else
			gigantamax.spriteLabel.Visible = false
			--		mega:Pause()
		end
		if rqPokemon and rqPokemon.canUltra and not alreadyChoseUltra then
			ultra.spriteLabel.Visible = true
			--		mega:Play(1)
			ultra.updateCallback(nil)
		else
			ultra.spriteLabel.Visible = false
			--		mega:Pause()
		end
		if rqPokemon and rqPokemon.canZMove and not zMoveUsed and not rqPokemon.canUltra then
			zmove.spriteLabel.Visible = true	
			zmove.updateCallback(nil)
		else
			zmove.spriteLabel.Visible = false
		end
		local ms = mega.spriteLabel
		local zm = zmove.spriteLabel
		local ub = ultra.spriteLabel
		local dm = dynamax.spriteLabel
		local gm = gigantamax.spriteLabel

		Utilities.Tween(.6, 'easeOutCubic', function(a)
			local o = 1-a
			run.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+run.AbsoluteSize.Y)*a)
			bag.Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -(container.AbsolutePosition.X+bag.AbsoluteSize.X)*a, 0.0, 0)
			pokemon.Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+pokemon.AbsoluteSize.Y)*a, 0.0, 0)
			ms.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*o)
			zm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y+36)*o)
			ub.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y+36)*o)
			dm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y+36)*o)
			gm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y+36)*o)

			local l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*o
			moves[1].Position = UDim2.new(-424/522, 0, -135/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			moves[3].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*o
			moves[2].Position = UDim2.new(424/522, 0, -135/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			moves[4].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			if moveCancel then
				cancel.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+run.AbsoluteSize.Y)*o)
			end
		end)
		bag.Visible, pokemon.Visible, run.Visible = false, false, false
		state = 'canchoosemove'
	end

	function BattleGui:exitButtonsMoveChosen()
		state = 'animating'
		local main = gui.main
		local fight, ms, zm, ub, dm, gm = main.fight, gui.mega.spriteLabel, gui.zmove.spriteLabel, gui.ultra.spriteLabel, gui.dynamax.spriteLabel, gui.gigantamax.spriteLabel
		local container = main.container
		local moves, cancel = gui.moves, gui.cancel
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			local o = 1-a
			fight.Position = UDim2.new(0.0, 0, -135/130/2, 0) + UDim2.new(0.0, 0, 0.0, -(container.AbsolutePosition.Y+fight.AbsoluteSize.Y+36)*a)
			ms.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y*2+36)*a)
			zm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y*2+36)*a)
			ub.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y*2+36)*a)
			dm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y*2+36)*a)
			gm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+zm.AbsoluteSize.Y*2+36)*a)

			local l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*a
			moves[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			moves[3].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*a
			moves[2].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			moves[4].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			cancel.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+cancel.AbsoluteSize.Y)*a)
		end)
		gui.mega.selected = false
		gui.mega:Pause()
		gui.zmove.selected = false
		gui.zmove:Pause()
		gui.ultra.selected = false
		gui.ultra:Pause()
		gui.dynamax.selected = false
		gui.dynamax:Pause()
		gui.gigantamax.selected = false
		gui.gigantamax:Pause()
		for i = 1, 4 do
			moves[i].Visible = false
		end
		container.Visible = false
		state = 'canchoosemain'
	end
	function BattleGui:animGMax(battle, poke)
		task.wait(0.5) -- defer from call instead?

		local cam = workspace.CurrentCamera

		local Models = _p.storage.Models
		local Pokeballs = Models.Pokeballs
		local Misc = Models.Misc

		local gmaxField = Misc.GMove:Clone()
		local gmaxBall = Pokeballs.gigantamaxball:Clone()
		local pokeBall = Models.pokeball:Clone()

		local fieldMain = gmaxField.Main

		local sprite = poke.sprite
		local spriteAnimation = sprite.animation
		local spriteLabel = spriteAnimation.spriteLabel
		local spritePos = spriteLabel.Position
		local spriteSize = spriteLabel.ImageRectSize

		local originalSpriteData = sprite.spriteData
		local originalSpriteCFrame = sprite.cf
		local originalSpriteLabelSize = spriteSize

		local sideDirection = -1
		local sideNumber = sprite.siden
		local trainer
		local rarm, gripOffset, holdDur
		local speed = 1

		if sideNumber == 1 then
			sprite.isBackSprite = false
			sprite:updateSpriteData()
			sprite:renderNewSpriteData()

			sideDirection = 1

			do
				local spriteLabel = sprite.animation.spriteLabel
				local spriteSize = spriteLabel.ImageRectSize
				spriteLabel.ImageRectSize = Vector2.new(-spriteSize.X, spriteSize.Y)
				function sprite.animation.updateCallback()
					local spriteOffset = spriteLabel.ImageRectOffset
					spriteLabel.ImageRectOffset = Vector2.new(spriteOffset.X + spriteSize.X, spriteOffset.Y)
				end
			end
		end

		sprite.offset = Vector3.new()

		Utilities.MoveModel(fieldMain, battle.CoordinateFrame1 + Vector3.new(0, 100, 0))

		local mainPos = fieldMain.Position
		gmaxField.Parent = workspace
		sprite.cf = CFrame.new(mainPos) + Vector3.new(0, fieldMain.Size.Y / 2, 0)

		if self.kind ~= "2v2" then
			if sideNumber == 1 then
				trainer = battle.playerModelObj
			elseif sideNumber == 2 then
				trainer = battle.trainerModelObj
			end
		else
			trainer = battle.playerModelObj
		end

		local cp = gmaxField.PlayerPos.Position + Vector3.new(0, gmaxField.PlayerPos.Size.Y / 2 + 1.7999999999999998, 0)
		local tcf = CFrame.new(cp, Vector3.new(mainPos.X, cp.Y, mainPos.Z))
		trainer.Root.CFrame = tcf
		trainer.BodyPosition.Position = tcf.p
		trainer.BodyGyro.CFrame = tcf


		local parts = trainer.PartTransparencies
		if parts then
			for p, t in pairs(parts) do
				p.Transparency = t
			end
		end
		trainer.Model.Parent = battle.scene

		local disabledGuis = {}
		for _, side in pairs(battle.sides) do
			for _, active in pairs(side.active) do
				pcall(function()
					if active.statbar.main.Visible then
						active.statbar.main.Visible = false
						table.insert(disabledGuis, active.statbar.main)
					end
				end)
			end
		end

		local dif = (mainPos - cp) * Vector3.new(1, 0, 1)
		local distance = dif.magnitude
		dif = dif.unit
		local b = distance * 0.7
		local theta = -0.17 * sideDirection
		local dir = tcf * CFrame.Angles(0, theta, 0).lookVector
		local fov0 = cam.FieldOfView
		local a = b * math.tan(math.rad(fov0 / 2))
		local inAir = (sprite.spriteData.inAir or 0) * 0.75

		Utilities.FadeOut(.5)

		cam.CFrame = CFrame.new((cp + dir / b) + Vector3.new(0, 0, 3) , cp)

		Utilities.FadeIn(.75)

		Utilities.Tween(3, "easeOutQuart", function(alpha)
			local focus = cp + dif * distance * 0.75 * alpha
			local bt = b * (1 + 1.5 / alpha)
			local roll = math.rad(15 * alpha) * sideDirection
			cam.CFrame = CFrame.new((cp + dir / bt) + Vector3.new(0, 0, 86 * alpha), focus) * CFrame.Angles(0, 0, -roll) + Vector3.new(0, inAir, 0)
			cam.FieldOfView = (2 * math.deg(math.atan(alpha / bt)) + fov0) / 2
		end)

		local animTrack = trainer.ZDance
		local throwTrack = trainer.ThrowAnimation
		local oldFov = cam.FieldOfView

		battle:startGmaxGlow(sprite)

		local p2 = gmaxField.ThrowZoom.CFrame
		local p1 = p2 * CFrame.new(0, 0, 4)
		local p3, p4 = gmaxField.BeginThrow.CFrame, gmaxField.EndThrow.CFrame

		local function ballAppear(ball)          
			local ballmain = ball.Main

			if trainer then -- pokeball grows in hand
				rarm = trainer.Model:FindFirstChild('Right Arm') or trainer.Model:FindFirstChild('RightHand')
				gripOffset = (rarm.Name=='Right Arm') and 1 or .335/2
				holdDur    = (rarm.Name=='Right Arm') and .55 or .45
				if rarm then
					local trainerScale = trainer.Scale
					local scale = Utilities.ScaleModel
					local lastScale = 1

					if ball.Name == 'gigantamaxball' then
						delay(.2, function()
							ballmain.Attachment.Bolts.Enabled = true
							ballmain.Attachment.Bolts.Enabled = true
						end)
					end

					Utilities.Tween(speed, 'easeOutCubic', function(a)
						local newScale = .5 + .5*a
						scale(ballmain, newScale / lastScale, true)
						lastScale = newScale

						Utilities.MoveModel(ballmain, rarm.CFrame * CFrame.new(0, -(newScale*.5+gripOffset)*trainerScale, 0) * CFrame.Angles(-math.pi/2, 0, 0), true)
					end)
				end
			end
		end

		pokeBall.Parent = workspace

		Utilities.Tween(1, 'easeInSine', function(a) -- print(18.0562801361084 - 15.73066234588623) = 2.325617790222168 2.325617790222168x10
			cam.FieldOfView -= (a/10)
			cam.CFrame += Vector3.new(a/25, 0, 0)
		end)

		ballAppear(pokeBall)

		poke.sprite:animGUnsummon()

		pokeBall:Destroy()

		spriteLabel.ImageRectSize = spriteSize
		spriteLabel.Position = UDim2.new(spritePos.X, 0, spritePos.Y, 0)

		spriteLabel.Visible = false
		sprite.animation:Play()

		local doSeperateThreadTween = function(cam, prop, val, dur, timing)
			task.spawn(function()
				task.wait()
				Utilities.pTween(cam, prop, val, dur, timing)
			end)
		end

		doSeperateThreadTween(cam, "FieldOfView", oldFov, 1, "easeInCubic")
		Utilities.pTween(cam, "CFrame", gmaxField.HandZoom.CFrame, 1, "easeInCubic")

		gmaxBall.Parent = workspace

		ballAppear(gmaxBall)

		doSeperateThreadTween(cam, "FieldOfView", oldFov + 10, 1, "easeInOutCubic")
		Utilities.pTween(cam, "CFrame", gmaxField.HeadZoom.CFrame, 1, "easeInOutCubic")

		-- Follow the ball infornt of it... 
		if trainer then
			throwTrack:Play()
			local ballMain = gmaxBall.Main
			task.delay(holdDur, function()
				doSeperateThreadTween(cam, "FieldOfView", 30, 1, "easeInOutCubic")
				Utilities.pTween(cam, "CFrame", p2, 1, "easeInOutCubic")

				throwTrack:Stop()

				local lerp2 = select(2, Utilities.lerpCFrame(ballMain.CFrame, p3))
				Utilities.Tween(0.1, "easeOutCubic", function(a)
					Utilities.MoveModel(ballMain, lerp2(a), true)
				end)

				local lerp3 = select(2, Utilities.lerpCFrame(ballMain.CFrame, p4))
				Utilities.Tween(1, "easeOutCubic", function(a)
					Utilities.MoveModel(ballMain, lerp3(a) * CFrame.Angles(-a*7, 0, 0) + Vector3.new(0, math.sin(a*math.pi), 0), true)
				end)
			end)

			if rarm then
				local trainerScale = trainer.Scale
				Utilities.Tween(holdDur / speed, nil, function()
					Utilities.MoveModel(ballMain, rarm.CFrame * CFrame.new(0, -(.5+gripOffset)*trainerScale, 0) * CFrame.Angles(-math.pi/2, 0, 0), true)
				end)
			else
				task.wait(holdDur / speed)
			end
			local lerp = select(2, Utilities.lerpCFrame(ballMain.CFrame, p3))
			Utilities.Tween(1 / speed, 'easeOutCubic', function(a)
				Utilities.MoveModel(ballMain, lerp(a) * CFrame.Angles(-a*7, 0, 0) + Vector3.new(0, math.sin(a*math.pi), 0), true)
			end)
		end

		task.wait(1)
		pcall(function()
			animTrack:Destroy()
		end)
		trainer.Model.Parent = nil
		sprite.cf = originalSpriteCFrame
		if sprite.siden == 1 then
			sprite.isBackSprite = true
			sprite.spriteData = originalSpriteData
			sprite:renderNewSpriteData()
			sprite.animation.spriteLabel.ImageRectSize = originalSpriteLabelSize
			sprite.animation.updateCallback = nil
		end
		gmaxField:Destroy()
		gmaxBall:Destroy()

		cam.CFrame = battle.battleCamera.CoordinateFrame + battle.sceneOffset
		cam.FieldOfView = battle.battleCamera.FieldOfView

		for _, g in pairs(disabledGuis) do
			pcall(function()
				g.Visible = true
			end)
		end
		spriteLabel.Visible = false
	end

	-- battle:stopZPowerGlow() will happen a few seconds after gmax
	function BattleGui:cancelToMain()
		state = 'animating'
		local main = gui.main
		local fight, bag, pokemon, run = main.fight, main.bag, main.pokemon, main.run
		local container = main.container
		local moves, ms, cancel, zm, ub, dm, gm = gui.moves, gui.mega.spriteLabel, gui.cancel, gui.zmove.spriteLabel, gui.ultra.spriteLabel, gui.dynamax.spriteLabel, gui.gigantamax.spriteLabel
		local canRun = self.isFirstUserPokemon
		bag.Visible, pokemon.Visible, run.Visible = true, true, canRun
		if _p.Battle.currentBattle.kind == 'pvp' or _p.Battle.currentBattle.kind == '2v2' then
			bag.Visible = false
		end
		gui.zmove.selected = false
		gui.zmove:Pause()
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			local o = 1-a
			if canRun then
				run.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+run.AbsoluteSize.Y)*o)
				cancel.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+cancel.AbsoluteSize.Y)*a)
			end
			bag.Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -(container.AbsolutePosition.X+bag.AbsoluteSize.X)*o, 0.0, 0)
			pokemon.Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+pokemon.AbsoluteSize.Y)*o, 0.0, 0)
			local l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*a
			moves[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			moves[3].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*a
			moves[2].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			moves[4].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			ms.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)
			zm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)
			ub.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)
			dm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)
			gm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)

		end)
		for i = 1, 4 do
			moves[i].Visible = false
		end
		-- todo mega.visible = false
		state = 'canchoosemain'
	end

	function BattleGui:fastCancelMain()
		state = 'animating'
		local main = gui.main
		local fight, bag, pokemon, run = main.fight, main.bag, main.pokemon, main.run
		local container = main.container
		local moves, ms, cancel, zm, ub, dm, gm = gui.moves, gui.mega.spriteLabel, gui.cancel, gui.zmove.spriteLabel, gui.ultra.spriteLabel, gui.dynamax.spriteLabel, gui.gigantamax.spriteLabel
		local canRun = self.isFirstUserPokemon
		bag.Visible, pokemon.Visible, run.Visible = true, true, canRun
		if _p.Battle.currentBattle.kind == 'pvp' or _p.Battle.currentBattle.kind == '2v2' then
			bag.Visible = false
		end
		gui.zmove.selected = false
		gui.zmove:Pause()
		local a = 1
		local o = 0
		if canRun then
			run.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+run.AbsoluteSize.Y)*o)
			cancel.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+cancel.AbsoluteSize.Y)*a)
		end
		bag.Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -(container.AbsolutePosition.X+bag.AbsoluteSize.X)*o, 0.0, 0)
		pokemon.Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+pokemon.AbsoluteSize.Y)*o, 0.0, 0)
		local l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*a
		moves[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
		moves[3].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
		local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*a
		moves[2].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
		moves[4].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
		ms.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)
		zm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)
		ub.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)
		dm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)
		gm.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)
		for i = 1, 4 do
			moves[i].Visible = false
		end
		-- todo mega.visible = false
		state = 'canchoosemain'
	end

	function BattleGui:chooseSwitchSlot(options, fromSlot)
		local bg = create 'ImageButton' {
			AutoButtonColor = false,
			BackgroundTransparency = .4,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1.0, 0, 1.0, 60),
			Position = UDim2.new(0.0, 0, 0.0, -60),
			ZIndex = 4, Parent = Utilities.frontGui,
		}
		local s = 0.2
		local container = create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(s*4.5/3, 0, s, 0),
			Position = UDim2.new(0.5, 0, 0.5-s/2, 0),
			Parent = Utilities.frontGui,
		}
		write 'Switch to which position?' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.4, 0),
				Position = UDim2.new(0.0, 0, -1.5, 0),
				ZIndex = 5, Parent = container,
			}, Scaled = true,
		}
		local sig = Utilities.Signal()
		local battle = _p.Battle.currentBattle
		local rfs = {}
		local cancel = roundedFrame:new {
			Button = true,
			CornerRadius = Utilities.gui.AbsoluteSize.Y*.024,
			BackgroundColor3 = BrickColor.new('Crimson').Color, --Bright red (OLD) topia
			Size = UDim2.new(0.85, 0, 0.55, 0),
			Position = UDim2.new(-0.425, 0, 1.7, 0),
			ZIndex = 5, Parent = container,
			MouseButton1Click = function()
				sig:fire()
			end,
		}
		write 'Cancel' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.5, 0),
				Position = UDim2.new(0.0, 0, 0.25, 0),
				ZIndex = 6, Parent = cancel.gui,
			}, Scaled = true,
		}
		for s = 1, 2 do
			for a = 1, #options do
				local onClick
				if s == 1 and options[a] then
					onClick = function()
						sig:fire(a)
					end
				end
				local rf = roundedFrame:new {
					Button = onClick~=nil,
					CornerRadius = Utilities.gui.AbsoluteSize.Y*.03,
					BackgroundColor3 = Color3.new(.6, .6, .6),
					Size = UDim2.new(4/4.5, 0, 1.0, 0),
					ZIndex = 5, Parent = container,
					MouseButton1Click = onClick,
				}
				if s == 1 then
					rf.Position = UDim2.new(-(#options+1)/2+a-0.5+(1-4/4.5)/2, 0, 0.55, 0)
					if options[a] then
						rf.BackgroundColor3 = BrickColor.new('Dark green').Color
					else
						pcall(function()
							local p = battle.mySide.active[a]
							if p and p.hp > 0 then
								local icon = p:getIcon()
								icon.Size = UDim2.new(0.6, 0, 0.6, 0)
								icon.Position = UDim2.new(0.2, 0, 0.2, 0)
								icon.ZIndex = 6
								icon.Parent = rf.gui
							end
						end)
					end
				else
					rf.Position = UDim2.new((#options+1)/2-a-0.5+(1-4/4.5)/2, 0, -0.55, 0)
					pcall(function()
						local p = battle.yourSide.active[a]
						if p and p.hp > 0 then
							local icon = p:getIcon()
							icon.Size = UDim2.new(0.6, 0, 0.6, 0)
							icon.Position = UDim2.new(0.2, 0, 0.2, 0)
							icon.ZIndex = 6
							icon.Parent = rf.gui
						end
					end)
				end
				table.insert(rfs, rf)
			end
		end
		local r = sig:wait()
		for _, rf in pairs(rfs) do
			rf:destroy()
		end
		container:Destroy()
		bg:Destroy()
		return r
	end

	function BattleGui:choosePokemon(selectionText, cannotCancel) -- yay for ugly hacks
		Menu.party.selectionText = selectionText
		local s = self:switchPokemon(cannotCancel and true or false)
		Menu.party.selectionText = nil
		return s
	end
	function BattleGui:chooseRaid(selectionText, cannotCancel) -- yay for ugly hacks
		Menu.party.selectionText = selectionText
		local s = self:switchRaid(cannotCancel and true or false)
		Menu.party.selectionText = nil
		return s
	end
	function BattleGui:switchRaid(forced, chooseSlot, alreadySwitched, toSlot)
		local battle = _p.Battle.currentBattle
		local sig = Utilities.Signal()
		Menu.party.battleEvent = sig
		spawn(function()
			-- ugly hack, BUT much less ugly with PDS up-to-date-with-battle party data
			if self.side then
				local nActive = self.side.nTeamActive or self.side.nActive -- OVH  one reason we need to keep side
				Menu.party.nActive = nActive
			else
				Menu.party.partyOrder = nil
				Menu.party.nActive = 0
			end
			Menu.party.alreadySwitched = alreadySwitched
			Menu.party.forceSwitch = forced
			Menu.party.chooseItemTarget = false
			Menu.party:open()
		end)
		spawn(function()
			if forced or not gui or not gui.main then return end
			local container = gui.main.container
			container.Parent = Utilities.backGui
			self:exitButtonsMain()
			container.Parent = Utilities.gui
		end)
		while true do
			local res, slot = sig:wait()
			if res == 'cancel' then
				spawn(function() Menu.party:close() end)
				if not forced then return false end
			elseif res == 'switch' then
				if Menu.party.selectionText then
					--				local partyData = Menu.party.partyData
					Menu.party:close()
					return slot--, partyData
				else
					local partyData = Menu.party.partyData
					local poke = partyData[slot]
					local pokemonSwitchingOut, pokemonSwitchingOutIsTrapped, pokemonSwitchingOutIsMaybeTrapped
					pcall(function()
						local activeMon = _p.Battle.currentBattle.fulfillingRequest.active[toSlot]
						pokemonSwitchingOut = partyData[toSlot] -- no longer a Pokemon object
						pokemonSwitchingOutIsTrapped = activeMon.trapped and true or false
						pokemonSwitchingOutIsMaybeTrapped = activeMon.maybeTrapped and true or false
					end)
					local placeId = game.PlaceId

					if poke.egg then -- OVH  todo: test these cases
						self:message('You can\'t send an Egg into battle!')
					elseif poke.hp <= 0 then
						self:message(poke.name .. ' has no energy left to battle!')
					elseif poke.id == 150 then
						self:message(poke.name .. ' is banned in the coloseum!')
					elseif pokemonSwitchingOutIsTrapped then
						self:message(pokemonSwitchingOut.name .. ' is trapped! It can\'t escape!')
					else
						local isTrapped = false
						if pokemonSwitchingOutIsMaybeTrapped then -- OVH  todo: test this
							local battle = _p.Battle.currentBattle
							local t, s, e = _p.Network:get('BattleFunction', battle.battleId, 'isTrapped', battle.sideId, toSlot)
							isTrapped = t
							local msg = false
							if t and s and e and e ~= '' then
								local poke = battle:getPokemon(s)
								if poke then
									msg = true
									self:message(poke:getName() .. '\'s ' .. e .. ' prevents switching!')
								end
							end
							if t and not msg then
								-- backup generic message
								self:message(pokemonSwitchingOut.name .. ' is trapped! It can\'t escape!')
							end
						end
						if not isTrapped then
							local fixedSlot = slot
							if self.side and self.side.indexFix and poke.bindex then
								fixedSlot = self.side.indexFix[poke.bindex]
								print(string.format('slot: %d; index: %d; b_index: %d; slot_fix: %d', slot or -1, poke.index or -1, poke.bindex or -1, fixedSlot or -1))
								Utilities.print_r(self.side.indexFix)
							else
								--print('slot:', slot or -1, '[no fix]')
							end
							if chooseSlot then -- multiple faints, need to choose which slot to fill
								local toSlot = self:chooseSwitchSlot(forced, slot) -- I think this is correct usage
								if toSlot then
									self.inputEvent:fire('switch '..fixedSlot, toSlot)
									Menu.party:close()
									return true
								end
							else
								self.inputEvent:fire('switch '..fixedSlot)
								Menu.party:close()
								return true
							end
						end
					end
				end
			end			
		end	
	end
	function BattleGui:switchPokemon(forced, chooseSlot, alreadySwitched, toSlot)
		local battle = _p.Battle.currentBattle
		local sig = Utilities.Signal()
		Menu.party.battleEvent = sig
		if battle and battle.isRaid then
			storage.Models.Win.Value = 'Lose'
			self:message('You failed the raid :(')
			battle.ended = true
			battle.BattleEnded:fire()
		else
			spawn(function()
				-- ugly hack, BUT much less ugly with PDS up-to-date-with-battle party data
				if self.side then
					local nActive = self.side.nTeamActive or self.side.nActive -- OVH  one reason we need to keep side
					Menu.party.nActive = nActive
				else
					Menu.party.partyOrder = nil
					Menu.party.nActive = 0
				end
				Menu.party.alreadySwitched = alreadySwitched
				Menu.party.forceSwitch = forced
				Menu.party.chooseItemTarget = false
				Menu.party:open()
			end)
			spawn(function()
				if forced or not gui or not gui.main then return end
				local container = gui.main.container
				container.Parent = Utilities.backGui
				self:exitButtonsMain()
				container.Parent = Utilities.gui
			end)
			while true do
				local res, slot = sig:wait()
				if res == 'cancel' then
					spawn(function() Menu.party:close() end)
					if not forced then return false end
				elseif res == 'switch' then
					if Menu.party.selectionText then
						--				local partyData = Menu.party.partyData
						Menu.party:close()
						return slot--, partyData
					else
						local partyData = Menu.party.partyData
						local poke = partyData[slot]
						local pokemonSwitchingOut, pokemonSwitchingOutIsTrapped, pokemonSwitchingOutIsMaybeTrapped
						pcall(function()
							local activeMon = _p.Battle.currentBattle.fulfillingRequest.active[toSlot]
							pokemonSwitchingOut = partyData[toSlot] -- no longer a Pokemon object
							pokemonSwitchingOutIsTrapped = activeMon.trapped and true or false
							pokemonSwitchingOutIsMaybeTrapped = activeMon.maybeTrapped and true or false
						end)
						local placeId = game.PlaceId

						if poke.egg then -- OVH  todo: test these cases
							self:message('You can\'t send an Egg into battle!')
						elseif poke.hp <= 0 then
							self:message(poke.name .. ' has no energy left to battle!')
						elseif poke.id == 150 then
							self:message(poke.name .. ' is banned in the coloseum!')
						elseif pokemonSwitchingOutIsTrapped then
							self:message(pokemonSwitchingOut.name .. ' is trapped! It can\'t escape!')
						else
							local isTrapped = false
							if pokemonSwitchingOutIsMaybeTrapped then -- OVH  todo: test this
								local battle = _p.Battle.currentBattle
								local t, s, e = _p.Network:get('BattleFunction', battle.battleId, 'isTrapped', battle.sideId, toSlot)
								isTrapped = t
								local msg = false
								if t and s and e and e ~= '' then
									local poke = battle:getPokemon(s)
									if poke then
										msg = true
										self:message(poke:getName() .. '\'s ' .. e .. ' prevents switching!')
									end
								end
								if t and not msg then
									-- backup generic message
									self:message(pokemonSwitchingOut.name .. ' is trapped! It can\'t escape!')
								end
							end
							if not isTrapped then
								local fixedSlot = slot
								if self.side and self.side.indexFix and poke.bindex then
									fixedSlot = self.side.indexFix[poke.bindex]
									print(string.format('slot: %d; index: %d; b_index: %d; slot_fix: %d', slot or -1, poke.index or -1, poke.bindex or -1, fixedSlot or -1))
									Utilities.print_r(self.side.indexFix)
								else
									--print('slot:', slot or -1, '[no fix]')
								end
								if chooseSlot then -- multiple faints, need to choose which slot to fill
									local toSlot = self:chooseSwitchSlot(forced, slot) -- I think this is correct usage
									if toSlot then
										self.inputEvent:fire('switch '..fixedSlot, toSlot)
										Menu.party:close()
										return true
									end
								else
									self.inputEvent:fire('switch '..fixedSlot)
									Menu.party:close()
									return true
								end
							end
						end
					end
				end
			end
		end	
	end
	function BattleGui:afterBattle()
		spawn(function() self:toggleRemainingPartyGuis(false) end)
		spawn(function() self:toggleFC(false) end)
		pcall(function() gui.main.container.Parent = nil end)
		pcall(function() gui.targetContainer.Parent = nil end)
		local s = Utilities.gui.AbsoluteSize
		local p = UDim2.new(10.0, s.X*3, 10.0, s.Y*3)
		pcall(function()
			for i = 1, 4 do
				gui.moves[i].Position = p
			end
		end)
		pcall(function() gui.cancel.Position = p end)
	end

	function BattleGui:createFoeHealthGui(nActive, slot)
		local yPos = 0.15
		local battle = _p.Battle.currentBattle
		local hg = {}
		if battle.isRaid then
			hg.main = create('Frame')({
				Name = 'FoeHealthGui',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				Parent = Utilities.backGui,
				--	Visible = false,
				create 'Frame' {
					Name = 'NameContainer',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					ZIndex = 4,
				},

			})
			hg.statusrf = roundedFrame:new {
				Name = 'status',
				Size = UDim2.new(0.15, 0, 0.07, 0),
				Position = UDim2.new(0.025, 0, 0.625, 0),
				Style = 'HorizontalBar',
				ZIndex = 4,
				Parent = hg.main,--.gui,
				create 'Frame' {
					Name = 'text',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.8, 0),
					Position = UDim2.new(0.5, 0, 0.1, 0),
					ZIndex = 5,
				},
			}
			hg.hpdiv = roundedFrame:new {
				Name = 'hpdiv',
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(0.75, 0, 0.03, 0),
				Position = UDim2.new(0.15, 0, 0.06, 0),
				Style = 'HorizontalBar',
				ZIndex = 4,
				Parent = hg.main,--.gui,

				create 'Frame' {
					Name = 'text',
					BackgroundTransparency = 1.0,
					Visible = false,
					Size = UDim2.new(0.0, 0, 1.0, 0),
					Position = UDim2.new(0.12, 0, 0.0, 0),
					ZIndex = 5,
				},
			}
			hg.hpfill = roundedFrame:new {
				Name = 'container',
				BackgroundColor3 = Color3.new(.9, .9, .9),
				Size = UDim2.new(1, 0, 1, 0),
				--AnchorPoint = Vector2.new(.5, 0),
				Position = UDim2.new(0, 0, 0, 0),
				Style = 'HorizontalBar',
				ZIndex = 5,
				Parent = hg.main.hpdiv,
			}
			hg.hpfill:setupFillbar('gyr', 0)

			function hg:update(pokemon)
				pokemon = pokemon or self.pokemon
				local gui = self.main--.gui
				gui.NameContainer:ClearAllChildren()
				gui.status.text:ClearAllChildren()
				local genderQry = ''
				if (pokemon.data and pokemon.data.num ~= 29 and pokemon.data.num ~= 32) or (pokemon.species and pokemon.species ~= 'nidoranf' and pokemon.species ~= 'nidoranm') and pokemon.gender and pokemon.gender ~= '' then
					genderQry = ' '..pokemon.gender:upper()..']'
				elseif pokemon.data and pokemon.data.gigantamax then
					genderQry = ' '
				end
				local Empties = write(pokemon:getShortName()) {
					Frame = gui.NameContainer,
					Scaled = true,
					--Font = "Outlined",
					TextXAlignment = Enum.TextXAlignment.Center,
					Color = Color3.fromRGB(193, 129, 0),

				}.Empties
				storage.Models.Rpoke.Value = pokemon:getShortName()
				if pokemon.data and pokemon.data.gigantamax and Empties then
					for _, empty in pairs(Empties) do
						create 'ImageLabel' {
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://6470280862',
							Size = UDim2.new(1, 0, 1, 0),
							SizeConstraint = Enum.SizeConstraint.RelativeXX,
							Position = UDim2.new(0, 0, 0, 0),
							Parent = empty,
						}
					end
				end
				self.hpfill:setFillbarRatio(pokemon.hp/pokemon.maxhp)
				-- status
				local statuses = _p.Settings['Status_Info']
				local status = pokemon.status
				if status then
					status = status:match('^(%D+)')
				end
				local s = statuses[status]
				local sf = self.statusrf
				if not s then
					sf.Visible = false
				else
					sf.Visible = true
					sf.BackgroundColor3 = s[2]
					write(s[1]) {
						Frame = sf.gui.text,
						Scaled = true,
						Color = s[3],
					}
				end
			end
			function hg:animateHP(fromHp, toHp, maxhp)
				self.animating = true
				self.hpfill:setFillbarRatio(toHp/maxhp, true)
				self.animating = false
				self.lastAnimTime = tick()
			end
			function hg:setHP(hp, maxhp)
				self.hpfill:setFillbarRatio(hp/maxhp)
			end
			function hg:slideOnscreen()

			end
			function hg:slideOffscreen()
				self.main.Visible = false
				self:destroy()
			end
			function hg:destroy()
				self.pokemon = nil
				pcall(function() self.statusrf:Destroy() end)
				pcall(function() self.hpdiv:Destroy() end)
				pcall(function() self.hpfill:Destroy() end)
				self.main:Destroy()

			end
			return hg
		end
		function hg:evalYPos(checkSlot)
			if checkSlot then
				pcall(function()
					slot = hg.pokemon.slot or slot
				end)
			end
			yPos = 0.15
			if slot == 2 then
				yPos = 0.025
			end
		end
		hg:evalYPos()
		local isPhone = Utilities.isPhone()
		local hpg = isPhone and 1 or 2
		hg.main = create("Frame")({
			Name = "FoeHealthGui",
			BackgroundTransparency = 1,
			Size = UDim2.new(-0.45, 0, 0.1, 0),
			Position = UDim2.new(0.975, 0, yPos, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Parent = Utilities.backGui,
			Visible = false,
			create("ImageLabel")({
				Name = "BackgroundImage",
				BackgroundTransparency = 1,
				Image = "rbxassetid://4350251392",
				SizeConstraint = Enum.SizeConstraint.RelativeXY,
				Size = UDim2.new(1.0, 0, 1.2, 0),
				Position = UDim2.new(.02, 0, 0.0, 0)
			}),
			create("Frame")({ 
				Name = "NameContainer",
				BackgroundTransparency = 1,
				Size = UDim2.new(0.0, 0, 0.27, 0),
				Position = UDim2.new(0.05, 0, 0.125, 0),
				ZIndex = 4
			}),
			create("Frame")({
				Name = "GenderContainer",
				BackgroundTransparency = 1,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.6, -13,0.15, 0), 
				ZIndex = 4
			}),
			create("Frame")({
				Name = "LevelContainer",
				BackgroundTransparency = 1,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.6, 0,0.17, 0),
				ZIndex = 4
			}),
			create("Frame")({
				Name = 'HealthContainer', 
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.18, 0),
				Position = UDim2.new(0.2, 0, 0.91, 0),
				ZIndex = 7,
			}),
			create("ImageLabel")({
				Name = "OwnedIcon",
				BackgroundTransparency = 1,
				Image = "rbxassetid://7824188301",
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.7, 3,0.7, 3),
				Position = UDim2.new(0.824, 0,0.215, -3),
				Rotation = 0,
				ZIndex = 4,
				Visible = false
			})
		})

		hg.hpdiv = roundedFrame:new({
			Name = "hpdiv",

			BackgroundColor3 = Color3.new(.7, .7, .7),
			Size = UDim2.new(0.7, 9,0.3, 0),
			Position = UDim2.new(0.1, -12,0.5, 0),
			Style = "HorizontalBar",
			ZIndex = 4,
			Parent = hg.main,

			create 'Frame' {
				Name = 'text',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 1, -hpg*2),
				Position = UDim2.new(0.12, 0, 0.0, hpg), --Position = UDim2.new(0.11, 0,0.5, 0),
				ZIndex = 5,
			},
		})
		write 'HP' {
			Frame = hg.main--[[.gui]].hpdiv.text,
			Color = Color3.fromRGB(48, 48, 48),
			Scaled = true,
		}
		hg.statusrf = roundedFrame:new({
			Name = "status",
			Size = UDim2.new(0.15, 0,0.25, 0),
			Position = UDim2.new(0.6, 0,-0.14, 0),
			Style = "HorizontalBar",
			ZIndex = 4,
			Parent = hg.main,
			create("Frame")({
				Name = "text",
				BackgroundTransparency = 1,
				Size = UDim2.new(0.0, 0, 0.8, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 5
			})
		})
		hg.hpfill = roundedFrame:new({
			Name = "container",
			BackgroundColor3 = Color3.new(.9, .9, .9),
			Size = UDim2.new(0.8, -hpg*2, 1.0, -hpg*2),
			Position = UDim2.new(0.2, hpg, 0.0, hpg),
			Style = "HorizontalBar",
			ZIndex = 5,
			Parent = hg.main.hpdiv
		})
		hg.hpfill:setupFillbar("gyr", hpg)

		function hg:update(pokemon)
			pokemon = pokemon or self.pokemon
			local gui = self.main
			gui.NameContainer:ClearAllChildren()
			gui.GenderContainer:ClearAllChildren()
			gui.LevelContainer:ClearAllChildren()
			gui.HealthContainer:ClearAllChildren()
			gui.status.text:ClearAllChildren()
			gui.BackgroundImage.Image = "rbxassetid://" .. (pokemon.corrupt and 2930551955 or 4350251392)

			pcall(function()
				for _, typing in pairs(gui:GetChildren()) do
					if typing.name == "TypeContainer" then
						typing:Destroy()
					end
				end
			end)

			write(pokemon:getShortName())({
				Frame = gui.NameContainer,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			pname = pokemon:getShortName()
			if pokemon.gender and pokemon.gender ~= "" then
				write("[" .. pokemon.gender:upper() .. "]")({
					Frame = gui.GenderContainer,
					Color = pokemon.gender == "F" and Color3.new(1, 0.44, 0.81) or BrickColor.new("Cyan").Color,
					Scaled = true,
				})
			end
			write(pokemon.level == 100 and "Lv.100" or "Lv. " .. pokemon.level)({
				Frame = gui.LevelContainer,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			self.hpfill:setFillbarRatio(pokemon.hp / pokemon.maxhp)
			write(math.floor((pokemon.hp / pokemon.maxhp) * 100) .. "%")
			{
				Frame = gui.HealthContainer,
				Scaled = true,
			}
			-- status
			local statuses = {
				brn = {'BRN', Color3.new(238/255,  70/255,  44/255)},-- Color3.new(222/255, 23/255, 31/255)},
				frz = {'FRZ', Color3.new(179/255,       1, 240/255)},
				par = {'PAR', Color3.new(240/255, 203/255,  67/255)},
				psn = {'PSN', Color3.new(175/255, 106/255, 206/255)},
				tox = {'PSN', Color3.new(111/255,   9/255,  95/255), Color3.new(188/255, 153/255, 205/255)},
				slp = {'SLP', Color3.new(160/255, 185/255, 175/255)},
			}
			local status = pokemon.status
			if status then
				status = status:match('^(%D+)')
			end
			local s = statuses[status]
			local sf = self.statusrf
			if not s then
				sf.Visible = false
			else
				sf.Visible = true
				sf.BackgroundColor3 = s[2]
				write(s[1]) {
					Frame = sf.gui.text,
					Scaled = true,
					Color = s[3],
				}
			end
			if pokemon.owned then
				gui.OwnedIcon.Visible = pokemon.owned
				gui.OwnedIcon.Image = "rbxassetid://7824188301"
			else
				gui.OwnedIcon.Visible = true
				gui.OwnedIcon.Image = "rbxassetid://6604509011"
			end
			pcall(function()
				local pokeTypes = _p.Pokemon:getTypes(battle.yourSide.active[slot].types or _p.Battle.currentBattle.p2.active[slot].types)
				local zorCheck = battle.yourSide.active[slot].baseSpecies == "Zoroark" or _p.Battle.currentBattle.p2.active.baseSpecies == "Zoroark"
				if zorCheck and not battle.yourSide.active[slot].revealed then 
					pokeTypes = _p.Pokemon:getTypes(Tools.getTemplate(battle.yourSide.active[slot].species).types) 
				end
				for i, t in pairs(pokeTypes) do
					local rf = roundedFrame:new {
						Name = "TypeContainer",
						BackgroundColor3 = typeColors[t],
						Size = UDim2.new(0.2, 0, 0.3, 0),
						Position = UDim2.new(0.6+0.2*(i%2-1), 0, 0.96, 0),
						ZIndex = 8, Style = 'HorizontalBar', Parent = gui,
					}
					write (t) {
						Frame = create 'Frame' {
							Parent = rf.gui, ZIndex = 9, BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.6, 0),
							Position = UDim2.new(0.5, 0, 0.15, 0),
						}, Scaled = true,
					}
				end
			end)
		end
		function hg:animateHP(fromHp, toHp, maxhp, isFastForward)
			local ratio = toHp/maxhp
			local lo = math.min(fromHp, toHp)
			local hi = math.max(fromHp, toHp)
			local tc = hg.main--[[.gui]].HealthContainer
			local t
			if isFastForward then
				self.hpfill:setFillbarRatio(ratio, true, function(a, r)
					local nt = math.max(lo, math.min(hi, math.floor(maxhp*r+.5)))
					if nt ~= t then
						tc:ClearAllChildren()
						local hpVal = (nt / maxhp) * 100
						if hpVal < 100 and hpVal > 0 then
							hpVal = string.format("%.1f", hpVal)
						end
						write(hpVal .. "%") {
							Frame = tc,
							Scaled = true,
						}
						t = nt
					end
				end)
				if t ~= toHp then
					tc:ClearAllChildren()
					local hpVal = (toHp / maxhp) * 100
					if hpVal < 100 and hpVal > 0 then
						hpVal = string.format("%.1f", hpVal)
					end
					write(hpVal .. "%") {
						Frame = tc,
						Scaled = true,
					}
				end
			else
				self.animating = true
				self.hpfill:setFillbarRatio(ratio, true, function(a, r)
					local nt = math.max(lo, math.min(hi, math.floor(maxhp*r+.5)))
					if nt ~= t then
						tc:ClearAllChildren()
						local hpVal = (nt / maxhp) * 100
						if hpVal < 100 and hpVal > 0 then
							hpVal = string.format("%.1f", hpVal)
						end
						write(hpVal .. "%") {
							Frame = tc,
							Scaled = true,
						}
						t = nt
					end
				end)
				if t ~= toHp then
					tc:ClearAllChildren()
					local hpVal = (toHp / maxhp) * 100
					if hpVal < 100 and hpVal > 0 then
						hpVal = string.format("%.1f", hpVal)
					end
					write(hpVal .. "%") {
						Frame = tc,
						Scaled = true,
					}
				end
				self.animating = false
				self.lastAnimTime = tick()
			end
		end
		function hg:setHP(hp, maxhp)
			self.hpfill:setFillbarRatio(hp / maxhp)
		end

		function hg:setOwned(owned)
			self.main.OwnedIcon.Visible = owned
		end
		local isOnscreen = false
		function hg:slideOnscreen()
			if isOnscreen then
				return
			end
			isOnscreen = true
			spawn(function()
				self.main.Visible = true
				Utilities.Tween(0.6, "easeOutCubic", function(a)
					self.main.Position = UDim2.new(0.975 + 0.025 * (1 - a), math.abs(self.main.AbsoluteSize.X) * (1 - a), yPos, 0)
				end)
			end)
		end
		function hg:slideOffscreen(delete)
			if not isOnscreen then
				if delete then
					self:destroy()
				end
				return
			end
			isOnscreen = false
			spawn(function()
				Utilities.Tween(0.6, "easeOutCubic", function(a)
					self.main.Position = UDim2.new(0.975 + 0.025 * a, math.abs(self.main.AbsoluteSize.X) * a, yPos, 0)
				end)
				self.main.Visible = false
				if delete then
					self:destroy()
				end
			end)
		end
		function hg:destroy()
			self.pokemon = nil
			pcall(function()
				self.statusrf:destroy()
			end)
			pcall(function()
				self.hpfill:destroy()
			end)
			pcall(function()
				self.hpdiv:destroy()
			end)

			self.main:Destroy()
		end
		return hg
	end

	function BattleGui:createUserHealthGui(nActive, slot, poke)
		local ys = 1.4
		local yPos = 0.3
		local hg = {}
		function hg:evalYPos(checkSlot)
			if checkSlot then
				pcall(function() slot = hg.pokemon.slot or slot end)
			end
			yPos = 0.3
			if nActive == 2 then
				if slot == 1 then
					yPos = 1-0.45/6-.0625-.2*ys
				elseif slot == 2 then
					yPos = 1-0.45/6-.0325-.1*ys
				end
			end
		end
		hg:evalYPos()
		local isPhone = Utilities.isPhone()
		local hpg = isPhone and 1 or 2
		local id
		--if not (poke.shiny or self.pokemon.shiny) then
		--	id = 15879437665
		--else
		--	id = 15881950031
		--end
		hg.main = create 'Frame' {--'ImageLabel' {--roundedFrame:new {
			BackgroundTransparency = 1.0,
			--		Image = 'rbxassetid://631488309',

			Name = 'UserHealthGui',
			--		CornerRadius = Utilities.gui.AbsoluteSize.Y*0.04,
			--		BackgroundColor3 = Color3.new(.3, .3, .3),
			Size = UDim2.new(0.45, 0, 0.1*ys, 0),
			Position = UDim2.new(0.015, 0, 0.3, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Parent = Utilities.backGui,
			Visible = false,
			create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://13366506977',--631543660',--4350249589
				ImageColor3 = Color3.new(255, 255, 255),
				SizeConstraint = Enum.SizeConstraint.RelativeXY,
				Size = UDim2.new(1.019, 0, 0.871, 0),
				Position = UDim2.new(0.0, 0, 0.0, 0),
			},
			create 'Frame' {
				Name = 'NameContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.27/ys, 0),
				Position = UDim2.new(0.25, 0, 0.11/ys, 0),
				--			Position = UDim2.new(0.2, 0, -0.135/ys, 0),
				ZIndex = 5,
			},
			create 'Frame' {
				Name = 'NameShadowContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.27/ys, 0),
				Position = UDim2.new(0.24, 0, 0.135/ys, 0),
				ZIndex = 4,
			},
			create 'Frame' {
				Name = 'GenderContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25/ys, 0),
				Position = UDim2.new(0.7, 0, 0.15/ys, 0), 
				--			Position = UDim2.new(0.7, 0, 0.25/ys, 0),
				ZIndex = 4,
			},
			create 'Frame' {
				Name = 'LevelContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2/ys, 0),
				Position = UDim2.new(0.75, 0, 0.17/ys, 0),
				--			Position = UDim2.new(0.75, 0, 0.25/ys, 0),
				ZIndex = 4,
			},
			create 'Frame' {
				Name = 'HealthContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.20/ys, 0),
				Position = UDim2.new(0.65, 0, 0.896/ys, 0),
				ZIndex = 4,
			},
			create("ImageLabel")({
				Name = "Icon",
				BackgroundTransparency = 1.0,
				Image = "rbxassetid://7824188301",
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.53, 0, 0.53, 0),
				Position = UDim2.new(0.0375, 0, 0.125, 0),
				Rotation = 0,
				ZIndex = 5,
				Visible = true
			})
		}
		hg.hpdiv = roundedFrame:new {
			Name = 'hpdiv',
			BackgroundColor3 = Color3.new(.7, .7, .7),
			Size = UDim2.new(0.75, 0, 0.3/ys, 0),
			Position = UDim2.new(0.235, 0, 0.5/ys, 0),
			Style = 'HorizontalBar',
			ZIndex = 4,
			Parent = hg.main,--.gui,

			create 'Frame' {
				Name = 'text',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 1, -hpg*2), 
				Position = UDim2.new(0.12, 0, 0.0, hpg), --Position = UDim2.new(0.11, 0,0.5, 0),
				ZIndex = 5,
			},
		}
		hg.statusrf = roundedFrame:new {
			Name = 'status',
			Size = UDim2.new(0.15, 0, 0.25/ys, 0),
			Position = UDim2.new(0.75, 0, -0.09, 0),
			--Position = UDim2.new(0.025, 0, 0.625/ys, 0),
			Style = 'HorizontalBar',
			ZIndex = 4,
			Parent = hg.main,--.gui,

			create 'Frame' {
				Name = 'text',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.8, 0),--1.0, -hpg*2),
				Position = UDim2.new(0.5, 0, 0.1, 0),--0.0, hpg),
				ZIndex = 5,
			},
		}
		hg.hpfill = roundedFrame:new {
			Name = 'container',
			BackgroundColor3 = Color3.new(.9, .9, .9),
			Size = UDim2.new(0.8, -hpg*2, 1.0, -hpg*2),
			Position = UDim2.new(0.2, hpg, 0.0, hpg),
			Style = 'HorizontalBar',
			ZIndex = 5,
			Parent = hg.main--[[.gui]].hpdiv,
		}
		hg.hpfill:setupFillbar('gyr', hpg)
		hg.xpfill = roundedFrame:new {
			Name = 'xpdiv',
			BackgroundColor3 = Color3.new(.1, .1, .1),
			Size = UDim2.new(0.8, 0, 0.1),
			Position = UDim2.new(0.1, 0, 0.95, 0),
			Style = 'HorizontalBar',
			ZIndex = 4,
			Parent = hg.main--.gui,
		}
		hg.xpfill:setupFillbar(Color3.new(.4, .8, 1), hpg, 0)
		write 'HP' {
			Frame = hg.main--[[.gui]].hpdiv.text,
			Color = Color3.fromRGB(48, 48, 48),
			Scaled = true,
		}
		--	local resizeCn = Utilities.gui.Changed:connect(function(prop)
		--		if prop ~= 'AbsoluteSize' then return end
		--		hg.main.CornerRadius = Utilities.gui.AbsoluteSize.Y*0.04
		--	end)
		function hg:update(pokemon, ignoreXP)
			pokemon = pokemon or self.pokemon
			local gui = self.main--.gui
			gui.NameContainer:ClearAllChildren()
			gui.NameShadowContainer:ClearAllChildren()
			gui.GenderContainer:ClearAllChildren()
			gui.LevelContainer:ClearAllChildren()
			gui.HealthContainer:ClearAllChildren()
			-- name
			--[[		local nameText = ]]write(pokemon:getShortName()) {
				Frame = gui.NameContainer,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				--			Color = Color3.new(.3, .3, .3),
			}--.Frame
			--		roundedFrame:new {
			--			name = 'barthing',
			--			BackgroundColor3 = Color3.fromRGB(211, 203, 70),-- new(.7, .7, .7),
			--			Size = UDim2.new(1.15, 0, 1.3, 0),
			--			Position = UDim2.new(-.075, 0, -.15, 0),
			--			Style = 'HorizontalBar',
			--			ZIndex = 4, Parent = nameText
			--		}
			--		write(pokemon:getShortName()) {
			--			Frame = gui.NameShadowContainer,
			--			Scaled = true,
			--			TextXAlignment = Enum.TextXAlignment.Left,
			--			Color = Color3.new(0, 0, 0),
			--			Transparency = .6
			--		}
			-- gender
			local show = (pokemon.data and pokemon.data.num ~= 29 and pokemon.data.num ~= 32) or (pokemon.species and pokemon.species ~= 'nidoranf' and pokemon.species ~= 'nidoranm')
			if show and pokemon.gender and pokemon.gender ~= '' then
				write('['..pokemon.gender:upper()..']') {
					Frame = gui.GenderContainer,
					Color = pokemon.gender=='F' and Color3.new(1, .44, .81) or BrickColor.new('Cyan').Color,
					Scaled = true,
				}
			end
			-- level
			write(pokemon.level == 100 and 'Lv.100' or 'Lv. '..pokemon.level) {
				Frame = gui.LevelContainer,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}
			-- hp
			self.hpfill:setFillbarRatio(pokemon.hp/pokemon.maxhp)
			write(pokemon.hp .. '/' .. pokemon.maxhp .. " (" .. math.floor((pokemon.hp / pokemon.maxhp) * 100) .. "%)")
			{
				Frame = gui.HealthContainer,
				Scaled = true,
			}
			-- exp
			if not ignoreXP then
				pcall(function()
					if not pokemon.expProg then
						gui.xpdiv.Visible = false
					else
						gui.xpdiv.Visible = true
						self.xpfill:setFillbarRatio(pokemon.expProg)
					end
				end)
			end
			-- status
			local statuses = {
				brn = {'BRN', Color3.new(238/255,  70/255,  44/255)},
				frz = {'FRZ', Color3.new(179/255,       1, 240/255)},
				par = {'PAR', Color3.new(240/255, 203/255,  67/255)},
				psn = {'PSN', Color3.new(175/255, 106/255, 206/255)},
				tox = {'PSN', Color3.new(111/255,   9/255,  95/255), Color3.new(188/255, 153/255, 205/255)},
				slp = {'SLP', Color3.new(160/255, 185/255, 175/255)},
			}
			local status = pokemon.status
			if status then
				status = status:match('^(%D+)')
			end
			local s = statuses[status]
			local sf = self.statusrf
			if not s then
				sf.Visible = false
			else
				sf.Visible = true
				sf.BackgroundColor3 = s[2]
				write(s[1]) {
					Frame = sf.gui.text,
					Scaled = true,
					Color = s[3],
				}
			end
		end
		function hg:animateHP(fromHp, toHp, maxhp)
			local ratio = toHp/maxhp
			local lo = math.min(fromHp, toHp)
			local hi = math.max(fromHp, toHp)
			local tc = hg.main--[[.gui]].HealthContainer
			local t
			self.animating = true
			self.hpfill:setFillbarRatio(ratio, true, function(a, r)
				local nt = math.max(lo, math.min(hi, math.floor(maxhp*r+.5)))
				if nt ~= t then
					tc:ClearAllChildren()
					write(nt..'/'..maxhp .. " (" .. math.floor((nt / maxhp) * 100) .. "%)") {
						Frame = tc,
						Scaled = true,
					}
					t = nt
				end
			end)
			if t ~= toHp then
				tc:ClearAllChildren()
				write(toHp .. '/' .. maxhp .. " (" .. math.floor((toHp / maxhp) * 100) .. "%)") {
					Frame = tc,
					Scaled = true,
				}
			end
			self.animating = false
			self.lastAnimTime = tick()
		end
		function hg:setHP(hp, maxhp)
			self.hpfill:setFillbarRatio(hp/maxhp)
			local tc = hg.main--[[.gui]].HealthContainer
			tc:ClearAllChildren()
			write(hp .. '/' .. maxhp .. " (" .. math.floor((hp / maxhp) * 100) .. "%)") {
				Frame = tc,
				Scaled = true,
			}
		end
		function hg:animateXP(ratio)
			self.xpfill:setFillbarRatio(ratio, true)
		end
		function hg:slideOnscreen()
			spawn(function()
				self.main.Visible = true
				Utilities.Tween(.6, 'easeOutCubic', function(a)
					self.main.Position = UDim2.new(0.015*a, -self.main.AbsoluteSize.X*(1-a), yPos, 0)
				end)
			end)
		end
		function hg:slideOffscreen(delete)
			spawn(function()
				Utilities.Tween(.6, 'easeOutCubic', function(a)
					self.main.Position = UDim2.new(0.015*(1-a), -self.main.AbsoluteSize.X*a, yPos, 0)
				end)
				self.main.Visible = false
				if delete then
					self:destroy()
				end
			end)
		end
		function hg:destroy()
			self.pokemon = nil
			--		resizeCn:disconnect()
			pcall(function() self.statusrf:Destroy() end)
			pcall(function() self.hpdiv:Destroy() end)
			pcall(function() self.hpfill:Destroy() end)
			pcall(function() self.xpfill:Destroy() end)
			self.main:Destroy()
		end
		return hg
	end


	function BattleGui:promptReplaceMove(movesData, alreadyFaded)
		local newMove
		if #movesData > 4 then
			newMove = table.remove(movesData) -- last
		end

		local fader = create 'Frame' {--Utilities.fadeGui
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 60),
			Position = UDim2.new(0.0, 0, 0.0, -60),
			Parent = Utilities.frontGui,
		}
		if not alreadyFaded then
			fader.BackgroundColor3 = Color3.new(0, 0, 0)
			fader.ZIndex = 6
		end
		local gui = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Parent = Utilities.frontGui,
		}
		write 'Which move should be forgotten?' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.06, 0),
				Position = UDim2.new(0.5, 0, 0.03, 0),
				Parent = gui,
				ZIndex = 7,
			},
			Scaled = true,
		}
		local rframes = {}
		local sig = Utilities.Signal()
		local function guiForMove(move, onClick)
			local color = typeColors[move.type]
			local panel = roundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(color.r*.35, color.g*.35, color.b*.35),
				CornerRadius = Utilities.gui.AbsoluteSize.Y*.03,
				Size = UDim2.new(0.425, 0, 0.25, 0),
				ZIndex = 8, Parent = gui,
				MouseButton1Click = onClick,

				create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://'..({Status=76284007769271,Special=85857751552351,Physical=70768504045906})[move.category],
					Size = UDim2.new(0.175/16*39, 0, 0.175, 0),--39x16
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Position = UDim2.new(0.545, 0, 0.07, 0),
					ZIndex = 9,
				}
			}
			table.insert(rframes, panel)
			write(move.name) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.2),
					Position = UDim2.new(0.05, 0, 0.05, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			write(move.type) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.15),
					Position = UDim2.new(0.95, 0, 0.075, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right, Color = color,
			}
			write('Power: '..move.power) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.15),
					Position = UDim2.new(0.1, 0, 0.3, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left, Color = Color3.new(.9, .9, .9),
			}
			write('Acc: '..(move.accuracy == true and '--' or move.accuracy)) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.15),
					Position = UDim2.new(0.6, 0, 0.3, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Center, Color = Color3.new(.9, .9, .9),
			}
			write('PP: '..move.pp) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.15),
					Position = UDim2.new(0.95, 0, 0.3, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right, Color = Color3.new(.9, .9, .9),
			}
			local descFrame = create 'Frame' {
				Size = UDim2.new(0.9, 0, 0.45),
				Position = UDim2.new(0.05, 0, 0.5, 0),
				BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
			}
			if move.desc and move.desc ~= '' then
				local ht = descFrame.AbsoluteSize.Y/4.5
				local obj = write(move.desc) {
					Frame = descFrame,
					Size = ht,
					Wraps = true,
				}
				if obj and obj.MaxBounds then
					local r = obj.MaxBounds.y/ht
					if r < 2 then
						descFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
					elseif r < 3 then
						descFrame.Position = UDim2.new(0.05, 0, 0.6, 0)
					end
				end
			end
			return panel
		end
		local saying = false
		for i, move in pairs(movesData) do
			local panel = guiForMove(move, function()
				if saying then return end
				if newMove and hmMoveIds[move.id] then
					saying = true
					_p.NPCChat:say('HM moves can\'t be forgotten now.')
					wait() wait()
					saying = false
					return
				end
				sig:fire(i)
			end)
			panel.Position = UDim2.new(0.525-(i%2)*0.475, 0, 0.15+math.floor((i-1)/2)*0.28, 0)
		end
		if newMove then
			local np = guiForMove(newMove, function() sig:fire(nil) end)
			np.Position = UDim2.new(0.5-0.425/2, 0, 0.15+0.28*2, 0)
		else
			local cancel = roundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.35, .35, .35),
				CornerRadius = Utilities.gui.AbsoluteSize.Y*.03,
				Size = UDim2.new(0.425, 0, 0.25, 0),
				Position = UDim2.new(0.5-0.425/2, 0, 0.15+0.28*2, 0),
				ZIndex = 8, Parent = gui,
				MouseButton1Click = function() sig:fire(nil) end,
			}
			table.insert(rframes, cancel)
			write 'Cancel' {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.3),
					Position = UDim2.new(0.5, 0, 0.35, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = cancel.gui,
				}, Scaled = true,
			}
		end
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			if not alreadyFaded then fader.BackgroundTransparency = 1 - a*.6 end
			gui.Position = UDim2.new(1-a, 0, 0.0, 0)
		end)
		local res = sig:wait()
		spawn(function()
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				if not alreadyFaded then fader.BackgroundTransparency = 1 - (1-a)*.6 end
				gui.Position = UDim2.new(a, 0, 0.0, 0)
			end)
			for _, rf in pairs(rframes) do
				rf:Destroy()
			end
			gui:Destroy()
		end)
		wait(.35)
		return res
	end

	function BattleGui:animateEvolution(name1, name2, sd1, sd2, alreadyFaded, cannotBeCanceled)
		spawn(function() Menu:disable() end)

		local stepped = game:GetService('RunService').RenderStepped
		local animating = true
		local canceled = false

		local topGui = Utilities.frontGui--create 'ScreenGui' { Parent = Utilities.gui.Parent }
		local fader = create 'Frame' {
			BackgroundTransparency = 1.0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1.0, 0, 1.0, 60),
			Position = UDim2.new(0.0, 0, 0.0, -60),
			Parent = topGui,
		}

		local function fadeOut(d)
			fader.ZIndex = 10
			local s = fader.BackgroundTransparency
			local e = 0.0
			Utilities.Tween(d, nil, function(a)
				fader.BackgroundTransparency = s + (e-s)*a
			end)
		end

		local function fadeIn(d)
			local s = fader.BackgroundTransparency
			local e = 1.0
			Utilities.Tween(d, nil, function(a)
				fader.BackgroundTransparency = s + (e-s)*a
			end)
		end

		if not alreadyFaded then
			spawn(function() _p.MusicManager:prepareToStack(.5) end)
			fadeOut(.5)
		end
		fader.ZIndex = 1

		-- todo -> convert to Pokemon::getSprite()
		--	local sd1 = _p.DataManager:getSprite((shiny and '_SHINY' or '')..'_FRONT', p1, p.gender=='F')
		--	local sd2 = _p.DataManager:getSprite((shiny and '_SHINY' or '')..'_FRONT', p2, p.gender=='F')
		if not sd1 then
			sd1 = _p.DataManager:getSprite('_FRONT', name1)
		end
		local anim1 = _p.AnimatedSprite:new(sd1)
		local sprite1 = anim1.spriteLabel
		local anim2 = _p.AnimatedSprite:new(sd2)
		local sprite2 = anim2.spriteLabel

		local container1 = Utilities.Create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Parent = topGui,
		}
		do
			sprite1.Parent = container1
			sprite1.ZIndex = 5
			local scale = sd1.scale or 1
			local x = sd1.fWidth/110*scale
			local y = sd1.fHeight/110*scale
			sprite1.Size = UDim2.new(x, 0, y, 0)
			sprite1.Position = UDim2.new(0.5-x/2, 0, 0.5-y/2, 0)
		end
		local container2 = Utilities.Create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Visible = false,
			Parent = topGui,
		}
		do
			sprite2.Parent = container2
			sprite2.ZIndex = 5
			local scale = sd2.scale or 1
			local x = sd2.fWidth/110*scale
			local y = sd2.fHeight/110*scale
			sprite2.Size = UDim2.new(x, 0, y, 0)
			sprite2.Position = UDim2.new(0.5-x/2, 0, 0.5-y/2, 0)
		end
		container1.Size = UDim2.new(0.6, 0, 0.6, 0)
		container1.Position = UDim2.new(0.5, -container1.AbsoluteSize.X/2, 0.2, 0)
		anim1:Play()

		Utilities.sound(_p.musicId.Evo1, nil, nil, 5)
		local sound
		delay(1, function()
			if canceled then return end
			sound = Utilities.loopSound(_p.musicId.Evo2)
		end)
		_p.NPCChat:say('What? ' .. name1 .. ' is evolving!')

		local cancel
		if not cannotBeCanceled then
			cancel = roundedFrame:new {
				Button = true, Name = 'CancelButton',
				CornerRadius = Utilities.gui.AbsoluteSize.Y*.01,
				BackgroundColor3 = Color3.new(.3, .3, .3),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(1/5, 0, 1/16, 0),
				Position = UDim2.new(0.7, 0, 29/32, 0),
				ZIndex = 5,
				MouseButton1Click = function()
					pcall(function()
						sound:Stop()
						sound:Destroy()
					end)
					canceled = true
					cancel:Destroy()
				end,
			}
		end

		spawn(function()
			local t = 3
			local n = 10
			local s = tick()
			local timer = Utilities.Timing.easeInCubic(t)
			for i = 1, n do
				local c = (i%5+3)/7
				local image = Utilities.Create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://289114252',--576575353
					ImageColor3 = Color3.new(.4*c, .8*c, c),
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					ZIndex = 3,
				}
				spawn(function()
					local last = 0
					while animating and not canceled do
						local et = (tick()-s-i*t/n)%t
						if et < last then
							image.Parent = nil; image.Parent = topGui
						end
						last = et
						local a = timer(et)
						image.Size = UDim2.new(a*2.5, 0, a*2.5, 0)
						image.Position = UDim2.new(0.5-a*2.5/2, 0, 0.5, -image.AbsoluteSize.Y/2)
						stepped:wait()
					end
					image:Destroy()
				end)
				wait(t/n)
			end
		end)

		wait(2)
		Utilities.Tween(1, nil, function(a)
			local o = 1-a
			sprite1.ImageColor3 = Color3.new(o, o, o)
		end)
		wait(.5)
		if cancel then
			cancel.Parent = topGui
			write 'Cancel' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 6, Parent = cancel.gui,
				}, Scaled = true,
			}
		end
		sprite2.ImageColor3 = Color3.new(0, 0, 0)
		anim2:Play()
		local s = tick()
		local last = 0
		while not canceled do
			local et = tick()-s
			local p = math.cos(et*math.pi*(0.5+et/3.5))
			if et >= 8 and p < 0 and last < p then break end
			last = p
			if p > 0 then
				container1.Visible = true
				container1.Size = UDim2.new(p*.6, 0, p*.6, 0)
				container1.Position = UDim2.new(0.5, -container1.AbsoluteSize.X/2, 0.5-p*.3, 0)
				container2.Visible = false
			else
				p = -p
				container1.Visible = false
				container2.Visible = true
				container2.Size = UDim2.new(p*.6, 0, p*.6, 0)
				container2.Position = UDim2.new(0.5, -container2.AbsoluteSize.X/2, 0.5-p*.3, 0)
			end
			stepped:wait()
		end
		if canceled then
			local bg = create 'Frame' {
				BackgroundColor3 = Color3.new(.4, .8, 1),
				Size = UDim2.new(1.0, 0, 1.0, 60),
				Position = UDim2.new(0.0, 0, 0.0, -60),
				ZIndex = 2,
				Parent = topGui
			}
			container1.Visible = true
			sprite1.ImageColor3 = Color3.new(1, 1, 1)
			container1.Size = UDim2.new(.6, 0, .6, 0)
			container1.Position = UDim2.new(0.5, -container1.AbsoluteSize.X/2, 0.2, 0)
			container2:Destroy()
			_p.NPCChat:say('Huh? ' .. name1 .. ' stopped evolving!')
			fadeOut(1)
			bg:Destroy()
			container1:Destroy()
			--		topGui:Destroy()
			if not alreadyFaded then
				spawn(function() _p.MusicManager:returnFromSilence(.5) end)
				fadeIn(.5)
				if not Menu.bag.open then
					spawn(function() Menu:enable() end)
				end
			end
			fader:Destroy()
			return false
		end
		pcall(function() cancel:Destroy() end)
		container1.Visible = false
		container2.Visible = true
		container2.Size = UDim2.new(.6, 0, .6, 0)
		container2.Position = UDim2.new(0.5, -container2.AbsoluteSize.X/2, 0.2, 0)
		local image = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://289114252',--
			ImageColor3 = Color3.new(.4, .8, 1), --.4, .8, 1
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			ZIndex = 4,
			Parent = topGui,
		}
		Utilities.Tween(.75, 'easeInCubic', function(a)
			image.Size = UDim2.new(a*2, 0, a*2, 0)
			image.Position = UDim2.new(0.5-a*2/2, 0, 0.5, -image.AbsoluteSize.Y/2)
			sprite2.ImageColor3 = Color3.new(a, a, a)
		end)
		animating = false
		pcall(function()
			sound:Stop()
			sound:Destroy()
		end)
		Utilities.sound(_p.musicId.Evo3, nil, .5, 10)
		_p.NPCChat:say('Congratulations! Your ' .. name1 .. ' evolved into ' .. name2 .. '!')
		wait(2)

		return true, function()
			fader.BackgroundTransparency = 1.0
			fadeOut(.5)
			container1:Destroy()
			container2:Destroy()
			image:Destroy()
			--		topGui:Destroy()
			if not alreadyFaded then
				spawn(function() _p.MusicManager:returnFromSilence(.5) end)
				fadeIn(.5)
				if not Menu.bag.open then
					spawn(function() Menu:enable() end)
				end
			end
			fader:Destroy()
		end
	end


	return BattleGui end
