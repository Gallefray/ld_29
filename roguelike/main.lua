lurker = require 'lib/lurker'

require 'levels'
require 'player'
require 'gen'


function love.load()
	ubuntubold = love.graphics.newFont("data/fnt/UbuntuMono-B.ttf", 22)
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
		-- if key == "1" then
		-- 	stat_add()
		-- end
		mov_player(key)
		act_player(key)
	end
end

function love.draw()
	drw_map()
	drw_hud()
	drw_stat()
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
	game.maph = 33
	game.mapn = 1
	game.map = maps
	game.ts = 15 -- ?

	status = {
	"",
	"",
	"",
	""
	}

	gen = {}
	player = {}
	player.hp = 95
	player._mhp = 100
	player.arm = 30
	player.pwr = 90
	player.inv = {}
	player.wield = "MLASLOW"
	player.primed = false
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

function weap_mlaslow(dir) -- mining laser low power
	local j = player.y/game.ts
	local i = player.x/game.ts
	if dir == "left" then
		if chk_tile(player.x, player.y, "left", wall) then
			 game.map[game.mapn][j][i-1] = floor
		end
	elseif dir == "down" then
		if chk_tile(player.x, player.y, "down", wall) then
			game.map[game.mapn][j+1][i] = floor
		end
	elseif dir == "up" then
		if chk_tile(player.x, player.y, "up", wall) then
			game.map[game.mapn][j-1][i] = floor
		end
	elseif dir == "right" then
		if chk_tile(player.x, player.y, "right", wall) then
			 game.map[game.mapn][j][i+1] = floor
		end
	end
end

function weap_mlasmid(dir) -- mining laser low power
	local j = player.y/game.ts
	local i = player.x/game.ts
	if dir == "left" then
		if chk_tile(player.x, player.y, "left", wall) or 
		   chk_tile(player.x, player.y, "left", air) then
			 game.map[game.mapn][j][i-1] = floor
			 game.map[game.mapn][j][i-2] = floor
			 game.map[game.mapn][j-1][i-1] = wall
			 game.map[game.mapn][j+1][i-1] = wall
			 game.map[game.mapn][j-1][i-2] = wall
			 game.map[game.mapn][j+1][i-2] = wall
		end
	elseif dir == "down" then
		if chk_tile(player.x, player.y, "down", wall) or 
		   chk_tile(player.x, player.y, "down", air) then
			game.map[game.mapn][j+1][i] = floor
			game.map[game.mapn][j+2][i] = floor
			game.map[game.mapn][j+2][i+1] = wall
			game.map[game.mapn][j+2][i-1] = wall
			game.map[game.mapn][j+1][i+1] = wall
			game.map[game.mapn][j+1][i-1] = wall
		end
	elseif dir == "up" then
		if chk_tile(player.x, player.y, "up", wall) or 
		   chk_tile(player.x, player.y, "up", air) then
			game.map[game.mapn][j-1][i] = floor
			game.map[game.mapn][j-2][i] = floor
			game.map[game.mapn][j-2][i-1] = wall
			game.map[game.mapn][j-2][i+1] = wall
			game.map[game.mapn][j-1][i-1] = wall
			game.map[game.mapn][j-1][i+1] = wall
		end
	elseif dir == "right" then
		if chk_tile(player.x, player.y, "right", wall) or
		   chk_tile(player.x, player.y, "right", air) then
			 game.map[game.mapn][j][i+1] = floor
			 game.map[game.mapn][j][i+2] = floor
			 game.map[game.mapn][j+1][i+1] = wall
			 game.map[game.mapn][j-1][i+1] = wall
			 game.map[game.mapn][j+1][i+2] = wall
			 game.map[game.mapn][j-1][i+2] = wall
		end
	end
end

function stat_add(s)
	status[4] = status[3]
	status[3] = status[2]
	status[2] = status[1]
	status[1] = s
end

function drw_stat()
	love.graphics.setColor(150, 150, 150, 55)
	love.graphics.print(status[4], 370, (game.maph+1.2)*game.ts)
	love.graphics.setColor(150, 150, 150, 100)
	love.graphics.print(status[3], 370, (game.maph+2.4)*game.ts)
	love.graphics.setColor(150, 150, 150, 155)
	love.graphics.print(status[2], 370, (game.maph+3.6)*game.ts)
	love.graphics.setColor(150, 150, 150, 200)
	love.graphics.print(status[1], 370, (game.maph+4.8)*game.ts)
end

function fire_weap(dir)
	if player.wield == "MLASLOW" then
		weap_mlaslow(dir)
		stat_add("Zap!")
		player.primed = false
	end
end