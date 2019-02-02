using WebIO, JSExpr

struct Ctx
    s::Scope
    o::Observable
end

obs(::Nothing) = obs(zeros(4))
obs((x, x̄, θ, θ̄)) =
    Dict("x" => x, "theta"=>θ)

function Ctx(env::CartPoleEnv)
    path = (p) -> normpath("$(@__DIR__)/$p")
    s = Scope(imports=path.(["../assets/js/Board.js", "../assets/css/cartpole.css"]))
    config = Dict(
        "cart_height"=> env.length/60,
        "cart_length"=> 2*env.length,
        "pole_length"=> env.polemass_length,
        "pole_diameter"=> env.polemass_length/5,
        "x_threshold"=> env.x_threshold)

    o = Observable(s, "obs", obs(env.state))
    onimport(s, @js () -> begin
        window.pick = (e) -> document.querySelector(e)
        window.container = window.pick(".wio-scope") || window.pick(".webio-scope")
        window.board = @new Board(window.container, $(config))
        board.render($o[])
    end)

    onjs(o, @js function (x)
        board.render(x)
    end)

    Ctx(s, o)
end

function render(env::CartPoleEnv, ctx::Ctx)
    ctx.o[] = obs(env.state)
end
