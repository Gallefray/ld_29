
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
	if not player.primed then
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
end

function act_player(key)
	if player.primed == true then
		if key == 'h' then
			fire_weap("left")
		elseif key == 'j' then
			fire_weap("down")
		elseif key == 'k' then
			fire_weap("up")
		elseif key == 'l' then
			fire_weap("right")
		else
			stat_add("Invalid direction!")
			primed = false
		end
	else
		print("bleep")
		if key == 'g' and player.wield == "MLASLOW" then
			print("bloop")
			player.primed = true
			stat_add("Pick a direction to fire in.")
		end
	end
end
