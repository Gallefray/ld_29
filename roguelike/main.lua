lurker = require 'lib/lurker'

--[[
	Coding conventions:
	I've tried to stay as close to the K&R naming convention as possible.
	Any variable beginning with `_` is a constant.
	A table beginning with `_` is either a constant or you can read it as an -
	enum.
-- ]]

function love.load()
	ubuntubold = love.graphics.newFont("data/fnt/UbuntuMono-B.ttf", 22)
	love.graphics.setFont(ubuntubold)

	require 'levels'
	variables()

	require 'noti'
	require 'player'
	require 'weap'
	require 'gen'

	gen_map(game.mapn)
	gen_player(game.mapn)
	gen_AI(game.mapn)
end

function love.update(dt)
	lurker.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
	mov_player(dt)
	if turn >= 2 then
		act_ai()
		turn = 0
	end
end

function love.keypressed(key, isrepeat)	
	if not isrepeat then
		mov_player(key)
		act_player(key)
		if not player.primed and not player.inv_vis then
			if turn < 2 then
				turn_step = math.random(1, 1.9)
				turn = turn + turn_step
			end
		end
	end
end

function love.draw()
	drw_map()
	drw_hud()
	drw_stat()
	drw_items()
	drw_player()
	drw_ai()
	drw_inv(player.inv_vist)
end

function variables()
	love.window.setTitle("LD29")

	turn = 0
	turn_step = 0

	screen = {}
	screen.w = love.window.getWidth()
	screen.h = love.window.getHeight()
	screen.tx, screen.ty = 0
	screen.sx, screen.sy = 0

	game = {}
	game.mapw = 53
	game.maph = 33
	game.mapn = 1
	game.map = maps
	game.ts = 15 -- ?

	status = {
		" ",
		" ",
		" ",
		" "
	}

	gen = {}
	items = {}

	ai = {}		-- This is the table full of monsters

	ai_dat = {
		mindmg = 5,
		maxdmg = 20,
		minhp = 20,
		maxhp = 50
	}
	_ai_n = {
		-- nam
		troll = 1,
		slug = 2,
		grue = 3,	-- You are likely to be eaten by a grue... etc
		alien = 4
	}
	_ai_t = {
		-- multipliers:
		1.3,
		1,
		2,
		2.5
	}
	_ai_stat = {
		["flee"] = 1,
		["fight"] = 2,
		["inert"] = 3
	}

	player = {}
	player.hp = 95
	player._mhp = 100
	-- player.arm = 30
	player.pwr = 90

	player.inv = {  -- name, wield status, type      
		{"Medium Strength Mining Laser", "w", "MLASMID"},
		{"Low Strength Mining Laser", "nw", "MLASLOW"},
		{"item 1", "na", "NONE"}, 
		{"item 2", "na", "NONE"},
		{"item 3", "na", "NONE"},
		{"item 4", "na", "NONE"},
		{"item 5", "na", "NONE"}, 
		{"item 6", "na", "NONE"},
		{"item 7", "na", "NONE"},
		{"item 8", "na", "NONE"},
		{"item 9", "na", "NONE"}, 
		{"item 10", "na", "NONE"},
		{"item 11", "na", "NONE"},
		{"item 12", "na", "NONE"},
		{"item 13", "na", "NONE"}
	}
	-- See the inv HUD
	player.inv_vis = false
	player.inv_vist = false
	-- Currnt and limit
	player.inv_cnt = 15
	player._inv_max = 26 + 9
	-- HUD values
	player.inv_maxl = 5
	player.inv_minl = 1
	-- Drop things?
	player.drop = false

	-- Currently *:
	player.wield = "MLASMID"
	player.wield_v = false
	-- Weapon primed?
	player.primed = false
	-- Total weapons in game:
	weaps = {
		"MLASLOW",
		"MLASMID"
	}
end

function colorize(i)
	if i <= 10 then
		love.graphics.setColor(255, 0, 0)
	elseif i <= 25 then
		love.graphics.setColor(250, 119, 5)
	elseif i <= 50 then
		love.graphics.setColor(250, 172, 5)
	elseif i <= 75 then
		love.graphics.setColor(250, 201, 5)
	elseif i <= 84 then
		love.graphics.setColor(217, 250, 5)
	elseif i <= 90 then
		love.graphics.setColor(168, 250, 7)
	elseif i <= 95 then
		love.graphics.setColor(115, 250, 5)
	elseif i == 100 then
		love.graphics.setColor(64, 255, 86)
	end
end

