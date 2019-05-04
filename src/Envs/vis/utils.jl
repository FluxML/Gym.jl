using WebIO, Cairo, Gtk

abstract type AbstractDrawParams end

abstract type AbstractCtx end

struct WebIOCtx <: AbstractCtx
    s::Scope
    o::Observable
end

struct CairoCtx <: AbstractCtx
    params::AbstractDrawParams
    viewer::Cairo.CairoSurfaceBase{UInt32}
end

const RGBCtx = CairoCtx

struct GtkCtx <: AbstractCtx
    params::AbstractDrawParams
    canvas::GtkCanvas
    win::GtkWindowLeaf
end

# `play(env, actions)`
# or
# `
# using Blink
# w = Blink()
# play(env, actions, (ctx)=> body!(w, ctx.s))
# `
#=
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
=#
