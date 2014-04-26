lurker = require 'lib/lurker'

require 'levels'

function love.load()
	ubuntubold = love.graphics.newFont("data/fnt/UbuntuMono-B.ttf", 24)
	love.graphics.setFont(ubuntubold)
	variables()
	gen_map(game.mapn)
	gen_player(game.mapn)
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
	end
end

function love.draw()
	drw_map()
	drw_player()
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
	game.maph = 39
	game.mapn = 1
	game.map = maps
	game.ts = 15 -- ?

	gen = {}
	player = {}
	-- player.x = 30
	-- player.y = 15*3
	player.inventory = {}
end

function drw_map()
	local i, j
	for j = 1, game.maph do
		for i = 1, game.mapw do
			if game.map[game.mapn][j][i] == wall then
				love.graphics.setColor(100, 100, 100, 255)
				love.graphics.print("#", i*game.ts-8, j*game.ts-16)
			elseif game.map[game.mapn][j][i] == floor then
				love.graphics.setColor(100, 100, 100, 255)
				love.graphics.print(".", i*game.ts-8, j*game.ts-16)
			end
		end
	end
end

function gen_player(mapn)
	local i, j, k

	local loc = {}
	for i = 1, game.mapw do
		for j = 1, game.maph do
			if game.map[mapn][j][i] == floor then
				table.insert(loc, {x=i, y=j})
			end
		end
	end

	k = math.random(1, #loc)
	player.x = loc[k].x*game.ts
	player.y = loc[k].y*game.ts
end

function drw_player()
	love.graphics.setColor(25, 25, 255, 255)
	love.graphics.print("@", player.x-8, player.y-16)
end

function mov_player(key)
	local px = player.x
	local py = player.y
	if key == "h" then
		if not chk_tile(px, py, "left", wall) and 
			   chk_tile(px, py, "left", floor) then
			player.x = player.x - game.ts
		end
	elseif key == "j" then
		if not chk_tile(px, py, "down", wall) and
			   chk_tile(px, py, "down", floor) then
			player.y = player.y + game.ts
		end
	elseif key == "k" then
		if not chk_tile(px, py, "up", wall) and
			   chk_tile(px, py, "up", floor) then
			player.y = player.y - game.ts
		end
	elseif key == "l" then
		if not chk_tile(px, py, "right", wall) and
			   chk_tile(px, py, "right", floor) then
			player.x = player.x + game.ts
		end
	end
end

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

function gen_room(mapn)
	local k, i, j
	math.randomseed(os.time())

	local min_rx = 1+2
	local min_ry = 1+2
	local max_rx = game.mapw-2
	local max_ry = game.maph-2

	local min_rw = 6
	local min_rh = 6 
	local max_rw = 20
	local max_rh = 20

	local x = math.random(min_rx, max_rx)
	local y = math.random(min_ry, max_ry)
	local w = math.random(min_rw, max_rw)
	local h = math.random(min_rh, max_rh)

	-- print("x: " .. x .. " y: " .. y .. " w: " .. w .. " h: " .. h)

	for k = 0, 11 do
		if x+w > game.mapw then
			x = math.random(min_rx, max_rx)
			w = math.random(min_rw, max_rw)
			-- print("regenerating the x coordinate and width")
		end
		if y+h > game.maph then
			y = math.random(min_ry, max_ry)
			h = math.random(min_rh, max_rh)
			-- print("regenerating the y coordinate and height")
		end
	end

	if x+w >= game.mapw or y+h >= game.maph then
		-- print("Tried 11 times - Failed")
		return 0
	end

	local regen = false
	for k = 0, 11 do
		regen = false
		if x+w < game.mapw and y+h < game.maph then
			for i = x, x+w do
				for j = y, y+h do
					-- print("J: " .. j .. " I: " .. i)
					if game.map[mapn][j][i] == wall or
					   game.map[mapn][j][i] == floor then
					   	regen = true
					   	break
					end
				end
				if regen == true then
					break
				end
			end
		end
		if x+w >= game.mapw or regen == true then
			x = math.random(min_rx, max_rx)
			w = math.random(min_rw, max_rw)
		end
		if y+h >= game.maph or regen == true then
			y = math.random(min_ry, max_ry)
			h = math.random(min_rh, max_rh)
		end
	end

	if x+w > game.mapw or y+h > game.maph or regen == true then
		-- print("Tried 11 times - Failed")
		return 0
	end

	-- check if the room is close to another one and space it out if it is
	-- y top, y bottom
	j = y
	for i = x, x+w do
		if game.map[mapn][j-1][i] == wall or game.map[mapn][j-1][i] == floor then
			y = y + 1
			if y+h > game.maph then
				h = h - 1
			end
		end
	end
	j = y+h
	for i = x, x+w do
		if game.map[mapn][j+1][i] == wall or game.map[mapn][j+1][i] == floor then
			h = h - 1
		end
	end
	-- x top, x bottom
	i = x
	for j = y, y+h do
		if game.map[mapn][j][i-1] == wall or game.map[mapn][j][i-1] == floor then
			x = x + 1
			if x+w > game.maph then
				w = w - 1
			end
		end
	end
	i = x+w
	for j = y, y+h do
		if game.map[mapn][j][i+1] == wall or game.map[mapn][j][i+1] == floor then
			w = w - 1
		end
	end

	-- Lay down the room 
	-- doors incoming
	-- print("placing room")
	local z = math.random(2, 4)
	local c
	for i = x, x+w do
		for j = y, y+h do
			if j == y then
				c = math.random(y, y+w)
				if c > 2 and c < 10 and z > 0 then
					game.map[mapn][j][i] = floor
				else
					game.map[mapn][j][i] = wall
				end
				z = z - 1
			elseif i == x then
				c = math.random(x, x+w)
				if c > 2 and c < 10 and z > 0 then
					game.map[mapn][j][i] = floor
				else
					game.map[mapn][j][i] = wall
				end
				z = z - 1
			elseif i == x+w then
				c = math.random(x, x+w)
				if c > 2 and c < 10 and z > 0 then
					game.map[mapn][j][i] = floor
				else
					game.map[mapn][j][i] = wall
				end
				z = z - 1
			elseif j == y+h then
				c = math.random(y, y+h)
				if c > 2 and c < 10 and z > 0 then
					game.map[mapn][j][i] = floor
				else
					game.map[mapn][j][i] = wall
				end
				z = z - 1
			else
				game.map[mapn][j][i] = floor
			end
		end
	end
	return 1
end

function gen_map(mapn)
	local tab = {}
	local i, j, k, l
	for j = 1, game.maph do
		local t = {}
		for i = 1, game.mapw do
			table.insert(t, 0)
		end
		table.insert(tab, t)
	end
	table.insert(maps, mapn, tab)

	l = true
	while l do
		for k = 0, 40 do
			gen_room(mapn)
		end

		for i = 1, game.mapw do
			for j = 1, game.maph do
				if game.map[mapn][j][i] == wall or game.map[mapn][j][i] == floor
				then
					l = false
				end
			end
		end
	end
end

