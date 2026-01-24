-- verlet approach

verlet_p = {
    x = 80, y = 20,
    px = 80, py = 20, -- px/py = previous x/y
    ax = 0, ay = 0
}

function update_verlet(p)
    -- calculate velocity implicitly
    local vx = p.x - p.px
    local vy = p.y - p.py

    -- update previous position to current
    p.px = p.x
    p.py = p.y

    -- calculate new position
    p.x += vx * 0.99 + p.ax
    p.y += vy * 0.99 + p.ay

    -- reset acceleration
    p.ax = 0
    p.ay = 0.1
    -- to simulate gravity
end

function draw_verlet()
    circfill(verlet_p.x, verlet_p.y, 2, 12)
end