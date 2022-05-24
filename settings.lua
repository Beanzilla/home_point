
home_point.home_point_basic = minetest.settings:get("home_point.home_point_basic")
if home_point.home_point_basic == nil then
    home_point.home_point_basic = 2
    minetest.settings:set("home_point.home_point_basic", 2)
else
    home_point.home_point_basic = tonumber(home_point.home_point_basic)
end

home_point.home_point_advanced = minetest.settings:get("home_point.home_point_advanced")
if home_point.home_point_advanced == nil then
    home_point.home_point_advanced = 4
    minetest.settings:set("home_point.home_point_advanced", 4)
else
    home_point.home_point_advanced = tonumber(home_point.home_point_advanced)
end

home_point.home_point_super = minetest.settings:get("home_point.home_point_super")
if home_point.home_point_super == nil then
    home_point.home_point_super = 8
    minetest.settings:set("home_point.home_point_super", 8)
else
    home_point.home_point_super = tonumber(home_point.home_point_super)
end

