
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
				if regen == true then
					break
				end
			end
		end
		if x+w >= game.mapw or regen == true then
			x = math.random(min_rx, max_rx)
			w = math.random(min_rw, max_rw)
		end
		if y+h >= game.maph or regen == true then
			y = math.random(min_ry, max_ry)
			h = math.random(min_rh, max_rh)
		end
	end

	if x+w > game.mapw or y+h > game.maph or regen == true then
		-- print("Tried 11 times - Failed")
		return 0
	end

	-- check if the room is close to another one and space it out if it is
	-- y top, y bottom
	h = h - 2

	j = y
	for i = x, x+w do
		if game.map[mapn][j-1][i] == wall or game.map[mapn][j-1][i] == floor then
			y = y + 1
			if y+h > game.maph then
				h = h - 1
			end
		end
	end

	j = y+h
	for i = x, x+w do
		-- What is it with this line. Why does it occasionally throw up errors.
		-- Fixed due to the `h = h -2`, but I shouldn't need that line D:
		if game.map[mapn][j+1][i] == wall or game.map[mapn][j+1][i] == floor then
			h = h - 1
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