obs(env::CartPoleEnv, ::Nothing) = obs(env, zeros(4))
obs(env::CartPoleEnv, (x, x̄, θ, θ̄)) =
    Dict("x" => x, "theta"=>θ)

struct CartPoleDrawParams <: AbstractDrawParams
    screen_height::UInt32
    screen_width::UInt32
    world_width::Float32
    scale::Float32
    carty::UInt32
    pole_width::Float32
    pole_length::Float32
    cart_width::Float32
    cart_height::Float32
end

CartPoleDrawParams() =
    CartPoleDrawParams(
        400,       # screen_height
        600,       # screen_width
        48f-1,     # world_width
        600/48f-1, # scale (screen_width / world_width)
        100,       # carty
        10f0,      # pole_width
        600/48f-1, # pole_length (scale)
        50f0,      # cart_width
        30f0       # cart_height
    )

Ctx(env::CartPoleEnv, mode::Symbol = :human_window) = Ctx(env, Val(mode))
    
function Ctx(::CartPoleEnv, ::Val{:human_pane})
    draw_params = CartPoleDrawParams()
    viewer = CairoRGBSurface(draw_params.screen_width, draw_params.screen_height)

    CairoCtx(draw_params, viewer)
end

@init @require Gtk="4c0ca9eb-093a-5379-98c5-f87ac0bbbf44" function Ctx(::CartPoleEnv, ::Val{:human_window})
    draw_params = CartPoleDrawParams()
    viewer = CairoRGBSurface(draw_params.screen_width, draw_params.screen_height)

    canvas = @GtkCanvas()
    canvas.backcc = CairoContext(viewer)
    win = GtkWindow(canvas, "CartPole",
            draw_params.screen_width, draw_params.screen_height; resizable=false)
    show(canvas)
    visible(win, false)
    signal_connect(win, "delete-event") do widget, event
        ccall((:gtk_widget_hide_on_delete, Gtk.libgtk), Bool, (Ptr{GObject},), win)
    end

    GtkCtx(draw_params, canvas, win)
end
   
function Ctx(::CartPoleEnv, ::Val{:rgb})
    draw_params = CartPoleDrawParams()
    viewer = CairoRGBSurface(draw_params.screen_width, draw_params.screen_height)

    RGBCtx(draw_params, viewer)
end

function drawcanvas!(env::CartPoleEnv, viewer::CairoContext, params::CartPoleDrawParams)
    # Background
    set_source_rgb(viewer, 1, 1, 1)
    rectangle(viewer, 0, 0, params.screen_width, params.screen_height)
    fill(viewer)

    # Track
    set_source_rgb(viewer, 0, 0, 0)
    move_to(viewer, 0, params.screen_height - params.carty)
    line_to(viewer, params.screen_width, params.screen_height - params.carty)
    set_line_width(viewer, 0.5)
    stroke(viewer)

    # Cart
    cartx = env.state[1] * params.scale + params.screen_width/2f0 # MIDDLE OF CART
    translation_dist = Pair(cartx, params.screen_height - params.carty - params.cart_height/2f0)
    translate(viewer, translation_dist.first, translation_dist.second) # first = x, second = y
    set_source_rgb(viewer, 0, 0, 0)
    rectangle(viewer, 0, 0, params.cart_width, params.cart_height)
    fill(viewer)

    # Undoing translation
    translate(viewer, -translation_dist.first, -translation_dist.second)

    # Pole
    translation_dist = Pair(cartx + params.cart_width/2f0, params.screen_height - params.carty - params.cart_height/8f0)
    # Translating from origin to perform rotation; first = x, second = y
    translate(viewer, translation_dist.first, translation_dist.second)
    # translate(viewer, params.cart_width/2, params.cart_height/2)
    rotate(viewer, env.state[3])
    set_source_rgb(viewer, 8f-1, 6f-1, 4f-1)
    rectangle(viewer, -params.pole_width/2, 0, params.pole_width, -params.pole_length)
    fill(viewer)

    #Axle
    set_source_rgb(viewer, 5f-1, 5f-1, 8f-1)
    circle(viewer, 0, 0, 5)
    fill(viewer)

    # Undoing translations and rotations
    rotate(viewer, -env.state[3])
    translate(viewer, -translation_dist.first, -translation_dist.second)
end
