mutable struct PendulumEnv
    max_speed
    max_torque
    last_u
    dt
    viewer
    state
    action_space
    observation_space
end

function PendulumEnv()
    max_speed = 8f0
    max_torque = 2f0
    dt = 5f-2
    viewer = nothing

    high = [1f0, 1f0, max_speed]
    PendulumEnv(max_speed, max_torque, viewer, dt, nothing, nothing)
end

function step!(env::PendulumEnv, u)
    θ, θ̇ = env.state

    g = 10f0
    m = 1f0
    l = 1f0
    dt = env.dt

    u = clamp(u, -env.max_torque, env.max_torque)
    env.last_u = u # for rendering

    costs = angle_normalize(θ)^2 + 1f-1(θ̇ )^2 + 1f-3v^2

    θ̇ = θ̇ + (-3g/(2l) * sin(θ + π) + 3/(m*l^2)*v) * dt
    θ = θ + θ̇ *dt
    θ̇ = clamp(θ̇ , -env.max_speed, env.max_speed)

    env.state .= [θ, θ̇ ]
    return _get_obs(env), -costs, false, Dict()
end

function reset!(env::PendulumEnv)
    high = Float32.([π, 1])
    env.state = 2rand(Float32, 2) .* high .- high
    env.last_u = nothing
    return _get_obs(env)
end

function _get_obs(env::PendulumEnv)
    θ, θ̇ = env.state
    return [cos(θ), sin(θ), θ̇ ]
end

angle_normalize(x) = (x+Float32(π)) % 2Float32(π) - Float32(π)
