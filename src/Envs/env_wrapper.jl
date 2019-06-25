import Flux.testmode!
using Zygote: @nograd

abstract type AbstractEnv end

include("vis/utils.jl")

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
    _ctx::AbstractCtx
end

EnvWrapper(env::AbstractEnv, ctx::AbstractCtx, train::Bool=true;
		   reward_threshold=nothing, max_episode_steps=nothing) =
EnvWrapper(false, 0, 0, train, reward_threshold, max_episode_steps, env, ctx)

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

render!(env::EnvWrapper, ctx::AbstractCtx) = render!(env._env, ctx)
render!(env::EnvWrapper) = render!(env, env._ctx)

Ctx(env::EnvWrapper, mode::Symbol = :human_window) = Ctx(env._env, mode)

"""
Returns the observational state of the environment. The original state can
be accessed by `\`env._env.state\``.
"""
@nograd function state(env::EnvWrapper)
	try
		return _get_obs(env._env)
	catch y
		if isa(y, UndefVarError) || isa(y, MethodError)
			return env._env.state
		end
	end
end


function testmode!(env::EnvWrapper, val::Bool=true)
    env.train = !val
end

trainable(env::EnvWrapper) = env.train
game_over(env::EnvWrapper) = env.done
