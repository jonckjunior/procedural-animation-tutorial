pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
#include verlet.lua

function _init()
    radius = 2
    eps = 0.01
    spine = create_spine((127 - 5 * 10) / 2, 50, 5, 10)
end

function _update()
    update_verlet_system()
    local move_speed = 1
    local rotation_speed = 0.01

    local forward, backward = 0, 0
    local rotation_delta = 0
    if btn(0) then
        -- left arrow
        rotation_delta -= rotation_speed
    end
    if btn(1) then
        -- right arrow
        rotation_delta += rotation_speed
    end
    if btn(2) then
        -- up arrow
        forward = 1
    end
    if btn(3) then
        -- down arrow
        backward = 1
    end

    local dif = forward - backward
    spine.rotation += rotation_delta
    -- Force head velocity based on input (decoupled from p2)
    local vx = cos(spine.rotation) * move_speed * dif
    local vy = sin(spine.rotation) * move_speed * dif
    spine.head.p1.px = spine.head.p1.x - vx
    spine.head.p1.py = spine.head.p1.y - vy
end

function _draw()
    cls()
    -- draw borders
    line(0, 0, 127, 0, 5)
    line(0, 127, 127, 127, 5)
    line(0, 0, 0, 127, 5)
    line(127, 0, 127, 127, 5)

    draw_verlet()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
