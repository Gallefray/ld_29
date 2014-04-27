lurker = require 'lib/lurker'


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
	drw_player()
	drw_inv(false)

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
	player = {}
	player.hp = 95
	player._mhp = 100
	player.arm = 30
	player.pwr = 90

	player.inv = {  -- name, wielded?, type      
		{"Medium Strength Mining Laser", "w", "weap"},
		{"Low Strength Mining Laser", "nw", "weap"},
		{"foo", "nw"}, 
		{"bar", "nw"},
		{"foobar", "nw"},
		{"baz", "nw"},
		{"foo", "nw"}, 
		{"bar", "nw"},
		{"foobar", "nw"},
		{"baz", "nw"},
		{"foo", "nw"}, 
		{"bar", "nw"},
		{"foobar", "nw"},
		{"baz", "nw"},
		{"quux", "nw"}
	}
	player.inv_cnt = 15
	player.inv_vis = false
	player.inv_maxl = 5
	player.inv_minl = 1

	player.wield = "MLASMID"

	player.primed = false

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

	love.graphics.setColor(150, 150, 150, 255)
	love.graphics.print("ARM: ", 125, (game.maph+1.2)*game.ts)
	colorize(player.arm)
	love.graphics.print(player.arm, 125+53, (game.maph+1.2)*game.ts)
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

function drw_inv(num)
	if player.inv_vis then
		local i, j
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", 10, 5, 400, 200)

		love.graphics.setColor(250, 250, 250)
		love.graphics.print("Inventory (i or spacebar to exit): ", 10, 5);
		love.graphics.setColor(200, 200, 200)
		j = 5
		for i = player.inv_minl, player.inv_maxl do
			j = j + (5 + 24)
			if not num then
				if player.inv[i][2] == "w" then
					love.graphics.print("> (W) " .. player.inv[i][1], 10, j);
				else
					love.graphics.print("> " .. player.inv[i][1], 10, j);
				end
			else
				if player.inv[i][2] == "w" then
					love.graphics.print(i .. ") (W) " .. player.inv[i][1], 10, j);
				else
					love.graphics.print(i .. ") " .. player.inv[i][1], 10, j);
				end
			end
		end
		j = j + (5 + 24)
		love.graphics.setColor(225, 225, 225)
		if player.inv_maxl < #player.inv and player.inv_minl == 1 then
			love.graphics.print("Next (l) >>>>", 10, j)
		elseif player.inv_maxl < #player.inv and player.inv_minl > 1 then
			love.graphics.print("<<<< (h) Prev | Next (l) >>>>", 10, j)
		elseif player.inv_maxl == #player.inv and player.inv_minl > 1 then
			love.graphics.print("<<<< (h) Prev", 10, j)
		end
	end
end