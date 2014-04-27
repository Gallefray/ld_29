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
	gen_AI(game.mapn)
	gen_AI(game.mapn)
end

function love.update(dt)
	lurker.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
	mov_player(dt)
end

function love.keypressed(key, isrepeat)	
	if not isrepeat then
		mov_player(key)
		act_player(key)
	end
end

function love.draw()
	drw_map()
	drw_hud()
	drw_stat()
	drw_items()
	drw_player()
	drw_AI()
	drw_inv(player.inv_vist)
end

function variables()
	love.window.setTitle("LD29")

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
		slug = 2
	}
	_ai_t = {
		-- multipliers:
		troll = 1.3,
		slug = 1
	}
	_ai_stat = {
		["flee"] = 1,
		["fight"] = 2
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
	local attack = math.random(ai_dat.mindmg*mapn,
							   ai_dat.maxdmg*mapn)
	local hp = math.random(ai_dat.minhp*mapn,
						   ai_dat.maxhp*mapn)
	local state = math.random(1, 2)

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
	add_stat(loc[k].x*game.ts .. "  " .. loc[k].y*game.ts)
	print(player.x .. "  " .. player.y)
end

function drw_AI()
	local i
	for i = 1, #ai do
		love.graphics.setColor(255, 255, 255, 255)
		if ai[i].nam == _ai_n.troll then
			colorize(ai[i].hp)
			love.graphics.print("S", ai[i].x-8, ai[i].y-16)
		elseif ai[i].nam == _ai_n.slug then
			colorize(ai[i].hp)
			love.graphics.print("T", ai[i].x-8, ai[i].y-16)
		end
	end
	print(player.x .. "  " .. player.y)
end