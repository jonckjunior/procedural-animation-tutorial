-- euler approach

euler_p = {
    x = 50, y = 20,
    vx = 0, vy = 0,
    ax = 0, ay = 0
}

function update_euler(p)
    -- update velocity
    p.vx += p.ax
    p.vy += p.ay

    p.vx *= 0.99
    p.vy *= 0.99

    -- update position
    p.x += p.vx
    p.y += p.vy
    -- reset acceleration
    p.ax = 0
    p.ay = 0.1
    -- to simulate gravity
end

function draw_euler()
    circfill(euler_p.x, euler_p.y, 2, 8)
end