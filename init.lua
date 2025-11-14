-- leaf_particles/init.lua


-- Namespace
leaf_particles = {}

local velmin = vector.new(0, 0, 0)
local velmax = vector.new(0, 0, 0)
local accmin = vector.new(-1, -2, -1)
local accmax = vector.new(1, -2, 1)


-- Spawn particles
function leaf_particles.spawn_particles(pos, node)
	-- Block below needs to be air.
	local below = vector.offset(pos, 0, -1, 0)
	if not core.get_node(below).name == "air" then
		return
	end
	
	posmin = vector.offset(below, -0.5, 0.8, -0.5)
	posmax = vector.offset(below,  0.5, 0.8,  0.5)
	
	minetest.add_particlespawner({
		amount = 1,
		time = 30,
		node = {name = node.name},
		collisiondetection = true,
		collision_removal = true,
		exptime = 15,
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

core.register_abm({
	label = "Spawn leaf particles",
	nodenames = {"group:leaves"},
	neighbors = {"air", "group:leaves"},
	interval = 30,
	chance = 20,
	action = function(...)
		leaf_particles.spawn_particles(...)
	end,
})
