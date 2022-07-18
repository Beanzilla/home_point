
home_point.home_point_basic = minetest.settings:get("home_point.home_point_basic")
if home_point.home_point_basic == nil then
    home_point.home_point_basic = 2
    minetest.settings:set("home_point.home_point_basic", 2)
else
    home_point.home_point_basic = tonumber(home_point.home_point_basic)
end

home_point.home_point_basic_jump_speed = minetest.settings:get('home_point.home_point_basic_jump_speed')
if home_point.home_point_basic_jump_speed == nil then
    home_point.home_point_basic_jump_speed = 15
    minetest.settings:set('home_point.home_point_basic_jump_speed', 15)
else
    home_point.home_point_basic_jump_speed = tonumber(home_point.home_point_basic_jump_speed)
end

home_point.home_point_advanced = minetest.settings:get("home_point.home_point_advanced")
if home_point.home_point_advanced == nil then
    home_point.home_point_advanced = 4
    minetest.settings:set("home_point.home_point_advanced", 4)
else
    home_point.home_point_advanced = tonumber(home_point.home_point_advanced)
end

home_point.home_point_advanced_jump_speed = minetest.settings:get('home_point.home_point_advanced_jump_speed')
if home_point.home_point_advanced_jump_speed == nil then
    home_point.home_point_advanced_jump_speed = 10
    minetest.settings:set('home_point.home_point_advanced_jump_speed', 10)
else
    home_point.home_point_advanced_jump_speed = tonumber(home_point.home_point_advanced_jump_speed)
end

home_point.home_point_super = minetest.settings:get("home_point.home_point_super")
if home_point.home_point_super == nil then
    home_point.home_point_super = 8
    minetest.settings:set("home_point.home_point_super", 8)
else
    home_point.home_point_super = tonumber(home_point.home_point_super)
end

home_point.home_point_super_jump_speed = minetest.settings:get('home_point.home_point_super_jump_speed')
if home_point.home_point_super_jump_speed == nil then
    home_point.home_point_super_jump_speed = 7
    minetest.settings:set('home_point.home_point_super_jump_speed', 7)
else
    home_point.home_point_super_jump_speed = tonumber(home_point.home_point_super_jump_speed)
end
