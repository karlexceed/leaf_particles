-- leaf_particles/init.lua

local wind_mod = dofile(core.get_modpath('breasy') .. '/init.lua')

local leaf_speed = 0.3
local leaf_velocity = vector.new(0, -0.6, 0)
local scan_box = vector.new(32, 8, 32)
local update_distance = 4
local gravity = vector.new(0,-0.5, 0)

local spawn_interval = 20
local particles_per_interval = 2
local player_cache = {}

local function get_player_cache(player)
    local name = player:get_player_name()
    player_cache[name] = player_cache[name] or {}
    return player_cache[name]
end

local function update_leaf_cache()
    for _, player in ipairs(core.get_connected_players()) do
        local pos = player:get_pos()
        local rounded = vector.new(math.floor(pos.x), math.floor(pos.y), math.floor(pos.z))
        local cache = get_player_cache(player)

        if not cache.last_pos or vector.distance(cache.last_pos, rounded) >= update_distance then
            cache.last_pos = rounded
            cache.leaves = core.find_nodes_in_area(
                vector.subtract(rounded, scan_box),
                vector.add(rounded, scan_box),
                {"group:leaves", "group:floar", "group:grass"},
                true -- grouped makes it so no get_node_or_nil calls are necessary.
            )
        end
    end
end

local function pick_random(items, amount)
    local r = {}
    for i = 1, amount do
        table.insert(r, items[math.random(0, #items)])
    end
    return r
end

local function spawn_particles()
    update_leaf_cache()

    for _, player in ipairs(core.get_connected_players()) do
        local cache = get_player_cache(player)
        if not cache.leaves then goto continue end

        local spawn_ratio = vector.length(wind_mod.get_wind(cache.last_pos)) / 4

        for node_name, positions in pairs(cache.leaves) do
        for _, lpos in ipairs(pick_random(positions, #positions * spawn_ratio)) do
            local posmin = vector.offset(lpos, -0.5, 0, -0.5)
            local posmax = vector.offset(lpos,  0.5, 0,  0.5)

            -- wind-based velocity and acceleration
            local w = wind_mod.get_wind(lpos)
            local vel = w:add(leaf_velocity, 0.4)

            -- increase jitter if windspeed is higher.
            -- local ws = math.min(1, vector.length(w) * 16)
            local jitter = {min = {x=-8,y=-8,z=-8}, max ={x=8,y=8,z=8}, bias = 0},

            core.add_particlespawner({
                size = 0.5,
                amount = particles_per_interval,
                alpha = 0.1,
                time = spawn_interval,
                node = { name = node_name },
                playername = player:get_player_name(),
                exptime = 15,
                minpos = posmin,
                maxpos = posmax,
                pos = {min = posmin, max = posmax},
                jitter = jitter,
                vel = vel,
                acc = w:add(gravity, 0.8),
            })
        end
        end

        ::continue::
    end

    core.after(spawn_interval, spawn_particles)
end

core.after(0, spawn_particles)
