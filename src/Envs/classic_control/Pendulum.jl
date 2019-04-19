mutable struct PendulumEnv <: AbstractEnv
    max_speed::Float32
    max_torque::Float32
    last_u
    dt::Float32
    viewer
    state
    action_space::Box
    observation_space::Box
end

include("vis/pendulum.jl")

function PendulumEnv()
    max_speed = 8f0
    max_torque = 2f0
    dt = 5f-2
    viewer = nothing
    # Observation space limits
    high = [1f0, 1f0, max_speed]
    action_space = Box(-max_torque, max_torque, (1,), Float32)
    observation_space = Box(-high, high, Float32)

    PendulumEnv(max_speed, max_torque, nothing, dt, nothing, nothing, action_space, observation_space)
end

function step!(env::PendulumEnv, u)
    @assert u ∈ env.action_space "Invalid action ($(u)) issued"
    θ, θ̇  = env.state[1:1], env.state[2:2]
    g, m, l, dt = 10f0, 1f0, 1f0, env.dt

    v = clamp.(u, -env.max_torque, env.max_torque)
    env.last_u = Tracker.data(v)[1] # for rendering

    costs = angle_normalize.(θ).^2 .+ 1f-1(θ̇ .^2) .+ 1f-3(u.^2)

    tempθ̇_ = θ̇  .+ (-3g/(2l) * sin.(θ .+ pi) .+ 3/(m*l^2)*u) * dt
    θ_     = θ  .+ tempθ̇_*dt
    θ̇_     = clamp.(tempθ̇_, -env.max_speed, env.max_speed)

    env.state = vcat(θ_, θ̇_)
    return _get_obs(env), -costs, false, Dict()
end

function reset!(env::PendulumEnv)
    high = Float32.([π, 1])
    env.state = param(2rand(Float32, 2) .* high .- high)

    if isdefined(Main, :CuArrays)
        env.state = env.state |> gpu
    end

    env.last_u = nothing
    return _get_obs(env)
end

function _get_obs(env::PendulumEnv)
    θ, θ̇ = env.state[1:1], env.state[2:2]
    return vcat(cos.(θ), sin.(θ), θ̇ )
end

pi = Float32(π)

angle_normalize(x) = ((x + pi) % 2pi + 2pi) % 2pi - pi
