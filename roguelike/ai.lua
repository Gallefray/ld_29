
function gen_ai(mapn)
	-- data is packed into the table like:
	-- {mname, x, y, attack, hp, state}
	local mname = math.random(1, #_ai_n)
	local attack_min = math.random((ai_dat.mindmg*mapn)*_ai_t[mname],
							   (ai_dat.maxdmg*mapn)*_ai_t[mname])
	local attack_max = math.random(attack_min,
							   (ai_dat.maxdmg*mapn)*_ai_t[mname])
	local hp = math.random(ai_dat.minhp*mapn*_ai_t[mname],
						   ai_dat.maxhp*mapn*_ai_t[mname])
	local state = _ai_stat["inert"]
	local alive = true
	local loc = {}
	for i = 1, game.mapw do
		for j = 1, game.maph do
			if game.map[mapn][j][i] == floor then
				table.insert(loc, {x=i, y=j})
			end
		end
	end

	local k = math.random(1, #loc)
	table.insert(ai, {nam=mname, x=loc[k].x*game.ts, y=loc[k].y*game.ts, atkmin=attack_min, atkmax=attack_max, hp=hp, state=state, alive=alive})
end

function drw_ai()
	local i
	for i = 1, #ai do
		if ai[i] ~= nil then
			love.graphics.setColor(255, 255, 255, 255)
			if _ai_hn[ai[i].nam] == "slug" and ai[i].alive then
				colorize(ai[i].hp)
				love.graphics.print("S", ai[i].x-8, ai[i].y-16)
			elseif _ai_hn[ai[i].nam] == "troll" and ai[i].alive then
				colorize(ai[i].hp)
				love.graphics.print("T", ai[i].x-8, ai[i].y-16)
			elseif _ai_hn[ai[i].nam] == "grue" and ai[i].alive then
				colorize(ai[i].hp)
				love.graphics.print("G", ai[i].x-8, ai[i].y-16)
			elseif _ai_hn[ai[i].nam] == "alien" and ai[i].alive then
				colorize(ai[i].hp)
				love.graphics.print("A", ai[i].x-8, ai[i].y-16)
			end
		end
	end
	--print(player.x .. "  " .. player.y)
end

function act_ai()
	local i 
	local DIST = 15*6

	for i = 1, #ai do
		if ai[i] ~= nil then
			-- print("i: " .. i)
			-- print("HP: " .. (ai[i].hp/(ai_dat.maxhp*game.mapn*_ai_t[ai[i].nam]))*100)
			if ai[i].alive then
				if ai[i].state == _ai_stat["inert"] then
					-- print("inert")
					if player.x < ai[i].x+DIST and player.x > ai[i].x-DIST and
					   player.y < ai[i].y+DIST and player.y > ai[i].y-DIST then

					    if (ai[i].hp/(ai_dat.maxhp*game.mapn*_ai_t[ai[i].nam]))*100 < 50 then
					    	ai[i].state = _ai_stat["flee"]
					    else
					    	ai[i].state = _ai_stat["fight"]
					    end
					end
				elseif ai[i].state == _ai_stat["flee"] then
					if player.x < ai[i].x+DIST and player.x > ai[i].x-DIST and
					   player.y < ai[i].y+DIST and player.y > ai[i].y-DIST then
						if player.x > ai[i].x then
							mov_ai(i, "left")
						elseif player.y < ai[i].y then
							mov_ai(i, "down")
						elseif player.y > ai[i].y then
							mov_ai(i, "up")
						elseif player.x < ai[i].x then
							mov_ai(i, "right")
						end
					end

				elseif ai[i].state == _ai_stat["fight"] then
					local DIST = 15*8
					local sDIST = 15*6
					if player.x < ai[i].x+DIST and player.x > ai[i].x-DIST and
					   player.y < ai[i].y+DIST and player.y > ai[i].y-DIST then
						if ai[i].nam == _ai_n.alien then
							-- Get player - alien distance and randomize between 
							-- dist/3 and dist for firing gun
							if player > 15*6 then

							end
						else
							local px = player.x/game.ts
							local py = player.y/game.ts
							local ax = ai[i].x/game.ts
							local ay = ai[i].y/game.ts

							-- left, down, up right
							if ax-1 == px and ay == py then
								atk_ai(i)
							elseif ax == px and ay+1 == py then
								atk_ai(i)
							elseif ax == px and ay-1 == py then
								atk_ai(i)
							elseif ax+1 == px and ay == py then
								atk_ai(i)
							else
								if player.x > ai[i].x then
									mov_ai(i, "right")
								elseif player.y < ai[i].y then
									mov_ai(i, "up")
								end
								if player.y > ai[i].y then
									mov_ai(i, "down")
								elseif player.x < ai[i].x then
									mov_ai(i, "left")
								end
							end
						end
					end
					if (ai[i].hp/(ai_dat.maxhp*game.mapn*_ai_t[ai[i].nam]))*100 < 50 then
					    ai[i].state = _ai_stat["flee"]
					end
				end
				if ai[i].hp < 0 then
					ai[i].alive = false
					die_ai(i)
				end
			end
		end
	end
end

function mov_ai(i, dir)
	local nx = ai[i].x
	local ny = ai[i].y
	if dir == "left" then
		if not chk_tile(nx, ny, "left", wall) and 
			   chk_tile(nx, ny, "left", floor) then
			ai[i].x = ai[i].x - game.ts
		end
	elseif dir == "right" then
		if not chk_tile(nx, ny, "right", wall) and
			   chk_tile(nx, ny, "right", floor) then
			ai[i].x = ai[i].x + game.ts
		end
	end
	if dir == "down" then
		if not chk_tile(nx, ny, "down", wall) and
			   chk_tile(nx, ny, "down", floor) then
			ai[i].y = ai[i].y + game.ts
		end
	elseif dir == "up" then
		if not chk_tile(nx, ny, "up", wall) and
			   chk_tile(nx, ny, "up", floor) then
			ai[i].y = ai[i].y - game.ts
		end
	end
end

function atk_ai(i) -- ai -> player
	name = _ai_hn[ai[i].nam]
	j = math.random(0.0, 1.2) -- chance of getting hit (on... ;_;)
	if j < .5 then
		local loss = math.random(ai[i].atkmin, ai[i].atkmax)
		add_stat("The " .. name .. " attacked you!")
		add_stat("You lose " .. loss .. " HP!")
		player.hp = player.hp - loss
	else
		add_stat("The " .. name .. " missed!")
	end
end

function atk_player(i)
	local name = _ai_hn[ai[i].nam]
	local j = math.random(0.0, 1) -- chance of hitting (it off... ;_;)
	local min, max, k
	if j < .5 then
		for k = 1, #player.inv do
			if player.inv[k][2] == "w" then
				min = player.inv[k][4]
				max = player.inv[k][5]
				break
			end
		end
		local loss = math.random(min, max)*player.pwr
		add_stat("You attacked the " .. name .. "!")
		add_stat("The " .. name .. " loses " .. loss .. " HP!")
		ai[i].hp = ai[i].hp - loss
	else
		add_stat("You missed!")
	end
end

function die_ai(i)
	local r = math.random(1, 4)
	local s = ""
	if r == 1 then
		s = ":"
	elseif r == 2 then
		s = "&"
	elseif r == 3 then
		s = "-"
	elseif r == 4 then
		s = "%"
	end
	table.insert(items, {_ai_hn[ai[i].nam] .. " corpse", "c", "FOOD", ai[i].x, ai[i].y, s})
	table.remove(ai, i)
end
  