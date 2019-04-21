import Flux.testmode!

abstract type AbstractEnv end

IntOrNothing  = Union{Int,  Nothing}
RealOrNothing = Union{Real, Nothing}

mutable struct EnvWrapper
    done::Bool
    total_reward::RealOrNothing
    steps::Int
    train::Bool
	reward_threshold::RealOrNothing
	max_episode_steps::IntOrNothing
    _env::AbstractEnv
end

EnvWrapper(env::AbstractEnv, train::Bool=true; 
		   reward_threshold=nothing, max_episode_steps=nothing) = 
EnvWrapper(false, 0, 0, train, reward_threshold, max_episode_steps, env)

function step!(env::EnvWrapper, a)
    s′, r, done, dict = step!(env._env, a)
    env.total_reward = env.total_reward .+ r
    env.steps += 1
    env.done = done
	if !isnothing(env.max_episode_steps)
		env.done |= env.steps ≥ env.max_episode_steps
	end
    return s′, r, done, dict
end

function reset!(env::EnvWrapper)
    env.done = false
    env.total_reward = 0
    env.steps = 0
    reset!(env._env)
end

render(env::EnvWrapper, ctx::AbstractCtx) = render(env._env, ctx)
render!(env::EnvWrapper, ctx::AbstractCtx) = render!(env._env, ctx)

_get_obs(env::AbstractEnv) = env.state

state(env::EnvWrapper) = _get_obs(env._env)

function testmode!(env::EnvWrapper, val::Bool=true)
    env.train = !val
end

trainable(env::EnvWrapper) = env.train
game_over(env::EnvWrapper) = env.done
