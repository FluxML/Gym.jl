# CartPole.jl
CartPole environment in Julia


## Usage

```julia
env = CartPole()
ctx = Ctx(env)

display(ctx.s)

# using Blink # when not on Juno
# body!(Blink.Window(), ctx.s)

actions = rand(1:2, 1000)
i = 1
done = false
reset()
while i <= length(actions) && !done
    step!(env, actions[i])
    render(env, ctx)
    i += 1
end
```
