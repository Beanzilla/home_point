
-- Saves the players current position as place_name (for multiple home support)
-- Returns if the save was successfull
function home_point.save(pname, place_name)
    local p = minetest.get_player_by_name(pname) or nil
    -- If the player really is a player
    if p ~= nil then
        -- Get their position and convert it to string
        local pos = p:get_pos()
        pos = "".. math.floor(pos.x) .." ".. math.floor(pos.y+1) .." ".. math.floor(pos.z)
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
            for k in pairs(tmp) do
                if k ~= place_name then
                    new[k] = tmp[k]
                end
            end
            home_point.storage:set_string(pname, minetest.serialize(new))
        end
    end
end

-- Returns list of home and position for a player
function home_point.list(pname)
    local p = minetest.get_player_by_name(pname) or nil
    if p ~= nil then
        return minetest.deserialize(home_point.storage:get_string(pname))
    end
end
