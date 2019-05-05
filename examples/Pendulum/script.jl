using Flux, Gym

# Load game environment
env = make("Pendulum-v0")
ctx = Ctx(env, :human_window)
reset!(env)

actions = [sample(env._env.action_space) for i=1:1000]
i = 1
done = false
reset!(env)
while i <= length(actions) && !done
    global i, done
    print("Iteration: $i, ")
    a, b, done, d = step!(env, actions[i])
    println("θ = $(env._env.state[1])")

    render!(env, ctx)
    i += 1
    sleep(0.01) # to see an animation
end