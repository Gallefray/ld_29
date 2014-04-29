
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
				if regen then
					break
				end
			end
		end
		if x+w >= game.mapw or regen then
			x = math.random(min_rx, max_rx)
			w = math.random(min_rw, max_rw)
		end
		if y+h >= game.maph or regen then
			y = math.random(min_ry, max_ry)
			h = math.random(min_rh, max_rh)
		end
	end

	if x+w > game.mapw or y+h > game.maph or regen then
		-- print("Tried 11 times - Failed")
		return 0
	end

	-- check if the room is close to another one and space it out if it is
	-- y top, y bottom
	-- h = h - 2
	j = y
	for i = x, x+w do
		if game.map[mapn][j-1][i] == wall or game.map[mapn][j-1][i] == floor then
			y = y + 1
			if y+h > game.maph then
				h = h - 2
			end
		end
	end

	j = y+h
	for i = x, x+w do
		-- j sometimes goes over the game.maph...
		if j+1 < game.maph then
			if game.map[mapn][j+1][i] == floor then
				h = h - 1
			end
			if game.map[mapn][j+1][i] == wall then 
				h = h - 1
			end
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


function gen_money(mapn)
	local i, j, k
	local x, y, pnt
	local loc = {}
	for i = 1, game.mapw do
		for j = 1, game.maph do
			if game.map[mapn][j][i] == floor then
				table.insert(loc, {x=i, y=j})
			end
		end
	end

	k = math.random(1, #loc)
	x = loc[k].x*game.ts
	y = loc[k].y*game.ts 
	pnt = math.random(player.score_min*game.mapn, player.score_max*game.mapn)
	table.insert(items, {nil, nil, "MONEY", x, y, pnt})
end

function gen_strdwn(mapn)
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
	dwndoor.x = loc[k].x*game.ts
	dwndoor.y = loc[k].y*game.ts
end

function gen_prpk(mapn)
	local i, j, k
	local x, y, pwr
	local loc = {}
	for i = 1, game.mapw do
		for j = 1, game.maph do
			if game.map[mapn][j][i] == floor then
				table.insert(loc, {x=i, y=j})
			end
		end
	end

	k = math.random(1, #loc)
	x = loc[k].x*game.ts
	y = loc[k].y*game.ts 
	pwr = math.random(player.power_min*game.mapn, player.power_max*game.mapn)
	table.insert(items, {"Powerpack x2000 (tm)", nil, "POWER", x, y, pwr})
end

function get_mast(mapn)
	local e_max = 3*mapn
	local e_min = 1*mapn
	local e = math.random(e_min, e_max)
	local m_max = 3*mapn
	local m_min = 1*mapn
	local m = math.random(m_min, m_max)
	local pp = math.random(0, 2)
	gen_map(mapn)
	gen_player(mapn)
	while e > 0 do
		gen_ai(mapn)
		e = e - 1
	end
	while m > 0 do
		gen_money(mapn)
		m = m - 1
	end
	if pp == 1 then
		gen_prpk(mapn)
	end
	gen_strdwn(mapn)
end