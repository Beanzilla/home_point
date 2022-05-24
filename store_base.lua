
-- Saves the players current position as place_name (for multiple home support)
-- Returns if the save was successfull
function home_point.save(pname, place_name)
    local p = minetest.get_player_by_name(pname) or nil
    -- If the player really is a player
    if p ~= nil then
        -- Get their position and convert it to string
        local pos = vector.round(p:get_pos())
        pos = "".. pos.x .." ".. pos.y+1 .." ".. pos.z
        -- Obtain the player's homes update/insert then update the mods storage
        local tmp = minetest.deserialize(home_point.storage:get_string(pname)) or {}
        tmp[place_name] = pos
        home_point.storage:set_string(pname, minetest.serialize(tmp))
        return true
    end
    return false
end

-- Gets the players home given it's place_name
-- Returns either "x y z" or an empty string to indicate success or not
function home_point.get(pname, place_name)
    local p = minetest.get_player_by_name(pname) or nil
    -- If the player really is a player
    if p ~= nil then
        -- Obtain the player's homes then looks for a place called place_name
        local tmp = minetest.deserialize(home_point.storage:get_string(pname))
        if tmp ~= nil then
            for k in pairs(tmp) do
                if k == place_name then
                    -- Found it, so return it's "x y z"
                    return tmp[k]
                end
            end
        end
    end
    -- Else return something clear to indicate fail
    return ""
end

-- Removes the location by name
function home_point.remove(pname, place_name)
    local p = minetest.get_player_by_name(pname) or nil
    if p ~= nil then
        local tmp = minetest.deserialize(home_point.storage:get_string(pname))
        if tmp ~= nil then
            -- Make a new table and add all except selected place
            local new = {}
            local found = false
            for k in pairs(tmp) do
                if k ~= place_name then
                    new[k] = tmp[k]
                else
                    found = true
                end
            end
            home_point.storage:set_string(pname, minetest.serialize(new))
            return found
        end
    end
    return false
end

-- Returns list of home and position for a player
function home_point.list(pname)
    local p = minetest.get_player_by_name(pname) or nil
    if p ~= nil then
        return minetest.deserialize(home_point.storage:get_string(pname))
    end
    return {}
end

-- Returns the actual count/number of homes
function home_point.count(pname)
    local home_count = 0
    local p = minetest.get_player_by_name(pname) or nil
    if p ~= nil then
        local list = home_point.list(pname)
        if list ~= nil then
            for k in pairs(list) do
                home_count = home_count + 1
            end
        end
    end
    return home_count
end

-- Waypoints are temporary, as in when the user quits/logs out I need to clear them from the temp list

-- Do we have a waypoint hud id for the given home point?
function home_point.waypoint_is(pname, home)
    if home_point.get(pname, home) ~= "" then
        local waypoints = home_point.temp[pname] or {}
        --minetest.log("action", "94 ".. minetest.serialize(waypoints))
        for name, way in pairs(waypoints) do
            --minetest.log("action", "96 ".. minetest.serialize(way))
            if name == home then
                return {success=true, errmsg="", value=way}
            end
        end
        return {success=true, errmsg="Home point '"..home.."' doesn't have a waypoint set.", value=-1}
    else
        return {success=false, errmsg="No such home point '"..home.."'.", value=nil}
    end
end

-- Adds the given hud id to the given home point
function home_point.waypoint_add(pname, home, hud_id, hex)
    if home_point.get(pname, home) ~= "" then
        local waypoints = home_point.temp[pname] or {}
        local tab = {}
        tab.hud = hud_id
        tab.color = hex
        waypoints[home] = tab
        home_point.temp[pname] = waypoints
        return {success=true, errmsg="", value=tab}
    else
        return {success=false, errmsg="No such home point '"..home.."'", value=nil}
    end
end

function home_point.waypoint_remove(pname, home)
    if home_point.get(pname, home) ~= "" then
        local waypoints = home_point.temp[pname] or {}
        local new_waypoints = {}
        --minetest.log("action", "128 ".. minetest.serialize(waypoints))
        for name, way in pairs(waypoints) do
            --minetest.log("action", "130 ".. minetest.serialize(way))
            if name ~= home then
                local tab = {}
                tab.hud = way.hud
                tab.color = way.color
                new_waypoints[name] = tab
            end
        end
        home_point.temp[pname] = new_waypoints
        return {success=true, errmsg="", value=nil}
    else
        return {success=false, errmsg="No such home point '"..home.."'", value=nil}
    end
end

function home_point.place_waypoint(pname, home, hex)
    if home_point.get(pname, home) ~= "" then
        -- Obtain the actual pos
        local raw_pos = home_point.split(home_point.get(pname, home), " ")
        local pos = {x=tonumber(raw_pos[1]), y=tonumber(raw_pos[2]), z=tonumber(raw_pos[3])}
        local player = minetest.get_player_by_name(pname)
        -- Clean up hex / have backup incase hex isn't HEX but something else
        local h = hex
        if type(hex) ~= "number" then
            h = 0xc80000
            minetest.chat_send_player(pname, "Invalid color option '"..tostring(hex).."'.")
            return {success=false, errmsg="Invalid color option '"..tostring(hex).."'.", value=nil}
        end

        local is_way = home_point.waypoint_is(pname, home)
        -- This will need to chance
        if is_way.success == true then
            if is_way.value ~= -1 then
                if is_way.value.color ~= h then
                    -- Change instead
                    player:hud_change(is_way.value.hud, "number", tostring(h))
                    minetest.log("action", "164 "..minetest.serialize(home_point.temp[pname][home]))
                    home_point.temp[pname][home].color = h
                    return {success=true, errmsg="Changed color of waypoint", value=nil}
                else
                    -- Remove
                    local rm = home_point.waypoint_remove(pname, home)
                    if rm.success ~= true then
                        return {success=false, errmsg="home_point.waypoint_remove returned error", value=rm}
                    else
                        player:hud_remove(is_way.value.hud)
                        return {success=true, errmsg="Removed waypoint", value=nil}
                    end
                end
            else
                -- Add
                local add = home_point.waypoint_add(pname, home, player:hud_add({
                    hud_elem_type = "waypoint",
                    world_pos = vector.subtract(pos, {x=0, y=1, z=0}),
                    name = home,
                    number = h
                }), h)
                if add.success ~= true then
                    return {success=false, errmsg="home_point.waypoint_add returned error", value=add}
                else
                    return {success=true, errmsg="Created waypoint", value=add.value}
                end
            end
        else
            return {success=false, errmsg="home_point.waypoint_is returned error", value=is_way}
        end
    else
       return {success=false, errmsg="No such home point '"..home.."'", value=nil}
    end
end

-- Clean up waypoints from players who are logged off
minetest.register_on_leaveplayer(function(player)
    local pname = player:get_player_name()
    if home_point.temp[pname] ~= nil then
        local new = {}
        for name, tab in pairs(home_point.temp) do
            if name ~= pname then
                new[name] = tab
            end
        end
        home_point.temp = new
    end
end)
