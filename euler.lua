-- euler approach

euler_particles = {}

function add_euler_particle(x, y)
    add(euler_particles, { x = x, y = y, vx = 0, vy = 0, ax = 0, ay = 0 })
end

function update_euler_system()
    border_collision_euler()
    apply_spring_force(euler_particles[1], euler_particles[2], 30)
    for p in all(euler_particles) do
        update_euler(p)
    end
end

function border_collision_euler()
    for p in all(euler_particles) do
        if p.x < radius then
            p.x = radius
            p.vx = -p.vx * 0.6
        elseif p.x > 127 / 2 - radius then
            p.x = 127 / 2 - radius
            p.vx = -p.vx * 0.6
        end

        if p.y > 127 - radius then
            p.y = 127 - radius
            p.vy = -p.vy * 0.6
        end
    end
end

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

-- euler distance constraint (spring-damper)
function apply_spring_force(p1, p2, target_dist)
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local dist = sqrt(dx * dx + dy * dy)

    -- prevent division by zero if points overlap
    if dist < eps then return end

    -- 1. calculate the "error" (displacement from rest distance)
    local displacement = dist - target_dist

    -- 2. hooke's law: force = stiffness * displacement
    -- 'k' is the stiffness constant: higher = stiffer spring
    local k = 1
    local force_mag = displacement * k

    -- 3. calculate force direction (normalize dx, dy)
    local nx = dx / dist
    local ny = dy / dist

    -- 4. apply spring force to acceleration
    --    (assuming mass=1, so f=a)
    p1.ax += nx * force_mag
    p1.ay += ny * force_mag
    p2.ax -= nx * force_mag
    p2.ay -= ny * force_mag
end

function draw_euler()
    for p in all(euler_particles) do
        circfill(p.x, p.y, 2, 8)
    end
    line(euler_particles[1].x, euler_particles[1].y, euler_particles[2].x, euler_particles[2].y, 7)
end