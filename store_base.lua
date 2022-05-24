
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
        --minetest.log("action", minetest.serialize(waypoints))
        for _, way in pairs(waypoints) do
            local way_name = way[1]
            local way_hid = way[2]
            --minetest.log("action", "[home_point.waypoint_is] way_name='"..way_name.."' way_hid="..tostring(way_hid))
            if way_name == home then
                return {success=true, errmsg="", value=way_hid}
            end
        end
        return {success=true, errmsg="Home point '"..home.."' doesn't have a waypoint set.", value=-1}
    else
        return {success=false, errmsg="No such home point '"..home.."'.", value=nil}
    end
end

-- Adds the given hud id to the given home point
function home_point.waypoint_add(pname, home, hud_id)
    if home_point.get(pname, home) ~= "" then
        local waypoints = home_point.temp[pname] or {}
        local tab = {}
        table.insert(tab, home)
        table.insert(tab, hud_id)
        table.insert(waypoints, tab)
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
        for _, way in pairs(waypoints) do
            local way_name = way[1]
            local way_hid = way[2]
            --minetest.log("action", "[home_point.waypoint_remove] way_name='"..way_name.."' way_hid="..tostring(way_hid))
            if way_name ~= home then
                local tab = {}
                table.insert(tab, way_name)
                table.insert(tab, way_hid)
                table.insert(new_waypoints, tab)
            end
        end
        home_point.temp[pname] = new_waypoints
        return {success=true, errmsg="", value=nil}
    else
        return {success=false, errmsg="No such home point '"..home.."'", value=nil}
    end
end

function home_point.place_waypoint(pname, home)
    if home_point.get(pname, home) ~= "" then
        -- Obtain the actual pos
        local raw_pos = home_point.split(home_point.get(pname, home), " ")
        local pos = {x=tonumber(raw_pos[1]), y=tonumber(raw_pos[2]), z=tonumber(raw_pos[3])}
        local player = minetest.get_player_by_name(pname)

        local is_way = home_point.waypoint_is(pname, home)
        if is_way.success == true then
            if is_way.value ~= -1 then
                -- Remove
                local rm = home_point.waypoint_remove(pname, home)
                if rm.success ~= true then
                    return {success=false, errmsg="home_point.waypoint_remove returned error", value=rm}
                else
                    player:hud_remove(is_way.value)
                    return {success=true, errmsg="Removed waypoint", value=nil}
                end
            else
                -- Add
                local add = home_point.waypoint_add(pname, home, player:hud_add({
                    hud_elem_type = "waypoint",
                    world_pos = vector.subtract(pos, {x=0, y=1, z=0}),
                    name = home,
                    number = 0x00c800
                }))
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
