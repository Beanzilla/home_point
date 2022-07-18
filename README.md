# Home Point

A multi homes teleport feature.

## Commands

All commands require `home_point` privilege (And `/sh` needs one of the further privileges, See Limiting homes section below)

* `/h (place_name)` Goes to a place called place_name unless not given then your player name is used.
* `/sh (place_name)` Saves a place called place_name unless not given then your player name is used.
* `/rh (place_name)` Removes a place called place_name unless not given then your player name is used.
* `/lh` Lists all your homes, if you don't have any it will tell you how to make one.
* `/wh (place_name)` Places a waypoint at the designated home till you log-out/quit, if place_name not given then your player name is used.

> `/wh` actually toggles a waypoint, and when `/sh` is used with the same home as a waypoint a new waypoint will be place at the new location. (Also when `/rh` is used on a home with a waypoint the waypoint will be removed)

## Telport Delay Feature

In Version 2.0 home_point can now telport after a delay, if a player is punched or moves the telport is canceled.

> There are also 3 new settings you can modify to define teleportation delays (see Limiting Homes section below)

## Colored Waypoints

Don't like the waypoints being white?

Just use `/wh place_name color` to change it. (This means you need to enter your player name if you want to change that waypoint color)

> Note, selecting the same color will cause it to be removed now (so if you changed it from white you will need to either type in the color you used or enter `/wh place_name` twice, once to change to white and the second time to remove it)

Supported colors:

* White
* Black
* Blue
* Red
* Orange
* Yellow
* Magenta or Purple
* Brown
* Green

## Notice

This mod uses mod storage... this means if the server crashes the mod could lose a few home points.

## Limiting homes

There are 4 default privileges which are defined in settings.

All these do is limit the number of home_points players can set. (And in v2.0 it also limits the speed at which players will be teleported)

> (For servers) This means you need to add `home_point` and at least `home_point_basic` to your default_privs in minetest.conf,
so new players can at least use home_point. (See [here](https://github.com/minetest/minetest/blob/master/builtin/settingtypes.txt#L1166) for info on default_privs in minetest.conf)

### home_point_basic

Defaults to max of 2 homes (Change with `home_point.home_point_basic` in settings)

With a jump speed of 15 seconds (Change with `home_point.home_point_basic_jump_speed` in settings)

### home_point_advanced

Defaults to max of 4 homes (Change with `home_point.home_point_advanced` in settings)

With a jump speed of 10 seconds (Change with `home_point.home_point_advanced_jump_speed` in settings)

### home_point_super

Defaults to max of 8 homes (Change with `home_point.home_point_super` in settings)

With a jump speed of 7 seconds (Change with `home_point.home_point_super_jump_speed` in settings)

### home_point_unlimited

Allows unlimited number of homes (Not defined in settings, as unlimited is assumed to be unlimited)

Forcebly defined at 5 seconds (Not defined in settings)

