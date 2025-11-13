-- leaf_particles/init.lua


-- Namespace
leaf_particles = {}
local scan_box = vector.new(32, 8, 32)


function leaf_particles.create_leaf_particles()
	for _,player_obj in pairs(core.get_connected_players()) do
		if (player_obj == nil) then break end
		local new_pos = player_obj:get_pos()
		local rounded_pos = vector.new(math.floor(new_pos["x"]), math.floor(new_pos["y"]), math.floor(new_pos["z"]))
		local blocks = minetest.find_nodes_in_area(rounded_pos - scan_box, rounded_pos + scan_box, "group:leaves")
		
		for _,lpos in pairs(blocks) do
			lnode = minetest.get_node(lpos)
			lpos_below = vector.offset(lpos, 0, -1, 0)
			lnode_below = minetest.get_node(lpos_below)
			if (lnode_below.name == "air") and (math.random(1,30) == 1) then
				minetest.add_particlespawner({
					amount = 1,
					time = 60,
					node = {name = lnode.name},
					object_collision = true,
					collisiondetection = true,
					collision_removal = true,
					exptime = 15,
					playername = player_obj:get_player_name(),
					minpos = vector.offset(lpos_below, -0.5, 0.45, -0.5),
					maxpos = vector.offset(lpos_below,  0.5, 0.4,  0.5),
					pos = {min = vector.offset(lpos_below, -0.5, 0.45, -0.5), max = vector.offset(lpos_below,  0.5, 0.4,  0.5)},
					minvel = vector.new(0, 0, 0),
					maxvel = vector.new(0, 0, 0),
					vel = {min = vector.new(0, 0, 0), max = vector.new(0, 0, 0)},
					minacc = {x = -1, y = -2, z = -1},
					maxacc = {x = 1, y = -2, z = 1},
					acc = {min = vector.new(-1, -2, -1), max = vector.new(1, -2, 1)}
				})
			end
		end
	end
end

function leaf_particles.timer(dtime)
	leaf_particles.elapsed = leaf_particles.elapsed + dtime
	if leaf_particles.elapsed > leaf_particles.interval then
		leaf_particles.create_leaf_particles()
		leaf_particles.interval = math.random(5,30)
		leaf_particles.elapsed = 0.0
	end
end

leaf_particles.interval = math.random(5,30)
leaf_particles.elapsed = 0.0

minetest.register_globalstep(function(dtime)
	leaf_particles.timer(dtime)
end)
