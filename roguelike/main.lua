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
	require 'ai'

	gen_map(1)
	get_mast(game.mapn)
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
	drw_doors()
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
	game.mapn = 2
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
		1,
		2,
		3,	-- You are likely to be eaten by a grue... etc
		4
	}
	_ai_hn = { -- human readable names
		-- nam
		"troll",
		"slug",
		"grue",	-- You are likely to be eaten by a grue... etc
		"alien"
	}
	_ai_t = {
		-- multipliers:
		1,
		1.1,
		1.2,
		1.6
	}
	_ai_stat = {
		["flee"] = 1,
		["fight"] = 2,
		["inert"] = 3
	}

	player = {}
	player.hp = 200
	player._mhp = 200
	player.score = 0
	player.pwr = 1

	player.inv = {  -- name, wield status, type      
		{"Medium Strength Mining Laser", "w", "MLASMID", 10, 24},
		{"Low Strength Mining Laser", "nw", "MLASLOW", 2, 5}
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
	-- Eat things?
	player.eat = true
	player.eat_min = 5
	player.eat_max = 40

	-- amount of money on the floor (times player.mapn)
	player.score_min = 10
	player.score_max = 50

	-- amount of power (multiplier)
	player.power_min = 1
	player.power_max = 3

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

	dwndoor = {x=0, y=0}
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
	elseif i <= 100 or i > 100 then
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
	love.graphics.setColor(150, 150, 150, 255)
	love.graphics.print("Score: ", 110, (game.maph+1.2)*game.ts)
	love.graphics.print(player.score, 185, (game.maph+1.2)*game.ts)
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
	local i, k

	for i = 1, #items do
		if items[i][3] == "MONEY" then
			k = "$"
			love.graphics.setColor(245, 204, 83)
		elseif items[i][3] == "POWER" then
			k = "~"
			love.graphics.setColor(245, 204, 83)
		elseif items[i][3] == "FOOD" then
			k = items[i][6]
			love.graphics.setColor(200, 100, 25)
		else
			if k == "i" then
				love.graphics.setColor(25, 200, 25)
			elseif k == "w" then
				love.graphics.setColor(200, 25, 25)
			elseif k == "c" then
				love.graphics.setColor(200, 25, 25)
			end
		end
		love.graphics.print(k, items[i][4]-8, items[i][5]-16)
	end
end

function drw_doors()
	love.graphics.setColor(170, 170, 170)
	love.graphics.print(">", dwndoor.x-8, dwndoor.y-16)
end
