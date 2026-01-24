-- verlet approach

verlet_particles = {}

function add_verlet_particle(x, y)
    add(verlet_particles, { x = x, y = y, px = x, py = y, ax = 0, ay = 0 })
end

function update_verlet_system()
    for p in all(verlet_particles) do
        update_verlet(p)
    end
    border_collision_verlet()
    resolve_distance(verlet_particles[1], verlet_particles[2], 30)
end

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

function resolve_distance(p1, p2, target_dist)
    -- fetch distance between points
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local stiffness = 1.0
    local dist = sqrt(dx * dx + dy * dy) * stiffness

    -- prevent division by zero if points overlap
    if dist < eps then return end

    -- calculate unit vectors
    local nx = dx / dist
    local ny = dy / dist

    -- apply displacement evenly between two points
    local diff = dist - target_dist
    local off_x = nx * diff * 0.5
    local off_y = ny * diff * 0.5

    -- distribute displacement
    p1.x += off_x
    p1.y += off_y
    p2.x -= off_x
    p2.y -= off_y
end

function border_collision_verlet()
    local ground_y = 127 - radius
    local restitution = 0.6

    for p in all(verlet_particles) do
        if p.y > ground_y then
            -- compute implicit velocity BEFORE correction
            local vy = p.y - p.py

            -- correct position
            p.y = ground_y

            -- reflect velocity
            p.py = p.y + vy * restitution
        end

        if p.x > 127 - radius then
            local vx = p.x - p.px
            p.x = 127 - radius
            p.px = p.x + vx * restitution
        elseif p.x < 127 / 2 + radius then
            local vx = p.x - p.px
            p.x = 127 / 2 + radius
            p.px = p.x + vx * restitution
        end
    end
end

function draw_verlet()
    for p in all(verlet_particles) do
        circfill(p.x, p.y, 2, 12)
    end
    line(verlet_particles[1].x, verlet_particles[1].y, verlet_particles[2].x, verlet_particles[2].y, 7)
end