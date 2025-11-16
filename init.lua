-- leaf_particles/init.lua


-- Namespace
leaf_particles = {}

local scan_box = vector.new(32, 8, 32)
local velmin = vector.new(0, 0, 0)
local velmax = vector.new(0, 0, 0)
local accmin = vector.new(-1, -2, -1)
local accmax = vector.new(1, -2, 1)


-- Spawn particles
function leaf_particles.spawn_particles()
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
				posmin = vector.offset(lpos_below, -0.5, 0.8, -0.5)
				posmax = vector.offset(lpos_below,  0.5, 0.8,  0.5)
				
				minetest.add_particlespawner({
					amount = 1,
					time = 30,
					node = {name = lnode.name},
					collisiondetection = true,
					collision_removal = true,
					exptime = 15,
					playername = player_obj:get_player_name(),
					minpos = posmin,
					maxpos = posmax,
					pos = {min = posmin, max = posmax},
					mminvel = velmin,
					maxvel = velmax,
					vel = {min = velmin, max = velmax},
					minacc = accmin,
					maxacc = accmax,
					acc = {min = accmin, max = accmax}
				})
			end
		end
	end
end

-- Timer
function leaf_particles.timer(dtime)
	leaf_particles.elapsed = leaf_particles.elapsed + dtime
	if leaf_particles.elapsed > leaf_particles.interval then
		leaf_particles.spawn_particles()
		leaf_particles.interval = math.random(5,30)
		leaf_particles.elapsed = 0.0
	end
end

leaf_particles.interval = math.random(5,30)
leaf_particles.elapsed = 0.0

minetest.register_globalstep(function(dtime)
	leaf_particles.timer(dtime)
end)
