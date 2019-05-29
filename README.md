# Gym.jl
Gym environments in Julia

**`Gym.jl` is a work in progress and in active development. Expect breaking changes for some time.**

**`Gym.jl` requires Julia v1.1**

# Installation
```julia
julia> ] add https://github.com/FluxML/Gym.jl
```

## Usage

```julia
env = make("CartPole-v0", :human_pane)

actions = [sample(env._env.action_space) for i=1:1000]
i = 1
done = false
reset!(env)
while i <= length(actions) && !done
    global i, done
    a, b, done, d = step!(env, actions[i])
    render!(env)
    i += 1
end
```
## Currently available environments
* CartPole
* Pendulum
* Continuous_MountainCar
