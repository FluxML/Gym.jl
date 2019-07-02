"""A specification for a particular instance of the environment. Used
to register the parameters for official evaluations.

Args:
    id (str): The official environment ID
    entry_point (Optional[str]): The Python entrypoint of the environment class (e.g. module.name:Class)
    trials (int): The number of trials to average reward over
    reward_threshold (Optional[int]): The reward threshold before the task is considered solved
    kwargs (dict): The kwargs to pass to the environment class
    nondeterministic (bool): Whether this environment is non-deterministic even after seeding
    tags (dict[str:any]): A set of arbitrary key-value tags on this environment, including simple property=True tags

Attributes:
    id (str): The official environment ID
    trials (int): The number of trials run in official evaluation
"""


struct EnvSpec
    id::Symbol
    entry_point::String

    trials::Int
    reward_threshold::Union{Int, Nothing}
    nondeterministic::Bool
    tags::Dict{String, Any}
    max_episode_steps::Union{Int, Nothing}
    max_episode_seconds::Union{Int, Nothing}
    kwargs::Dict
end

function EnvSpec(id, entry_point; trials=100, reward_threshold=nothing,
                nondeterministic=false, tags=Dict(), max_episode_steps=nothing,
                max_episode_seconds=nothing, kwargs=Dict())

    # Still need to figure out how to create a wrapper that stops the environment
    # after a certain number of episodes.
    tags["wrapper_config.TimeLimit.max_episode_steps"] = max_episode_steps
    EnvSpec(id, entry_point, trials, reward_threshold, nondeterministic, tags,
            max_episode_steps, max_episode_seconds, kwargs)
end

function _make(spec::EnvSpec, render_mode::Symbol; kwargs...)
    _kwargs = deepcopy(spec.kwargs)
    merge!(_kwargs, Dict(kwargs))

    env_var = load(spec.entry_point, spec.id)
    ctx_var = load(spec.entry_point, :Ctx)
    env = Base.invokelatest(env_var)
    ctx = Base.invokelatest(ctx_var, env, render_mode)
    env, ctx, spec.reward_threshold, spec.max_episode_steps
end

function load(path, id)
    #mod_name, attr_name = split(name, ':')
    #println(mod_name, attr_name)
    home_dir = @__DIR__
    fullpath = home_dir * path
    include(fullpath)
    eval(id)
end



mutable struct EnvRegistry
    env_specs::Dict{String, EnvSpec}

    EnvRegistry() = new(Dict{String, EnvSpec}())
end

function _register(reg::EnvRegistry, id_string, id, entry_point; kwargs...)
    !isnothing(get(reg.env_specs, id_string, nothing)) &&
                (throw(ErrorException("Cannot re-register id: $(id_string)")))

    reg.env_specs[id_string] = EnvSpec(id, entry_point; kwargs...)
end

function _make(reg::EnvRegistry, id_string, render_mode::Symbol; kwargs...)
    spec = get(reg.env_specs, id_string, nothing)

    isnothing(spec) &&
            (throw(ErrorException("Environment $(id_string) not found in the registry. Please ensure that you've spelled the name correctly.")))

    _make(spec, render_mode; kwargs...)
end

registry = EnvRegistry()

"""
Registers an environment to the global registry.
"""
register(id_string, id, entry_point; kwargs...) = _register(registry, id_string,
                                                            id, entry_point; kwargs...)

"""
Instantiates an instance of the environment with appropriate kwargs.

Optional keyword arguments:
    trials (Int): The number of trials to average reward over
    reward_threshold (Int): The reward threshold before the task is considered solved
    kwargs (Dict): The kwargs to pass to the environment class
    nondeterministic ( Bool): Whether this environment is non-deterministic even after seeding
    tags (Dict{String, Any}): A set of arbitrary key-value tags on this environment, including simple property=True tags
"""

include("env_wrapper.jl")

function make(id_string, mode=:human_pane, train=true; kwargs...)
	env, ctx, rt, max_ep_steps = _make(registry, id_string, mode; kwargs...)
	EnvWrapper(env, ctx, train; reward_threshold=rt, max_episode_steps=max_ep_steps)
end
