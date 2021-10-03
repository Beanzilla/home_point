
local modpath = minetest.get_modpath("home_point")

home_point = {}

home_point.storage = minetest.get_mod_storage()

-- Actually it's our api so if someone else wanted to monkey with points they can
dofile(modpath.."/store_base.lua")

-- Assistants
function home_point.firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function home_point.split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

minetest.register_privilege("home_point", "Gives access to /sh and /h from home point")

minetest.register_chatcommand("sh", {
    privs = {
        home_point = true
    },
    description = "Sets a home point given /sh (place_name)",
    func = function(name, param)
        -- Don't allow players who aren't online
        if name ~= "singleplayer" then
            if minetest.get_player_by_name(name) == nil then return false, "You must be online to use this command" end
        end
        local place = string.match(param, "^([%a%d_-]+)") or ""
        if place ~= "" then
            minetest.log("action", "[home_point] "..name.." saves a point as '"..place.."'")
            return home_point.save(name, place), "Saved as "..place
        else
            minetest.log("action", "[home_point] "..name.." saves a point as '"..name.."'")
            return home_point.save(name, name), "Saved as "..name
        end
        return false, "Uable to determine place_name"
    end,
})

minetest.register_chatcommand("h", {
    privs = {
        home_point = true
    },
    description = "Goes to a home point given /h (place_name)",
    func = function(name, param)
        -- Don't allow players who aren't online
        if name ~= "singleplayer" then
            if minetest.get_player_by_name(name) == nil then return false, "You must be online to use this command" end
        end
        local place = string.match(param, "^([%a%d_-]+)") or ""
        local target = nil
        if place ~= "" then
            target = home_point.get(name, place)
            minetest.log("action", "[home_point] "..name.." teleports to '"..place.."'")
            minetest.chat_send_player(name, "Teleported to "..place)
        else
            target = home_point.get(name, name)
            minetest.log("action", "[home_point] "..name.." teleports to '"..name.."'")
            minetest.chat_send_player(name, "Teleported to "..name)
        end
        if target ~= "" then
            local p = minetest.get_player_by_name(name)
            local pos = target.split(target, " ")
            p:set_pos({x=tonumber(pos[1]), y=tonumber(pos[2]), z=tonumber(pos[3])})
        else
            minetest.log("action", "[home_point] Failed to obtain place_name '"..place.."'")
            return false, "Invalid place_name or you have no home points, try /sh (place_name)"
        end
    end,
})

minetest.register_chatcommand("rh", {
    privs = {
        home_point = true
    },
    description = "Remvoes a home point given /rh (place_name)",
    func = function(name, param)
                -- Don't allow players who aren't online
        if name ~= "singleplayer" then
            if minetest.get_player_by_name(name) == nil then return false, "You must be online to use this command" end
        end
        local place = string.match(param, "^([%a%d_-]+)") or ""
        local target = nil
        if place ~= "" then
            home_point.remove(name, place)
            minetest.log("action", "[home_point] "..name.." removes home of '"..place.."'")
            minetest.chat_send_player(name, ""..place.." removed")
        else
            home_point.remove(name, name)
            minetest.log("action", "[home_point] "..name.." removes home of '"..name.."'")
            minetest.chat_send_player(name, ""..name.." removed")
        end
    end,
})

minetest.log("action", "[home_point] Ready")