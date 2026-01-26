-- verlet approach

verlet_objects = {}

function create_verlet_particle(x, y)
    return { x = x, y = y, px = x, py = y, ax = 0, ay = 0 }
end

function draw_rope(rope)
    for p in all(rope.particles) do
        circfill(p.x, p.y, radius, 8)
    end
    for c in all(rope.constraints) do
        if c.type == "distance" then
            line(c.p1.x, c.p1.y, c.p2.x, c.p2.y, 7)
        end
    end
end

function create_rope(x, y, segments, segment_distance)
    local rope = {
        particles = {},
        constraints = {},
        draw = draw_rope
    }
    for i = 0, segments do
        add(rope.particles, create_verlet_particle(x + segment_distance * i, y))
    end
    for i = 2, #rope.particles do
        add(
            rope.constraints, {
                type = "distance",
                p1 = rope.particles[i - 1],
                p2 = rope.particles[i],
                distance = segment_distance
            }
        )
    end
    -- pin the root particle
    add(rope.constraints, { type = "pin", p1 = rope.particles[1], x = rope.particles[1].x, y = rope.particles[1].y })

    add(verlet_objects, rope)
    return rope
end

function update_verlet_system()
    for o in all(verlet_objects) do
        for p in all(o.particles) do
            update_verlet(p)
        end
    end
    for i = 1, 1 do
        for o in all(verlet_objects) do
            for c in all(o.constraints) do
                solve_constraints(c)
            end
        end
    end
    border_collision_verlet()
end

function solve_constraints(c)
    if c.type == "distance" then
        resolve_distance(c.p1, c.p2, c.distance)
    elseif c.type == "pin" then
        c.p1.x = c.x
        c.p1.y = c.y
    else
        assert(false, c.type .. " is not a constraint type")
    end
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
    local restitution = 0.6
    for o in all(verlet_objects) do
        for p in all(o.particles) do
            if p.y + radius > 126 then
                -- compute implicit velocity BEFORE correction
                local vy = p.y - p.py
                -- correct position
                p.y = 126 - radius
                -- reflect velocity
                p.py = p.y + vy * restitution
            end

            if p.x > 127 - radius then
                local vx = p.x - p.px
                p.x = 127 - radius
                p.px = p.x + vx * restitution
            elseif p.x - radius < 1 then
                local vx = p.x - p.px
                p.x = radius + 1
                p.px = p.x + vx * restitution
            end
        end
    end
end

function draw_verlet()
    for o in all(verlet_objects) do
        o.draw(o)
    end
end