function drw_hud()
	local i
	love.graphics.setColor(150, 150, 150, 255)
	for i = 0, game.mapw do
		love.graphics.print("~", i*game.ts, (game.maph)*game.ts)
	end
	love.graphics.setColor(150, 150, 150, 255)
	love.graphics.print("HP: ", 15, (game.maph+1.2)*game.ts)
	colorize(player.hp)
	love.graphics.print(player.hp, 53, (game.maph+1.2)*game.ts)
	love.graphics.setColor(150, 150, 150, 255)
	love.graphics.print("PWR: ", 15, (game.maph+2.7)*game.ts)
	colorize(player.pwr)
	love.graphics.print(player.pwr, 64, (game.maph+2.7)*game.ts)
	love.graphics.setColor(150, 150, 150, 255)
	love.graphics.print("LVL: " .. game.mapn, 15, (game.maph+4.2)*game.ts)
end

-- I could clean up a lot of code by using this function, something for day 3!
function chk_tile(x, y, dir, tile) 
	local i = x/game.ts
	local j = y/game.ts
	if dir == "left" then
		return (game.map[game.mapn][j][i-1] == tile)
	elseif dir == "down" then
		return (game.map[game.mapn][j+1][i] == tile)
	elseif dir == "up" then
		return (game.map[game.mapn][j-1][i] == tile)
	elseif dir == "right" then
		return (game.map[game.mapn][j][i+1] == tile)
	end
	return false
end

function drw_items()
	local i, j, k

	for i = 1, #items do
		k = "i"
		for j = 1, #weaps do
			if items[i][3] == weaps[j] then
				k = "w"
			end
		end
		if k == "i" then
			love.graphics.setColor(25, 200, 25)
		elseif k == "w" then
			love.graphics.setColor(200, 25, 25)
		end
		love.graphics.print(k, items[i][4]-8, items[i][5]-16)
	end
end

function gen_AI(mapn)
	-- data is packed into the table like:
	-- {mname, x, y, attack, hp, state}
	local mname = math.random(1, #_ai_n)
	local attack = math.random((ai_dat.mindmg*mapn)*_ai_t[mname],
							   (ai_dat.maxdmg*mapn)*_ai_t[mname])
	local hp = math.random(ai_dat.minhp*mapn*_ai_t[mname],
						   ai_dat.maxhp*mapn*_ai_t[mname])
	local state = _ai_stat["inert"]

	local loc = {}
	for i = 1, game.mapw do
		for j = 1, game.maph do
			if game.map[mapn][j][i] == floor then
				table.insert(loc, {x=i, y=j})
			end
		end
	end

	local k = math.random(1, #loc)
	table.insert(ai, {nam=mname, x=loc[k].x*game.ts, y=loc[k].y*game.ts, atk=attack, hp=hp, state=state})
end

function drw_ai()
	local i
	for i = 1, #ai do
		love.graphics.setColor(255, 255, 255, 255)
		if ai[i].nam == _ai_n.troll then
			colorize(ai[i].hp)
			love.graphics.print("S", ai[i].x-8, ai[i].y-16)
		elseif ai[i].nam == _ai_n.slug then
			colorize(ai[i].hp)
			love.graphics.print("T", ai[i].x-8, ai[i].y-16)
		elseif ai[i].nam == _ai_n.grue then
			colorize(ai[i].hp)
			love.graphics.print("G", ai[i].x-8, ai[i].y-16)
		elseif ai[i].nam == _ai_n.alien then
			colorize(ai[i].hp)
			love.graphics.print("A", ai[i].x-8, ai[i].y-16)
		end
	end
	--print(player.x .. "  " .. player.y)
end

function act_ai()
	local i 
	local DIST = 15*6

	for i = 1, #ai do
		-- print("i: " .. i)
		-- print("HP: " .. (ai[i].hp/(ai_dat.maxhp*game.mapn*_ai_t[ai[i].nam]))*100)

		if ai[i].state == _ai_stat["inert"] then
			-- print("inert")
			if player.x < ai[i].x+DIST and player.x > ai[i].x-DIST and
			   player.y < ai[i].y+DIST and player.y > ai[i].y-DIST then

			    if (ai[i].hp/(ai_dat.maxhp*game.mapn*_ai_t[ai[i].nam]))*100 < 25 then
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
			if player.x < ai[i].x+DIST and player.x > ai[i].x-DIST and
			   player.y < ai[i].y+DIST and player.y > ai[i].y-DIST then
				if ai[i].nam == _ai_n.alien then
					-- get player - alien distance and randomize between 
					-- dist/3 and dist for firing gun
				else
					local px = player.x/game.ts
					local py = player.y/game.ts
					local ax = ai[i].x/game.ts
					local ay = ai[i].y/game.ts

					-- left, down, up right
					if ax-1 == px and ay == py then
						add_stat("The " .. ai[i].nam .. " attacks you! (left)")
					elseif ax == px and ay+1 == py then
						add_stat("The " .. ai[i].nam .. " attacks you! (down)")
					elseif ax == px and ay-1 == py then
						add_stat("The " .. ai[i].nam .. " attacks you! (up)")
					elseif ax+1 == px and ay == py then
						add_stat("The " .. ai[i].nam .. " attacks you! (right)")
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