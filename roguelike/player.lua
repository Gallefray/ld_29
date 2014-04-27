
options = {
	'1',
	'2',
	'3',
	'4',
	'5',
	'6',
	'7',
	'8',
	'9',
	'a',
	'b',
	'c',
	'd',
	'e',
	'f',
	'g',
	'h',
	'i',
	'j',
	'k',
	'l',
	'm',
	'n',
	'o',
	'p',
	'q',
	'r',
	's',
	't',
	'u',
	'v',
	'w',
	'x',
	'y',
	'z'
}

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

function drw_inv(num)
	if player.inv_vis then
		local i, j, k, l
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", 10, 5, 400, 200)

		love.graphics.setColor(250, 250, 250)
		if not player.drop then
			love.graphics.print("Inventory (i or spacebar to exit): ", 10, 5)
		else
			love.graphics.print("Select item (i or spacebar to exit): ", 10, 5)
		end
		love.graphics.setColor(200, 200, 200)
		j = 5
		for i = player.inv_minl, player.inv_maxl do
			j = j + (5 + 24)
			k = i
			for l= 1, player._inv_max do
				if k == l then
					k = options[l]
				end
			end
			if not num then
				if player.inv[i][2] == "w" then
					love.graphics.print("> (W) " .. player.inv[i][1], 10, j);
				else
					love.graphics.print("> " .. player.inv[i][1], 10, j);
				end
			elseif num then
				if player.inv[i][2] == "w" then
					love.graphics.print(k .. ") (W) " .. player.inv[i][1], 10, j);
				else
					love.graphics.print(k .. ") " .. player.inv[i][1], 10, j);
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
			player.inv_vist = false
		end
		if key == "d" then
			add_stat("What do you want to drop?")
			player.drop = true
			player.inv_vis = true
			player.inv_vist = true
		end
		if key == "p" then 
			local i
			for i = 1, #items do
				print("Bip - i " .. i)
				-- ERROR ON FOLLOWING LINE:
				if player.x == items[i][4] and player.y == items[i][5] then
					table.insert(player.inv, {items[i][1], items[i][2], items[i][3]})
					player.inv_cnt = player.inv_cnt + 1 
					add_stat("Picked up " .. items[i][1])
					table.remove(items, i)
				end 
				print("Bop")
			end
		end

	elseif player.inv_vis and not player.drop then
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
			player.inv_vist = false
			add_stat("Never Mind.")
		end
	elseif player.inv_vis and player.drop then
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
			add_stat("Never Mind.")
			player.inv_vis = false
			player.inv_vist = false
			player.drop = false
		else
			local k, l, z
			for k = 1, player.inv_cnt do
				if key == options[k] then
					z = "na"
					for l = 1, #weaps do
						if weaps[l] == player.inv[k][3] then
							z = "nw"
							if player.wield == player.inv[k][3] then
								player.wield = ""
							end
						end
					end
					table.insert(items, {player.inv[k][1], z, player.inv[k][3], player.x, player.y})		
					add_stat("Dropped " .. player.inv[k][1])
					table.remove(player.inv, k)
					player.inv_cnt = player.inv_cnt - 1
					player.inv_vis = false
					player.inv_vist = false
					player.drop = false
				end
			end
		end
	end
end
