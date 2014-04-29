function add_stat(s)
	status[4] = status[3]
	status[3] = status[2]
	status[2] = status[1]
	status[1] = s
end

function drw_stat()
	love.graphics.setColor(150, 150, 150, 55)
	love.graphics.print(status[4], 315, (game.maph+1.2)*game.ts)
	love.graphics.setColor(150, 150, 150, 100)
	love.graphics.print(status[3], 315, (game.maph+2.4)*game.ts)
	love.graphics.setColor(150, 150, 150, 155)
	love.graphics.print(status[2], 315, (game.maph+3.6)*game.ts)
	love.graphics.setColor(150, 150, 150, 200)
	love.graphics.print(status[1], 315, (game.maph+4.8)*game.ts)
end