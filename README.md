# Procedural Animation with Verlet Physics in PICO-8

A tutorial exploring procedural animation using Verlet integration for stable, natural-looking movement without complex force calculations.

## Key Concepts

### Verlet vs Euler Integration
- **Euler**: Uses velocity and acceleration to predict movement. Intuitive but prone to drift and instability.
- **Verlet**: Uses previous position and current position to infer velocity. More stable, cheaper computationally, and handles constraints elegantly.

### Why Verlet?
- No need for complex force calculations
- Constraints can be solved by simply moving points to correct positions
- Naturally prevents overshooting and explosions
- Much better for games and procedural animation

## Constraints

The tutorial covers three core constraint types:

1. **Distance**: Keeps two points at a fixed distance (rope, sticks)
2. **Pin**: Locks a point to a specific position
3. **Angular**: Limits rotation between three consecutive points (prevents self-crossing)

## Tutorial Modules

- **tutorial_point**: Basic single-point Verlet simulation
- **tutorial_rope**: Distance constraints chained together
- **tutorial_spine**: Fixed head point with angular constraints
- **tutorial_stick**: Two-point rigid constraint with collisions

Each module includes a `verlet.lua` library with core physics functions and a `.p8` PICO-8 cartridge demonstrating the concept.

## Files

- `verlet.lua`: Core Verlet integration and constraint resolution
- `euler.lua`: Reference Euler integration implementation (in point/stick tutorials)


Link to tutorial: https://www.lexaloffle.com/bbs/?tid=154658