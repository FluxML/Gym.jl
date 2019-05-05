using WebIO, JSExpr, Cairo, Colors, Images

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

function Ctx(env::CartPoleEnv, mode::Symbol = :webio)
    if mode == :webio
        path = (p) -> normpath("$(@__DIR__)/$p")
        s = Scope(imports=path.(["../../assets/cartpole/js/Board.js", "../../assets/cartpole/css/cartpole.css"]))
        config = Dict(
            "cart_height"=> env.length/60,
            "cart_length"=> 2*env.length,
            "pole_length"=> env.polemass_length,
            "pole_diameter"=> env.polemass_length/5,
            "x_threshold"=> env.x_threshold)

        o = Observable(s, "obs", obs(env, Flux.data(env.state)))
        onimport(s, @js () -> begin
            window.pick = (e) -> document.querySelector(e)
            window.container = window.pick(".wio-scope") || window.pick(".webio-scope")
            window.board = @new Board(window.container, $(config))
            board.render($o[])
        end)

        onjs(o, @js function (x)
            board.render(x)
        end)

        WebIOCtx(s, o)
    elseif mode == :human_pane
        draw_params = CartPoleDrawParams()
        viewer = CairoRGBSurface(draw_params.screen_width, draw_params.screen_height)

        CairoCtx(draw_params, viewer)
    elseif mode == :human_window
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
    elseif mode == :rgb
        draw_params = CartPoleDrawParams()
        viewer = CairoRGBSurface(draw_params.screen_width, draw_params.screen_height)

        RGBCtx(draw_params, viewer)
    else
        error("Unrecognized mode in Ctx(): $(mode)")
    end
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

function render(env::CartPoleEnv, ctx::WebIOCtx)
    ctx.o[] = obs(env, env.state)
end

function render!(env::CartPoleEnv, ctx::CairoCtx)
    drawcanvas!(env, CairoContext(ctx.viewer), ctx.params)
    return ctx.viewer
end

function render!(env::CartPoleEnv, ctx::RGBCtx)
    drawcanvas!(env, CairoContext(ctx.viewer), ctx.params)
    ptr = ccall((:cairo_image_surface_get_data, Cairo._jl_libcairo), Ptr{UInt32}, (Ptr{Nothing},), ctx.viewer.ptr)
    arr = unsafe_wrap(Array, ptr, (ctx.params.screen_width, ctx.params.screen_height))
    rgb_arr = convert.(Float64, channelview(colorview(RGB{N0f8}, permutedims(reinterpret(RGB24, arr), [2, 1]))))
    return rgb_arr
end

function render!(env::CartPoleEnv, ctx::GtkCtx)
    !visible(ctx.win) && visible(ctx.win, true)
    @guarded draw(ctx.canvas) do widget
        drawcanvas!(env, getgc(ctx.canvas), ctx.params)
    end
    reveal(ctx.canvas, true)
    return ctx.canvas
end