lurker = require 'lib/lurker'

require 'levels'

function love.load()
	ubuntubold = love.graphics.newFont("data/fnt/UbuntuMono-B.ttf", 24)
	love.graphics.setFont(ubuntubold)
	variables()
	gen_map(game.mapn)
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
		-- if key == "g" then
		-- 	room_gen(game.mapn)
		-- 	print("------------------------------------------")
		-- end
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
	-- gen.miRx = 4
	-- gen.miRy = 4

	-- gen.mxRw = 25
	-- gen.mxRh = 26
	-- gen.miRw = 4
	-- gen.miRh = 4

	player = {}
	player.x = 30
	player.y = 15*3
	player.inventory = {}
end

function drw_map()
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
	math.randomseed(os.time())

	local x = math.random(1+2, game.mapw-2)
	local y = math.random(1+2, game.maph-2)
	local w = math.random(4, 26)
	local h = math.random(4, 26)

	print("x: " .. x .. " y: " .. y .. " w: " .. w .. " h: " .. h)

	for k = 0, 11 do
		if x+w > game.mapw then
			x = math.random(1+2, game.mapw-2)
			w = math.random(4, 26)
			print("regenerating the x coordinate and width")
		end
		if y+h > game.maph then
			y = math.random(1+2, game.maph-2)
			h = math.random(4, 24)
			print("regenerating the y coordinate and height")
		end
	end

	if x+w >= game.mapw or y+h >= game.maph then
		print("Tried 11 times - Failed")
		return 0
	end

	local regen = false
	for k = 0, 11 do
		regen = false
		if x+w < game.mapw and y+h < game.maph then
			for i = x, x+w do
				for j = y, y+h do
					print("J: " .. j .. " I: " .. i)
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
			x = math.random(1+2, game.mapw-2)
			w = math.random(4, 26)
		end
		if y+h >= game.maph or regen == true then
			y = math.random(1+2, game.maph-3)
			h = math.random(4, 24)
		end
	end

	if x+w > game.mapw or y+h > game.maph or regen == true then
		print("Tried 11 times - Failed")
		return 0
	end

	-- Lay down the room 
	-- doors incoming
	print("placing room")
	for i = x, x+w do
		for j = y, y+h do
			game.map[mapn][j][i] = wall
		end
	end
	return 1
end

function gen_map(mapn)
	local tab = {}
	local i, j
	for j = 1, game.maph do
		local t = {}
		for i = 1, game.mapw do
			table.insert(t, 0)
		end
		table.insert(tab, t)
	end
	table.insert(maps, mapn, tab)

	for i = 0, 11 do
		gen_room(mapn)
	end
end

