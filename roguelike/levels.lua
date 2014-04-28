air		= 0
wall 	= 1
floor   = 2
doorup  = 3
doordwn = 4

maps = {}

function drw_map()
	local i, j
	for j = 1, game.maph do
		for i = 1, game.mapw do
			if game.map[game.mapn][j][i] == air then
				love.graphics.setColor(10, 10, 10, 255)
				love.graphics.print("-", i*game.ts-8, j*game.ts-16)
			elseif game.map[game.mapn][j][i] == wall then
				love.graphics.setColor(130, 130, 130, 255)
				love.graphics.print("#", i*game.ts-8, j*game.ts-16)
			elseif game.map[game.mapn][j][i] == floor then
				love.graphics.setColor(50, 50, 50, 255)
				love.graphics.print(".", i*game.ts-8, j*game.ts-16)
			elseif game.map[game.mapn][j][i] == doorup then
				love.graphics.setColor(50, 50, 50, 255)
				love.graphics.print(".", i*game.ts-8, j*game.ts-16)
			    
			end
		end
	end
end