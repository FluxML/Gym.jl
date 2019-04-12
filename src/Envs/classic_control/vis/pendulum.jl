obs(env::PendulumEnv, ::Nothing) = obs(env, [0.0, 0.0])
obs(env::PendulumEnv, (θ, θ̄)) = Flux.data(θ)

function Ctx(env::PendulumEnv)
    path = (p) -> normpath("$(@__DIR__)/$p")
    s = Scope(imports=path.(["../../assets/utils.js", "../../assets/pendulum/pendulum.js", "../../assets/pendulum/pendulum.css"]))
    o = Observable(s, "obs", obs(env, env.state))
    onimport(s, @js () -> begin
        window.pick = (e) -> document.querySelector(e)
        window.container = window.pick(".wio-scope") || window.pick(".webio-scope")
        window.p = __init__(container, $o[]);
        p.draw();
    end)

    onjs(o, @js function (x)
        p.set_theta(x)
        p.draw()
    end)

    Ctx(s, o)
end

function render(env::PendulumEnv, ctx::Gym.Ctx)
    ctx.o[] = obs(env, env.state)
end
