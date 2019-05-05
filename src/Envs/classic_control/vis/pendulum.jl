using WebIO, JSExpr

obs(env::PendulumEnv, ::Nothing) = obs(env, [0.0, 0.0])
obs(env::PendulumEnv, (θ, θ̄)) = Flux.data(θ)

struct PendulumDrawParams <: AbstractDrawParams
    screen_height::UInt32
    screen_width::UInt32
    world_width::Float32
    scale::Float32
    arm_length::Float32
    arm_width::Float32
    axle_radius::Float32
end

PendulumDrawParams() =
    PendulumDrawParams(
        500,       # screen_height
        500,       # screen_width
        44f-1,     # world_width
        500/44f-1, # scale (screen_width / world_width)
        1f0,       # arm_length
        2f-1,      # arm_width
        5f-2       # axle_radius
    )

function Ctx(env::PendulumEnv, mode::Symbol = :webio)
    if mode == :webio
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

        WebIOCtx(s, o)
    elseif mode == :human_pane
        draw_params = PendulumDrawParams()
        viewer = CairoRGBSurface(draw_params.screen_width, draw_params.screen_height)

        CairoCtx(draw_params, viewer)
    elseif mode == :human_window
        draw_params = PendulumDrawParams()
        viewer = CairoRGBSurface(draw_params.screen_width, draw_params.screen_height)

        canvas = @GtkCanvas()
        canvas.backcc = CairoContext(viewer)
        win = GtkWindow(canvas, "Pendulum",
                draw_params.screen_width, draw_params.screen_height; resizable=false)
        show(canvas)
        visible(win, false)
        signal_connect(win, "delete-event") do widget, event
            ccall((:gtk_widget_hide_on_delete, Gtk.libgtk), Bool, (Ptr{GObject},), win)
        end

        GtkCtx(draw_params, canvas, win)
    elseif mode == :rgb
        draw_params = PendulumDrawParams()
        viewer = CairoRGBSurface(draw_params.screen_width, draw_params.screen_height)

        RGBCtx(draw_params, viewer)
    else
        error("Unrecognized mode in Ctx(): $(mode)")
    end
end

function drawcanvas!(env::PendulumEnv, viewer::CairoContext, params::PendulumDrawParams)
    # Background
    set_source_rgb(viewer, 1, 1, 1)
    rectangle(viewer, 0, 0, params.screen_width, params.screen_height)
    fill(viewer)

    # Move to center of screen
    translate_dist = Pair(params.screen_width/2, params.screen_height/2)
    translate(viewer, translate_dist.first, translate_dist.second)

    # Arm Start Circle
    set_source_rgb(viewer, 8f-1, 3f-1, 3f-1)
    move_to(viewer, 0, 0)
    arc(viewer, 0, 0, params.scale * params.arm_width/2, π, 2*π)

    # Arm Side 1
    rel_line_to(viewer, 0, params.scale * params.arm_length)

    # Arm End Circle
    arc(viewer, 0, params.scale * params.arm_length, params.scale * params.arm_width/2, 0, π)

    # Arm Side 2
    rel_line_to(viewer, 0, -params.scale * params.arm_length)

    # Fill arm
    fill(viewer)

    # Axle
    set_source_rgb(viewer, 0, 0, 0)
    circle(viewer, 0, 0, params.scale * params.axle_radius)
    fill(viewer)

    # Rotate
    rotate(viewer, env.state[2] * env.dt)

    # Undo translation
    translate(viewer, -translate_dist.first, -translate_dist.second)
end

function render(env::PendulumEnv, ctx::WebIOCtx)
    ctx.o[] = obs(env, env.state)
end

function render!(env::PendulumEnv, ctx::CairoCtx)
    drawcanvas!(env, CairoContext(ctx.viewer), ctx.params)
    return ctx.viewer
end

function render!(env::PendulumEnv, ctx::RGBCtx)
    drawcanvas!(env, CairoContext(ctx.viewer), ctx.params)
    ptr = ccall((:cairo_image_surface_get_data, Cairo._jl_libcairo), Ptr{UInt32}, (Ptr{Nothing},), ctx.viewer.ptr)
    arr = unsafe_wrap(Array, ptr, (ctx.params.screen_width, ctx.params.screen_height))
    rgb_arr = convert.(Float64, channelview(colorview(RGB{N0f8}, permutedims(reinterpret(RGB24, arr), [2, 1]))))
    return rgb_arr
end

function render!(env::PendulumEnv, ctx::GtkCtx)
    !visible(ctx.win) && visible(ctx.win, true)
    @guarded draw(ctx.canvas) do widget
        drawcanvas!(env, getgc(ctx.canvas), ctx.params)
    end
    reveal(ctx.canvas, true)
    return ctx.canvas
end