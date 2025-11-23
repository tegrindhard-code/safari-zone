return function(_p)
	local players = game:GetService('Players')
	local player = players.LocalPlayer

	local Utilities = _p.Utilities

	-- todo: pokerus
	local Pokemon = {
		balls = { -- OVH  these are still necessary for BattleSprite:animSummon
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
			'timerball',--'meadowball',
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
			'pumpkinball',-- 31 (1 more allowed, would have to be [0])
		}

	}




	function Pokemon:filterNickname(nickname) -- this is the quick filter; full Roblox filter implemented once they hit submit
		nickname = nickname:gsub('|', '')	
		do
			local bytes = {string.byte(nickname, 1, #nickname)}
			for i = #bytes, 1, -1 do
				local b = bytes[i]
				if b < 32 or b > 126 then
					table.remove(bytes, i)
				end
			end
			nickname = string.char(unpack(bytes))
		end
		if nickname:len() > 12 then
			nickname = nickname:sub(1, 12)
		end
		return nickname
	end
	function Pokemon:getIcon(icon, shiny)
		local icontopoke = { -- custom icons
			[1145] = 'rbxassetid://11226762910', --xmas sceptile
			[1146] = 'rbxassetid://15491372937', --santa lax
			[1147] = 'rbxassetid://13917084621', -- walking wake
			[1148] = 'rbxassetid://17143724476', --gouging fire
			[1149] = 'rbxassetid://17143776298', --raging bolt
			[1150] = 'rbxassetid://13912703630', --ceruledge
			[1154] = 'rbxassetid://18183505456', --zoroark
			[1155] = 'rbxassetid://18183515005', --typhlo
			[1156] = 'rbxassetid://18183522802', --samurott
			[1157] = 'rbxassetid://18183528011', --decidueye
			[2008] = 'rbxassetid://16765240130', --MegaArceus
			[1158] = 'rbxassetid://18102766560', --Iron Crown
			[1159] = 'rbxassetid://18114423902', --Archaludon
			[1160] = 'rbxassetid://18125547671', --Hydrapple
			[1161] = 'rbxassetid://18144094706', --Dialga Origin
			[1162] = 'rbxassetid://18144107433', --Palkia Origin
			[1163] = 'rbxassetid://18185259253', --Sneasel Hisui
			[1164] = 'rbxassetid://18185260706', --Sneasler
			[1165] = 'rbxassetid://18183395721', --BasculegionF
			[1166] = 'rbxassetid://18183398938', --BasculegionM
			[1167] = 'rbxassetid://18183410332', --Growlithe Hisui
			[1168] = 'rbxassetid://18183414369', --Arcanine Hisui
			[1169] = 'rbxassetid://18183418721', --Avalugg Hisui
			[1170] = 'rbxassetid://18183432460', --Braviary Hisui
			[1171] = 'rbxassetid://18183423183', --Voltorb Hisui
			[1172] = 'rbxassetid://18183437075', --Electrode Hisui
			[1173] = 'rbxassetid://18183443475', --Sliggoo Hisui
			[1174] = 'rbxassetid://18183448909', --Goodra Hisui
			[1175] = 'rbxassetid://18183454246', --Lilligant Hisui
			[1176] = 'rbxassetid://18183459133', --Qwilfish Hisui
			[1177] = 'rbxassetid://18183465039', --Overqwil
			[1178] = 'rbxassetid://18183471426', --Kleavor
			[1179] = 'rbxassetid://18183475228', --Ursaluna
			[1180] = 'rbxassetid://18183481328', --Wyrdeer
			[1181] = 'rbxassetid://18183404862', --Basculin White Stripe
			[1182] = 'rbxassetid://18203041726', --Shadow Lugia
			[1183] = 'rbxassetid://13912703752', --armarouge
			[1184] = 'rbxassetid://13912712303', --charcadet
			[1185] = 'rbxassetid://18183497722', --zorua
		}
		local icontopokeshiny = {
			[1147] = 'rbxassetid://17156352347', --walking wake
			[1150] = 'rbxassetid://17152657050', --ceruledge
			[1154] = 'rbxassetid://18183506539', --zoroark
			[1155] = 'rbxassetid://18183516621', --typhlo
			[1156] = 'rbxassetid://18183523761', --samurott
			[1157] = 'rbxassetid://18183529046', --decidueye
			[1158] = 'rbxassetid://18102800054', --Iron Crown
			[1159] = 'rbxassetid://18114424487', --Archaludon
			[1160] = 'rbxassetid://18125548598', --Hydrapple
			[1161] = 'rbxassetid://18144105599', --Dialga Origin
			[1162] = 'rbxassetid://18144108651', --Palkia Origin
			[1163] = 'rbxassetid://18185260041', --Sneasel Hisui
			[1164] = 'rbxassetid://18185261357', --Sneasler
			[1165] = 'rbxassetid://18183396471', --BasculegionF
			[1166] = 'rbxassetid://18183399606', --BasculegionM
			[1167] = 'rbxassetid://18183411623', --Growlithe Hisui
			[1168] = 'rbxassetid://18183415344', --Arcanine Hisui
			[1169] = 'rbxassetid://18183419605', --Avalugg Hisui
			[1170] = 'rbxassetid://18183433229', --Braviary Hisui
			[1171] = 'rbxassetid://18183424140', --Voltorb Hisui
			[1172] = 'rbxassetid://18183438281', --Electrode Hisui
			[1173] = 'rbxassetid://18183445521', --Sliggoo Hisui
			[1174] = 'rbxassetid://18183450422', --Goodra Hisui
			[1175] = 'rbxassetid://18183455337', --Lilligant Hisui
			[1176] = 'rbxassetid://18183459980', --Qwilfish Hisui
			[1177] = 'rbxassetid://18183466923', --Overqwil
			[1178] = 'rbxassetid://18183472427', --Kleavor
			[1179] = 'rbxassetid://18183476326', --Ursaluna
			[1180] = 'rbxassetid://18183482029', --Wyrdeer
			[1181] = 'rbxassetid://18183404862', --Basculin White Stripe
			[1183] = 'rbxassetid://17152648882', --armarouge
			[1184] = 'rbxassetid://17152643126', --charcadet
			[1185] = 'rbxassetid://18183498898', --zorua
		}
		local options = _p.Menu.options
		local sfx = options.IconSFX
		if icontopoke[icon + 1] then
			local gui
			if shiny then
				gui = Utilities.Create 'ImageLabel' {
					Name = 'PokemonIcon',
					BackgroundTransparency = 1.0,
					Image = icontopokeshiny[icon + 1],
					Size = UDim2.new(0.85, 0, 1, 0),
					ResampleMode = Enum.ResamplerMode.Pixelated,
					ZIndex = 5
				}
			else
				gui = Utilities.Create 'ImageLabel' {
					Name = 'PokemonIcon',
					BackgroundTransparency = 1.0,
					Image = icontopoke[icon + 1],
					Size = UDim2.new(0.85, 0, 1, 0),
					ResampleMode = Enum.ResamplerMode.Pixelated,
					ZIndex = 5
				}	
			end	
			spawn(function() 
				if shiny and sfx then
					self:animateSFX(gui, 'Sparkle')
				end
			end)
			return gui, icon
		end



		local gui
		if icon > 1450 then -- egg threshold
			-- Egg
			local i
			if icon > 1872 then
				i = icon-1442
			else
				i = icon-1451 -- also egg threshold dependent
			end
			local s = .7
			gui = Utilities.Create 'Frame' {
				Name = 'PokemonIcon',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 1.0, 0),

				Utilities.Create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://13039987315',
					ImageRectSize = Vector2.new(30, 32),
					ImageRectOffset = Vector2.new(30*(i%18), 32*math.floor(i/18)),
					Size = UDim2.new(3/4/32*30*s, 0, s, 0),
					ResampleMode = Enum.ResamplerMode.Pixelated,
					Position = UDim2.new(.5-3/4/32*30*s/2, 0, 0.5-s/2, 0),
					ZIndex = 5,
				}
			}
		else
			local col = icon%21
			local row = math.floor(icon/21)
			local image = 1
			if col>10 then image=image+1 col=col-11 end
			if row>24 then image=image+2 row=row-25 end
			if row>32 then image=image+2 row=row-33 end
			gui = Utilities.Create 'ImageLabel' {
				Name = 'PokemonIcon',
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://'..({75793676247212,81454939375923,99771081794487,116756659359673,119849842436214,128152271065089})[image],
				ImageRectSize = Vector2.new(40, 30),
				ImageRectOffset = Vector2.new(80*col+(shiny and 40 or 0), 30*row),
				ResampleMode = Enum.ResamplerMode.Pixelated,
				Size = UDim2.new(1.0, 0, 1.0, 0),
				ZIndex = 5
			}
		end
		spawn(function() 
			if shiny and sfx then
				self:animateSFX(gui, 'Sparkle')
			end
		end)
		return gui, icon
	end
	function Pokemon:animateSFX(gui, variant)
		while gui do
			if variant == 'Sparkle' then
				local s = .1+.15*math.random()
				local r = 90*math.random()
				local rv = math.random(-50, 50)
				local px, py = math.random(), math.random()
				local sparkle = Utilities.Create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://7112395588',
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					ZIndex = 10,--3 
				}
				spawn(function()
					local st = tick()
					sparkle.Parent = gui
					Utilities.Tween(.4+.6*math.random(), nil, function(a)
						local size = s*math.sin(a*math.pi)
						sparkle.Size = UDim2.new(size, 0, size, 0)
						sparkle.Position = UDim2.new(px-size/2, 0, py, -sparkle.AbsoluteSize.Y/2)
						sparkle.Rotation = r + rv*(tick()-st)
					end)
					delay(1, function() sparkle:Remove() end)
				end)
				wait(.1)
			end
		end
	end
	function Pokemon:giveNickname(icon, isShiny)
		local bg = Utilities.Create("ImageButton")({
			AutoButtonColor = false,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 0.5,
			Size = UDim2.new(1, 0, 1, 36),
			Position = UDim2.new(0, 0, 0, -36),
			ZIndex = 21,
			Parent = Utilities.frontGui
		})
		local prompt = _p.RoundedFrame:new({
			CornerRadius = 0.026,
			BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
			Size = UDim2.new(0.6, 0, 0.2, 0),
			Position = UDim2.new(0.2, 0, 0.28, 0),
			ZIndex = 22,
			Parent = Utilities.frontGui
		})
		local icon = self:getIcon(icon, isShiny)
		icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
		icon.Size = UDim2.new(1.3333333333333333, 0, 1, 0)
		icon.ZIndex = 23
		icon.Parent = prompt.gui
		local entryRF = _p.RoundedFrame:new({
			CornerRadius = 0.022,
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(0.7325, 0, 0.8, 0),
			Position = UDim2.new(0.25, 0, 0.1, 0),
			ZIndex = 23,
			Parent = prompt.gui
		})
		local entryBox = Utilities.Create("TextBox")({
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(0.3, 0.3, 0.3),
			TextScaled = true,
			Font = Enum.Font.GothamBold,
			Text = "",
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Size = UDim2.new(0.97, 0, 0.8, 0),
			Position = UDim2.new(0.015, 0, 0.1, 0),
			ZIndex = 24,
			Parent = entryRF.gui
		})
		local fauxEntryBox = Utilities.Create("TextLabel")({
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(0.3, 0.3, 0.3),
			TextScaled = true,
			Font = Enum.Font.GothamBold,
			Text = "",
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0.97, 0, 0.8, 0),
			Position = UDim2.new(0.015, 0, 0.1, 0),
			ZIndex = 24,
			Parent = entryRF.gui
		})
		entryBox.Changed:Connect(function()
			entryBox.Text = self:filterNickname(entryBox.Text)
		end)
		local name
		while true do
			entryBox.Visible = true
			fauxEntryBox.Visible = false
			entryBox:CaptureFocus()
			entryBox.FocusLost:wait()
			entryBox.Visible = false
			fauxEntryBox.Visible = true
			name = self:filterNickname(Utilities.trim(entryBox.Text))
			fauxEntryBox.Text = name
			if name:len() == 0 then
				name = nil
			end
			bg.ZIndex = 25
			if name then
				name = _p.Network:get("PDS", "approveNickname", name)
				fauxEntryBox.Text = name
				if _p.NPCChat:say("[y/n]Is \"" .. name .. "\" OK?") then
					break
				end
			elseif _p.NPCChat:say("[y/n]Is no nickname OK?") then
				break
			end
			bg.ZIndex = 21
			entryBox.Text = name or ""
		end
		entryRF:destroy()
		prompt:destroy()
		bg:Destroy()
		return name
	end


	function Pokemon:hatch(data)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()

		local menuWasEnabled = _p.Menu.enabled
		spawn(function() _p.Menu:disable() end)
		_p.NPCChat:say('Oh?')
		spawn(function() _p.MusicManager:prepareToStack(.5) end)
		Utilities.FadeOut(.5, Color3.new(0, 0, 0))
		local bg = Utilities.Create 'Frame' {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(239/255, 181/255, 71/255),
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = Utilities.gui,
		}
		local sq = Utilities.Create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Parent = Utilities.gui,
		}
		local function update(prop)
			if prop ~= 'AbsoluteSize' then return end
			sq.Position = UDim2.new(0.5, -sq.AbsoluteSize.X/2, 0.0, 0)
		end
		sq.Changed:connect(update)
		update('AbsoluteSize')
		local eggFrame = (self:getIcon(data.eggIcon))
		local egg = eggFrame:GetChildren()[1]
		egg.Parent = sq
		eggFrame:Destroy()
		local s = .3
		egg.Size = UDim2.new(s, 0, s, 0)
		egg.Position = UDim2.new(.5-s/2, 0, .5-s/2, 0)
		Utilities.FadeIn(.5)
		Utilities.sound(287784334, nil, nil, 5)
		local sound
		delay(1, function()
			sound = Utilities.loopSound(10841117508)--ev
		end)
		wait(.5)
		local crack = Utilities.Create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://12983571985',
			ImageRectSize = Vector2.new(30, 32),
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ResampleMode = Enum.ResamplerMode.Pixelated,
			ZIndex = 6,
		}
		local function crackStage(s)
			crack.ImageRectOffset = Vector2.new(30*(s+2), 32*20)
		end
		crackStage(1)
		for i = 1, 2 do
			Utilities.Tween(1, nil, function(a)
				local p = math.cos(a*math.pi*2)
				local sy = s*.85
				local oy = 0
				if p > 0 then
					--				if i == 1 and a > .5 then return false end
					sy = s*(.85+p*.15)
				else
					local p2 = math.sin((a*math.pi*2-math.pi/2)*1.2)
					if p2 > 0 then
						sy = s*(.85+p2*.25)
					end
					oy = p*s*.3
				end
				egg.Size = UDim2.new(s, 0, sy, 0)
				egg.Position = UDim2.new(.5-s/2, 0, .5-s/2+(s-sy)+oy, 0)
			end)
			wait(.2)
			if i == 1 then
				crack.Parent = egg
			else
				crackStage(2)
			end
		end
		wait(.5)
		Utilities.Tween(1, nil, function(a)
			local p = math.sin(a*math.pi*2)
			egg.Rotation = 45*p
			egg.Size = UDim2.new(s, 0, s, 0)
			egg.Position = UDim2.new(.5-s/2+s*p/math.pi, 0, .5-s/2, 0)
		end)
		crackStage(3)
		wait(.1)
		Utilities.Tween(.8, nil, function(a)
			local p = math.cos(a*math.pi*2)
			local sy = s*.85
			local oy = 0
			if p > 0 then
				if a > .5 then return false end
				sy = s*(.85+p*.15)
			else
				local p2 = math.sin((a*math.pi*2-math.pi/2)*1.2)
				if p2 > 0 then
					sy = s*(.85+p2*.25)
				end
				oy = p*s*.3
			end
			egg.Size = UDim2.new(s, 0, sy, 0)
			egg.Position = UDim2.new(.5-s/2, 0, .5-s/2+(s-sy)+oy, 0)
		end)
		crackStage(4)
		wait(.1)
		Utilities.Tween(.8, nil, function(a)
			local p = math.sin(a*math.pi*2)
			local sy = s
			if a < .25 then
				sy = s*(.85+p*.15)
			end
			egg.Rotation = 45*p
			egg.Size = UDim2.new(s, 0, sy, 0)
			egg.Position = UDim2.new(.5-s/2+s*p/math.pi, 0, 0.5-s/2+(s-sy), 0)
		end)
		local circle
		spawn(function()
			local p = Utilities.Create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://12983571985',
				ResampleMode = Enum.ResamplerMode.Pixelated,
				ZIndex = 7, Parent = sq,
			}
			circle = p
			Utilities.Tween(.3, nil, function(a)
				local ps = a*1.5
				p.Size = UDim2.new(ps, 0, ps, 0)
				p.Position = UDim2.new(.5-ps/2, 0, .5-ps/2, 0)
				local e = s+a*.3
				egg.Size = UDim2.new(e, 0, e, 0)
				egg.Position = UDim2.new(.5-e/2, 0, .5-e/2, 0)
				egg.ImageTransparency = a
				crack.ImageTransparency = a
			end)
		end)
		wait(.1)
		--	crackStage(5)
		wait(.1)
		Utilities.FadeOut(.3, Color3.new(1, 1, 1))
		egg:Destroy()
		local before = tick()
		local sd = data.pSprite
		local elapsed = tick()-before
		if elapsed < 1 then
			wait(1-elapsed)
		end
		local sprite = _p.AnimatedSprite:new(sd)
		sprite.spriteLabel.Parent = sq
		sprite.spriteLabel.ZIndex = 5
		local scale = sd.scale or 1
		local x = sd.fWidth/175*scale
		local y = sd.fHeight/175*scale
		sprite.spriteLabel.Size = UDim2.new(x, 0, y, 0)
		sprite.spriteLabel.Position = UDim2.new(0.5-x/2, 0, 0.5-y/2, 0)
		sprite:Play()
		spawn(function()
			local p = circle
			Utilities.Tween(.5, nil, function(a)
				local s = (1-a)*1.5
				p.Size = UDim2.new(s, 0, s, 0)
				p.Position = UDim2.new(.5-s/2, 0, .5-s/2, 0)
			end)
			p:Destroy()
		end)
		Utilities.FadeIn(1)
		pcall(function()
			sound:Stop()
			sound:Destroy()
		end)
		Utilities.sound(10841121539, nil, .5, 10)
		_p.NPCChat:say(data.pName .. ' hatched from the Egg!')
		wait(1)
		local nickname
		if _p.NPCChat:say('[y/n]Would you like to give a nickname to the newly hatched ' .. data.pName .. '?') then
			nickname = self:giveNickname(data.pIcon, data.pShiny)
		end
		local st = tick()
		_p.Network:get('PDS', 'makeDecision', data.d_id, nickname)
		local et = tick()-st
		if et < 1 then wait(1-et) end
		Utilities.FadeOut(.5, Color3.new(0, 0, 0))
		sprite:destroy()
		bg:Destroy()
		sq:Destroy()
		wait(.5)
		spawn(function() _p.MusicManager:returnFromSilence(.5) end)
		Utilities.FadeIn(.5)
		if menuWasEnabled then
			Utilities.fastSpawn(function() _p.Menu:enable() end)
		end
		_p.MasterControl.WalkEnabled = true
	end

	function Pokemon:getOT(id)
		if not id or id == _p.userId then return _p.player.Name, _p.userId end
		if id == 12301 then return 'Ash', 12301 end
		if id == 422016303 then return "Law_nz", 422016303 end
		if id == 1 then return "Spawned", 1 end
		if id == 16 then return "DottyBot", 16 end
		if id == 17 then return "From a Code", 17 end
		if id == 18 then return "Roulette", 18 end
		if id == 25 then return "Santa", 25 end
		if id <= 0 then
			return 'Guest', 0
		end
		local name
		local s = pcall(function() name = players:GetNameFromUserIdAsync(id) end)
		return name, id
	end

	function Pokemon:getNature(num)
		return ({
			{name='Hardy'                           },
			{name='Lonely',  plus='atk', minus='def'},
			{name='Brave',   plus='atk', minus='spe'},
			{name='Adamant', plus='atk', minus='spa'},
			{name='Naughty', plus='atk', minus='spd'},
			{name='Bold',    plus='def', minus='atk'},
			{name='Docile'                          },
			{name='Relaxed', plus='def', minus='spe'},
			{name='Impish',  plus='def', minus='spa'},
			{name='Lax',     plus='def', minus='spd'},
			{name='Timid',   plus='spe', minus='atk'},
			{name='Hasty',   plus='spe', minus='def'},
			{name='Serious'                         },
			{name='Jolly',   plus='spe', minus='spa'},
			{name='Naive',   plus='spe', minus='spd'},
			{name='Modest',  plus='spa', minus='atk'},
			{name='Mild',    plus='spa', minus='def'},
			{name='Quiet',   plus='spa', minus='spe'},
			{name='Bashful'                         },
			{name='Rash',    plus='spa', minus='spd'},
			{name='Calm',    plus='spd', minus='atk'},
			{name='Gentle',  plus='spd', minus='def'},
			{name='Sassy',   plus='spd', minus='spe'},
			{name='Careful', plus='spd', minus='spa'},
			{name='Quirky'                          },
		})[num]
	end

	function Pokemon:getTypes(fromTypes)
		local typeFromInt = {'Bug','Dark','Dragon','Electric','Fairy','Fighting','Fire','Flying','Ghost','Grass','Ground','Ice','Normal','Poison','Psychic','Rock','Steel','Water'}
		local types = {}
		for i, t in pairs(fromTypes) do
			types[i] = typeFromInt[t]
		end
		return types
	end

	function Pokemon:getPokeBall(ballId)
		return Pokemon.balls[ballId or 1] or 'pokeball'
	end



	function Pokemon:tryLearnMove(pokemonName, knownMoves, decision)
		local chat = _p.NPCChat
		local move = decision.move
		local moveName = move.name
		local didLearn = false
		local function learnMove(slot)
			didLearn = true
			knownMoves[slot] = move
			local args = {slot}
			if decision.transform then
				args = {decision.transform(move, slot)}
			end
			_p.Network:get('PDS', 'makeDecision', decision.id, unpack(args))
		end
		for i = 1, 4 do
			if not knownMoves[i] then
				chat:say(pokemonName .. ' learned the move ' .. moveName .. '!')
				learnMove(i)
				break
			end
		end
		if not didLearn then
			while true do
				chat:say(pokemonName .. ' wants to learn the move ' .. moveName .. '.')
				chat:say('However, ' .. pokemonName .. ' already knows four moves.')
				local delete = chat:say('[Y/N]Should a move be deleted and replaced with ' .. moveName .. '?')

				if delete then
					chat:say('Which move should be forgotten?')
					local movesCopy = Utilities.shallowcopy(knownMoves)
					movesCopy[#movesCopy+1] = move
					local slot = _p.BattleGui:promptReplaceMove(movesCopy)
					if slot then
						local deletedMove = knownMoves[slot]
						if chat:say('[Y/N]Should ' .. pokemonName .. ' forget ' .. deletedMove.name .. ' in order to learn ' .. moveName .. '?') then
							chat:say('1, 2, and... ... ... Ta-da!', pokemonName .. ' forgot how to use ' .. deletedMove.name .. '.',
								'And...', pokemonName .. ' learned ' .. moveName .. '!')
							learnMove(slot)
							break
						end
					end
				end

				if chat:say('[y/n]Give up on learning the move ' .. moveName .. '?') then
					chat:say(pokemonName .. ' did not learn ' .. moveName .. '.')
					break
				end
			end
		end
		return didLearn
	end

	function Pokemon:learnMoves(pokemonName, knownMoves, decisions)
		for _, decision in pairs(decisions) do
			local move = decision.move
			local knowsMove = false
			for _, m in pairs(knownMoves) do
				if m.name == move.name then
					knowsMove = true
					break
				end
			end
			if not knowsMove then
				if not self:tryLearnMove(pokemonName, knownMoves, decision) then
					_p.Network:get('PDS', 'makeDecision', decision.id, nil)
				end
			end
		end
	end

	function Pokemon:processMovesAndEvolution(data, alreadyFaded)
		-- try to learn moves
		if data.moves then
			self:learnMoves(data.pokeName, data.known, data.moves)
		end
		-- try to evolve
		local evo = data.evo
		if evo then
			if evo.flip then
				local flipped = false
				local orientation0 = evo.orientation0
				local orientation1 = _p.Battle:sampleOrientation()
				if orientation0 and orientation1 then
					orientation0 = (orientation0*Vector3.new(1,0,1)).unit
					orientation1 = (orientation1*Vector3.new(1,0,1)).unit
					if orientation0.magnitude + orientation1.magnitude > 1.9 then
						local angle = math.deg(math.acos(orientation0:Dot(orientation1)))
						if angle > 150 then
							flipped = true
						end
					end
				end
				if not flipped then
					_p.Network:get('PDS', 'makeDecision', evo.decisionId, false)
					return
				end
			end
			local evolved, endFade = _p.BattleGui:animateEvolution(data.pokeName, evo.name, evo.sprite1, evo.sprite2, alreadyFaded, evo.cannotCancel)
			_p.Network:get('PDS', 'makeDecision', evo.decisionId, evolved)
			if evolved and evo.moves then
				self:learnMoves(evo.nickname or evo.name, data.known, evo.moves)
			end
			if endFade then spawn(endFade) end
		end
	end


	return Pokemon end