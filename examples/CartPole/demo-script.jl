using .Gym
env = make("CartPole-v0", :human_pane)

actions = [sample(env._env.action_space) for i=1:1000]
i = 1
done = false
reset!(env)
while i <= length(actions)
    global i, done
    a, b, done, d = step!(env, actions[i])

    render!(env)
    i += 1
end
