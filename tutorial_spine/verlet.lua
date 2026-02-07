-- verlet approach

verlet_objects = {}

function create_verlet_particle(x, y)
    return { x = x, y = y, px = x, py = y, ax = 0, ay = 0, fixed = false }
end

function draw_spine(spine)
    for p in all(spine.particles) do
        if p == spine.head.p1 then
            circfill(p.x, p.y, radius, 9)
        else
            circfill(p.x, p.y, radius, 8)
        end
    end
    for c in all(spine.constraints) do
        if c.type == "distance" then
            line(c.p1.x, c.p1.y, c.p2.x, c.p2.y, 7)
        end
    end
end

function create_spine(x, y, segments, segment_distance)
    local spine = {
        particles = {},
        constraints = {},
        draw = draw_spine,
        head = nil,
        rotation = 0.5
    }
    for i = 0, segments do
        add(spine.particles, create_verlet_particle(x + segment_distance * i, y))
    end

    -- distance constraints between particles
    for i = 2, #spine.particles do
        add(
            spine.constraints, {
                type = "distance",
                p1 = spine.particles[i - 1],
                p2 = spine.particles[i],
                distance = segment_distance
            }
        )
    end

    -- angle constraints to limit bending
    for i = 3, #spine.particles do
        add(
            spine.constraints, {
                type = "angle",
                p1 = spine.particles[i - 2],
                p2 = spine.particles[i - 1],
                p3 = spine.particles[i],
                min_angle = 0.25,
                max_angle = 0.75
            }
        )
    end

    add(verlet_objects, spine)
    spine.head = { p1 = spine.particles[1], p2 = spine.particles[2], distance = segment_distance }
    spine.head.p1.fixed = true
    return spine
end

function update_verlet_system()
    for o in all(verlet_objects) do
        for p in all(o.particles) do
            update_verlet(p)
        end
    end
    for i = 1, 8 do
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
    elseif c.type == "angle" then
        resolve_angle(c.p1, c.p2, c.p3, c.min_angle, c.max_angle)
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
    p.x += vx * 0.95 + p.ax
    p.y += vy * 0.95 + p.ay

    -- reset acceleration
    p.ax = 0
    p.ay = 0
    -- to simulate gravity
end

function resolve_distance(p1, p2, target_dist)
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local stiffness = 1.0
    local dist = sqrt(dx * dx + dy * dy) * stiffness
    if dist < eps then return end
    local nx = dx / dist
    local ny = dy / dist
    local diff = dist - target_dist

    if p1.fixed and p2.fixed then
        return -- Can't resolve if both fixed
    elseif p1.fixed then
        -- Move only p2 fully
        local off_x = nx * diff
        local off_y = ny * diff
        p2.x -= off_x
        p2.y -= off_y
    elseif p2.fixed then
        -- Move only p1 fully
        local off_x = nx * diff
        local off_y = ny * diff
        p1.x += off_x
        p1.y += off_y
    else
        -- Symmetric as before
        local off_x = nx * diff * 0.5
        local off_y = ny * diff * 0.5
        p1.x += off_x
        p1.y += off_y
        p2.x -= off_x
        p2.y -= off_y
    end
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

function resolve_angle(p1, p2, p3, min_angle, max_angle)
    local b1 = atan2(p3.x - p2.x, p3.y - p2.y)
    local a1 = atan2(p1.x - p2.x, p1.y - p2.y)

    -- p1's angle relative to p3 (treating p3 as 0)
    local relative_angle = a1 - b1

    -- Wrap to [0, 1)
    while (relative_angle < 0) do
        relative_angle += 1
    end
    while (relative_angle >= 1) do
        relative_angle -= 1
    end

    -- Check if within range
    if min_angle <= relative_angle and relative_angle <= max_angle then
        return
    end

    -- Calculate correction
    local angle_correction = 0
    if relative_angle < min_angle then
        angle_correction = relative_angle - min_angle
    elseif relative_angle > max_angle then
        angle_correction = relative_angle - max_angle
    end

    -- Rotate p3
    local b_len = sqrt((p3.x - p2.x) ^ 2 + (p3.y - p2.y) ^ 2)
    p3.x = p2.x + cos(b1 + angle_correction) * b_len
    p3.y = p2.y + sin(b1 + angle_correction) * b_len
end