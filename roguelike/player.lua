
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
	if not player.primed and not player.inv_vis then
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
	if player.primed and not player.inv_vis then
		if key == "h" then
			fire_weap("left")
		elseif key == "j" then
			fire_weap("down")
		elseif key == "k" then
			fire_weap("up")
		elseif key == "l" then
			fire_weap("right")
		else
			add_stat("Invalid direction!")
			primed = false
		end
	elseif not player.primed and not player.inv_vis then
		local k
		if key == "g" then
			for k = 0, #weaps do
				if player.weild == weaps[k] then
					player.primed = true
					add_stat("Pick a direction to fire in.")
				end
			end
		end
		if key == "i" then
			player.inv_vis = true
		end
	elseif player.inv_vis then
		local k = 5
		if key == "h" then
			if player.inv_minl > 1 then
				player.inv_minl = player.inv_minl - k
				player.inv_maxl = player.inv_maxl - k
			end
		elseif key == "l" then
			if player.inv_maxl < player.inv_cnt then
				player.inv_minl = player.inv_minl + k
				player.inv_maxl = player.inv_maxl + k
			end
		elseif key == " " or key == "i" then
			player.inv_vis = false
		end
	end
end
