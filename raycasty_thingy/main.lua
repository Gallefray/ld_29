require 'levels'

function love.load()
	variables()
end

function love.update(dt)
end

function love.draw()
	castRay()
end

function variables()
	screen = {}
	screen.w = love.window.getWidth()
	screen.h = love.window.getHeight()
	screen.tx, screen.ty, screen.sx, screen.sy = 0

	game = {}
	game.ts = 32
	game.map = map1
	game.mapn = MAP1

	player = {}
	player.x = 512
	player.y = 512

	player.vA = 0
	player.FoV = 800
	player.vDis = 255
	player._vStp = 2
	player._vAStp = 0.2
end

function castRay()
	local minA = (player.vA - math.rad(player.FoV/2))
	local maxA = (player.vA + math.rad(player.FoV/2))
	local x, y, i, j = 0
	local wc = 0

	for a = minA, maxA, player._vAStp do
		wc = wc + 1
		for r = 0, player.vDis, player._vStp do
			x = math.cos(a)*r + player.x
			y = math.cos(a)*r + player.y
			print(x .. "  " .. y)
			i = x/game.ts
			j = y/game.ts
			print(i .. "  " .. j)
			if game.map[j][i] == wall then
				love.graphics.setColor(255, 255, 255, r) 
				love.graphics.rectangle("fill", wc, 0, 1, 1)
			end
		end
	end
end