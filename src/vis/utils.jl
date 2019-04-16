using WebIO, JSExpr, Cairo

abstract type AbstractCtx end

struct WebIOCtx <: AbstractCtx
    s::Scope
    o::Observable
end

struct CairoCtx <: AbstractCtx
    screen_height::UInt32
    screen_width::UInt32
    world_width::Float32
    scale::Float32
    carty::UInt32
    pole_width::Float32
    pole_length::Float32
    cart_width::Float32
    cart_height::Float32
    viewer::Cairo.CairoSurfaceBase{UInt32}
end

# `play(env, actions)`
# or
# `
# using Blink
# w = Blink()
# play(env, actions, (ctx)=> body!(w, ctx.s))
# `
function play(env, actions=rand(1:2, 1000), cb=nothing)
    reset!(env)
    ctx = Ctx(env)
    if cb == nothing
        display(ctx.s)
    else
        cb(ctx)
    end

    i = 1
    done = false

    while i <= length(actions) && !done
        a, b, done, d = step!(env, actions[i])
        render(env, ctx)
        i += 1
        sleep(0.08) # to see an animation
    end

end
