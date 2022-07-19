
local modpath = minetest.get_modpath("home_point")

home_point = {}
home_point.version = "2.1"

home_point.storage = minetest.get_mod_storage()
home_point.temp = {} -- Used to track who has what waypoints set for what homes

-- Actually it's our api so if someone else wanted to monkey with points they can
dofile(modpath..DIR_DELIM.."store_base.lua")

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

home_point.color = {
    white = 0xffffff,
    black = 0x000000,
    red = 0xc80000,
    green = 0x00c800,
    blue = 0x0055ff, -- Lightened some so it's better visably
    cyan = 0x00c8ff,
    magenta = 0xc800c8, -- purple
    yellow = 0xc8c800,
    brown = 0x966400,
    orange = 0xff9600,
}
home_point.color.purple = home_point.color.magenta

dofile(modpath..DIR_DELIM.."settings.lua")

-- Adds a tracker api so we can identify if someone moved or not, else requests go thru
-- This also allows the player to change their teleport destination while waiting (will/should reset timer)
dofile(modpath..DIR_DELIM.."tracker.lua")

minetest.register_privilege("home_point", {
    description = "Gives access to home point commands",
    give_to_singleplayer = true -- This should mean in singleplayer you start off with the defaults
})

minetest.register_privilege("home_point_basic", {
    description = "Gives access upto "..tostring(home_point.home_point_basic).." homes",
    give_to_singleplayer = true -- This should mean in singleplayer you start off with the defaults
})
minetest.register_privilege("home_point_advanced", {
    description = "Gives access upto "..tostring(home_point.home_point_advanced).." homes",
    give_to_singleplayer = false
})
minetest.register_privilege("home_point_super", {
    description = "Gives access upto "..tostring(home_point.home_point_super).." homes",
    give_to_singleplayer = false
})
minetest.register_privilege("home_point_unlimited", {
    description= "Gives access to unlimited homes",
    give_to_singleplayer = false
})

-- Set home
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
        -- Ensure we stop users from placing unlimited homes when they are not allowed to
        local homes = home_point.count(name)
        if not minetest.check_player_privs(name, {home_point_unlimited=true}) then
            if minetest.check_player_privs(name, {home_point_super=true}) then
                if homes+1 > home_point.home_point_super  then
                    return false, "You can only have "..tostring(home_point.home_point_super).." homes, currently you have "..tostring(homes).."."
                end
            elseif minetest.check_player_privs(name, {home_point_advanced=true}) then
                if homes+1 > home_point.home_point_basic then
                    return false, "You can only have "..tostring(home_point.home_point_advanced).." homes, currently you have "..tostring(homes).."."
                end
            elseif minetest.check_player_privs(name, {home_point_basic=true}) then
                if homes+1 > home_point.home_point_basic  then
                    return false, "You can only have "..tostring(home_point.home_point_basic).." homes, currently you have "..tostring(homes).."."
                end
            else
                return false, "You appear to not have access to place any homes, You need home_point and one of these (home_point_basic, home_point_advanced, home_point_super, or home_point_unlimited)."
            end
        end
        -- Setup the place/home
        local place = string.match(param, "^([%a%d_-]+)") or ""
        if place ~= "" then
            minetest.log("action", "[home_point] "..name.." saves a point as '"..place.."'")
            local rc = home_point.save(name, place)
            -- Update a waypoints position if we are showing that home
            local is_way = home_point.waypoint_is(name, place)
            if is_way.success == true and is_way.value ~= -1 then
                local pl = home_point.place_waypoint(name, place, is_way.value.color)
                if pl.success ~= true then
                    minetest.log("action", "[home_point] Err="..pl.errmsg.." Val="..minetest.serialize(pl.value))
                end
                pl = home_point.place_waypoint(name, place, is_way.value.color)
                if pl.success ~= true then
                    minetest.log("action", "[home_point] Err="..pl.errmsg.." Val="..minetest.serialize(pl.value))
                end
            else
                minetest.log("action", "[home_point] Err="..is_way.errmsg.." Val="..minetest.serialize(is_way.value))
            end
            return rc, "Saved as "..place
        else
            minetest.log("action", "[home_point] "..name.." saves a point as '"..name.."'")
            local rc = home_point.save(name, name)
            -- Update a waypoints position if we are showing that home
            local is_way = home_point.waypoint_is(name, name)
            if is_way.success == true and is_way.value ~= -1 then
                local pl = home_point.place_waypoint(name, name, is_way.value.color)
                if pl.success ~= true then
                    minetest.log("action", "[home_point] Err="..pl.errmsg.." Val="..minetest.serialize(pl.value))
                end
                pl = home_point.place_waypoint(name, name, is_way.value.color)
                if pl.success ~= true then
                    minetest.log("action", "[home_point] Err="..pl.errmsg.." Val="..minetest.serialize(pl.value))
                end
            else
                minetest.log("action", "[home_point] Err="..is_way.errmsg.." Val="..minetest.serialize(is_way.value))
            end
            return rc, "Saved as "..name
        end
        return false, "Uable to determine place_name"
    end,
})

