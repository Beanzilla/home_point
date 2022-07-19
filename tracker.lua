
local CHECK_INTERVAL = 1

home_point.players = {}
local checkTimer = 0

minetest.register_on_joinplayer(function (player)
    local name = player:get_player_name()
    home_point.players[name] = {
        lastAction = minetest.get_gametime(),
        request = nil
    }
end)

minetest.register_on_leaveplayer(function (player)
    local name = player:get_player_name()
    home_point.players[name] = nil
end)

--[[minetest.register_on_chat_message(function (name, msg)
    if home_point.players[name] then
        home_point.players[name].lastAction = minetest.get_gametime()
        minetest.log("action", "[home_point] "..name.." chatted")
    end
end)]]

minetest.register_on_punchplayer(function (player, hitter)
    local name = player:get_player_name()
    local hit = hitter:get_player_name()
    if home_point.players[name] then
        home_point.players[name].lastAction = minetest.get_gametime()
        if home_point.players[name].request then
            home_point.players[name].request = nil
            minetest.chat_send_player(name, "Teleport Canceled, PVP!")
        end
    end
    if home_point.players[hit] then
        home_point.players[hit].lastAction = minetest.get_gametime()
        if home_point.players[hit].request then
            home_point.players[hit].request = nil
            minetest.chat_send_player(hit, "Teleport Canceled, PVP!")
        end
    end
end)

home_point.getJumpSpeed = function (name)
    if minetest.check_player_privs(name, {home_point_unlimited=true}) then
        return home_point.home_point_unlimited_jump_speed
    elseif minetest.check_player_privs(name, {home_point_super=true}) then
        return home_point.home_point_super_jump_speed
    elseif minetest.check_player_privs(name, {home_point_advanced=true}) then
        return home_point.home_point_advanced_jump_speed
    else -- Covers basic and having none of these privs (but basic or higher is required anyway)
        return home_point.home_point_basic_jump_speed
    end
end

local questionTeleport = function (player, name, info, curTime)
    --minetest.log("action", "[home_point] "..tostring(info.lastAction+home_point.getJumpSpeed(name)).." <= " .. tostring(curTime) .. " = " .. tostring(info.lastAction+home_point.getJumpSpeed(name) <= curTime))
    if info.lastAction + home_point.getJumpSpeed(name) <= curTime then
        -- Teleport
        if info.request then
            player:set_pos(info.request)
            info.request = nil
            minetest.chat_send_player(name, "Teleported")
        end
    else
        if info.request then
            local diff = info.lastAction+home_point.getJumpSpeed(name) - curTime
            if diff <= 5 then
                minetest.chat_send_player(name, "Teleporting in "..tostring(diff)..".")
            end
        end
    end
end

minetest.register_globalstep(function (dtime)
    local curTime = minetest.get_gametime()
    checkTimer = checkTimer + dtime

    local checkNow = checkTimer >= CHECK_INTERVAL
    if checkNow then
        checkTimer = checkTimer - CHECK_INTERVAL
    end

    for name, info in pairs(home_point.players) do
        local player = minetest.get_player_by_name(name)
        if player then
            for _, keyPress in pairs(player:get_player_control()) do
                if keyPress then
                    info.lastAction = curTime
                    if info.request then
                        info.request = nil
                        minetest.chat_send_player(name, "Teleport Canceled, you moved!")
                    end
                end
            end

            if checkNow then
                questionTeleport(player, name, info, curTime)
            end
        else -- Clean up invalids
            players[name] = nil
        end
    end
end)
