# Gym.jl
Gym environments in Julia

**`Gym.jl` is a work in progress and in active development. Expect breaking changes for some time.**

# Installation
```julia
julia> ] add https://github.com/FluxML/Gym.jl
```

## Usage

```julia
env = make("CartPole")
ctx = Ctx(env)

display(ctx.s)

# using Blink # when not on Juno
# body!(Blink.Window(), ctx.s)

actions = [sample(env.action_space) for i=1:1000]
i = 1
done = false
reset!(env)
while i <= length(actions) && !done
    global i, done
    a, b, done, d = step!(env, actions[i])
    render(env, ctx)
    i += 1
    # sleep(0.4) # to see an animation
end
```
## Currently available environments
* CartPole
* Pendulum
* Continuous_MountainCar