-- Home (Go home)
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
            --minetest.chat_send_player(name, "Teleported to "..place)
        else
            target = home_point.get(name, name)
            minetest.log("action", "[home_point] "..name.." teleports to '"..name.."'")
            --minetest.chat_send_player(name, "Teleported to "..name)
        end
        if target ~= "" then
            local p = minetest.get_player_by_name(name)
            local pos = target.split(target, " ")
            home_point.players[name].request = {x=tonumber(pos[1]), y=tonumber(pos[2]), z=tonumber(pos[3])} -- Queue up teleport
            minetest.chat_send_player(name, "Teleporting to "..name.." in "..tostring(home_point.getJumpSpeed(name)).." seconds (Don't move)")
            -- In 5 seconds left we show countdown
        else
            minetest.log("action", "[home_point] Failed to obtain place_name '"..place.."'")
            return false, "Invalid place_name or you have no home points, try /sh (place_name)"
        end
    end,
})

-- Remove home
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
        local resp = ""
        if place ~= "" then
            minetest.log("action", "[home_point] "..name.." removes home of '"..place.."'")
            --minetest.chat_send_player(name, ""..place.." removed")
            resp = place.." removed"
            -- Remove waypoints from deleted homes
            local is_way = home_point.waypoint_is(name, place)
            if is_way.success and is_way.value ~= -1 then
                home_point.place_waypoint(name, place, home_point.color.black)
                local place_way = home_point.place_waypoint(name, place, home_point.color.black)
                if place_way.success == true then
                    minetest.log("action", "[home_point] "..name.." removed waypoint at '"..place.."'")
                else
                    minetest.log("action", "[home_point] Err="..place_way.errmsg.." Val="..minetest.serialize(place_way.value))
                end
            end
            local target = home_point.get(name, place)
            local pos = target.split(target, " ") -- Remove teleport dest if we've removed home homepoint
            if home_point.players[name].request == {x=tonumber(pos[1]), y=tonumber(pos[2]), z=tonumber(pos[3])} then
                home_point.players[name].request = nil
                minetest.chat_send_player(name, "Teleport Canceled, Removed Home!")
            end
            if home_point.remove(name, place) then
                minetest.chat_send_player(name, resp)
            end
        else
            minetest.log("action", "[home_point] "..name.." removes home of '"..name.."'")
            --minetest.chat_send_player(name, ""..name.." removed")
            resp = name.." removed"
            -- Remove waypoints from deleted homes
            local is_way = home_point.waypoint_is(name, name)
            if is_way.success and is_way.value ~= -1 then
                home_point.place_waypoint(name, place, home_point.color.black)
                local place_way = home_point.place_waypoint(name, name, home_point.color.black)
                if place_way.success == true then
                    minetest.log("action", "[home_point] "..name.." removed waypoint at '"..name.."'")
                else
                    minetest.log("action", "[home_point] Err="..place_way.errmsg.." Val="..minetest.serialize(place_way.value))
                end
            end
            local target = home_point.get(name, name)
            local pos = target.split(target, " ") -- Remove teleport dest if we've removed home homepoint
            if home_point.players[name].request == {x=tonumber(pos[1]), y=tonumber(pos[2]), z=tonumber(pos[3])} then
                home_point.players[name].request = nil
                minetest.chat_send_player(name, "Teleport Canceled, Removed Home!")
            end
            if home_point.remove(name, name) then
                minetest.chat_send_player(name, resp)
            end
        end
    end,
})

