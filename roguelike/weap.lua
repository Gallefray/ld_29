
function mlaslow_weap(dir) -- mining laser low power
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
	add_stat("Zap!")
	add_stat("You hear the rock crumble.")
end

function mlasmid_nos()
	local k = math.random(0, 2)
	if k == 0 then
		add_stat("Zap!")
		add_stat("You hear the rock cave in.")
	elseif k == 1 then
		add_stat("Pew! Pew!")
		add_stat("You blast the rock out of the way!")
	elseif k == 2 then
		add_stat("Bzzzzzzzzssssshh")
		add_stat("You disintegrate the rock!")
	end
end

function mlasmid_weap(dir) -- mining laser low power
	local j = player.y/game.ts
	local i = player.x/game.ts
	if dir == "left" then
		if chk_tile(player.x, player.y, "left", wall) or 
		   chk_tile(player.x, player.y, "left", air) then
		     if game.map[game.mapn][j][i-2] == air then
		     	game.map[game.mapn][j][i-3] = wall
			 end
			 game.map[game.mapn][j][i-1] = floor
			 game.map[game.mapn][j][i-2] = floor
			 game.map[game.mapn][j-1][i-1] = wall
			 game.map[game.mapn][j+1][i-1] = wall
			 game.map[game.mapn][j-1][i-2] = wall
			 game.map[game.mapn][j+1][i-2] = wall
			 mlasmid_nos()
		else
			add_stat("The beam fizzles out in the air.")
		end
	elseif dir == "down" then
		if chk_tile(player.x, player.y, "down", wall) or 
		   chk_tile(player.x, player.y, "down", air) then
		    if game.map[game.mapn][j+2][i] == air then
		    	game.map[game.mapn][j+3][i] = wall
		    end
			game.map[game.mapn][j+1][i] = floor
			game.map[game.mapn][j+2][i] = floor
			game.map[game.mapn][j+2][i+1] = wall
			game.map[game.mapn][j+2][i-1] = wall
			game.map[game.mapn][j+1][i+1] = wall
			game.map[game.mapn][j+1][i-1] = wall
			mlasmid_nos()
		else
			add_stat("The beam fizzles out in the air.")
		end
	elseif dir == "up" then
		if chk_tile(player.x, player.y, "up", wall) or 
		   chk_tile(player.x, player.y, "up", air) then
		   	if game.map[game.mapn][j-2][i] == air then
				game.map[game.mapn][j-3][i] = wall
			end
			game.map[game.mapn][j-1][i] = floor
			game.map[game.mapn][j-2][i] = floor
			game.map[game.mapn][j-2][i-1] = wall
			game.map[game.mapn][j-2][i+1] = wall
			game.map[game.mapn][j-1][i-1] = wall
			game.map[game.mapn][j-1][i+1] = wall
			mlasmid_nos()
		else
			add_stat("The beam fizzles out in the air.")
		end
	elseif dir == "right" then
		if chk_tile(player.x, player.y, "right", wall) or
		   chk_tile(player.x, player.y, "right", air) then
		   	 if game.map[game.mapn][j][i+2] == air then
				game.map[game.mapn][j][i+3] = wall
			 end
			 game.map[game.mapn][j][i+1] = floor
			 game.map[game.mapn][j][i+2] = floor
			 game.map[game.mapn][j+1][i+1] = wall
			 game.map[game.mapn][j-1][i+1] = wall
			 game.map[game.mapn][j+1][i+2] = wall
			 game.map[game.mapn][j-1][i+2] = wall
			 mlasmid_nos()
		else
			add_stat("The beam fizzles out in the air.")
		end
	end

end

function fire_weap(dir)
	local i
	if player.wield == "MLASLOW" then
		mlaslow_weap(dir)
		player.primed = false
	elseif player.wield == "MLASMID" then
		mlasmid_weap(dir)
		player.primed = false
	elseif player.wield == "" then
		add_stat("Nothing to fire!")
		player.primed = false
	end
end