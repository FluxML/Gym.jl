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

function Ctx(env::PendulumEnv, mode::Symbol = :human_window)
    if mode == :human_pane
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