-- List homes
minetest.register_chatcommand("lh", {
    privs = {
        home_point = true
    },
    description = "Lists all home points for you",
    func = function(name)
        -- Don't allow offline players
        if name ~= "singleplayer" then
            if minetest.get_player_by_name(name) == nil then return false, "You must be online to use this command" end
        end
        local list = home_point.list(name)
        if list ~= nil and home_point.count(name) ~= 0 then
            --minetest.log("action", "[home_point] "..type(list).." "..minetest.serialize(list).." "..tostring(#list))
            local r = "Homes: " .. tostring(home_point.count(name)) .. "\n"
            for k in pairs(list) do
                local pos = list[k].split(list[k], " ")
                local is_way = home_point.waypoint_is(name, k)
                if is_way.success == false then
                    minetest.log("action", "[home_point] Err="..is_way.errmsg.." Val="..minetest.serialize(is_way.value))
                end
                -- Add a * to the end if we are showing that home with a waypoint
                if is_way.success == true and is_way.value ~= -1 then
                    r = r .. "  " .. k .. " (" .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ") *\n"
                else
                    r = r .. "  " .. k .. " (" .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ")\n"
                end
            end
            return true, r
        else
            minetest.chat_send_player(name, "You don't have any homes yet, use /sh <home_name> to place a home.")
        end
    end,
})

-- Toggle waypoint on home
minetest.register_chatcommand("wh", {
    privs = {
        home_point = true
    },
    description = "Toggles a waypoint at a home point",
    func = function (name, param)
        -- Don't allow offline players
        if name ~= "singleplayer" then
            if minetest.get_player_by_name(name) == nil then return false, "You must be online to use this command" end
        end
        local parts = home_point.split(param, " ")
        --minetest.log("action", minetest.serialize(parts))
        local place = ""
        local color = "white"
        if #parts >= 1 then
            place = string.match(parts[1], "^([%a%d_-]+)") or ""
            --minetest.log("action", "place='"..place.."'")
        end
        if #parts >= 2 then
            color = string.match(parts[2], "^([%a%d_-]+)") or "white"
            --minetest.log("action", "color='"..color.."'")
        end
        -- Check that the color is a valid color that's been converted to HEX
        color = string.lower(color)
        for c, hex in pairs(home_point.color) do
            if c == color then
                color = hex
                break
            end
        end
        if home_point.count(name) ~= 0 then
            if place ~= "" then
                if home_point.get(name, place) ~= "" then
                    local rc = home_point.place_waypoint(name, place, color)
                    if rc.success == true then
                            minetest.log("action", "[home_point] "..name.." "..rc.errmsg.." at "..place.." '"..home_point.get(name, place).."'")
                            minetest.chat_send_player(name, rc.errmsg.." at "..place)
                    else
                            minetest.log("action", "[home_point] Err="..rc.errmsg.." Val="..minetest.serialize(rc.value))
                    end
                else
                    minetest.chat_send_player(name, "No such home point "..place)
                end
            else
                if home_point.get(name, name) ~= "" then
                    local rc = home_point.place_waypoint(name, name, color)
                    if rc.success == true then
                            minetest.log("action", "[home_point] "..name.." "..rc.errmsg.." at "..name.." '"..home_point.get(name, name).."'")
                            minetest.chat_send_player(name, rc.errmsg.." at "..name)
                    else
                            minetest.log("action", "[home_point] Err="..rc.errmsg.." Val="..minetest.serialize(rc.value))
                    end
                end
            end
        else
            minetest.chat_send_player(name, "You don't have any homes yet, use /sh <home_name> to place a home.")
        end
    end
})

minetest.log("action", "[home_point] Version: "..home_point.version)
