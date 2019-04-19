using WebIO, JSExpr, Cairo, Colors, Images

obs(env::CartPoleEnv, ::Nothing) = obs(env, zeros(4))
obs(env::CartPoleEnv, (x, x̄, θ, θ̄)) =
    Dict("x" => x, "theta"=>θ)

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
    elseif mode == :human
        screen_height = 400
        screen_width = 600
        world_width = 48f-1
        scale = screen_width/world_width
        carty = 100 # TOP OF CART
        pole_width = 10f0
        pole_length = scale
        cart_width = 50f0
        cart_height = 30f0
        viewer = CairoRGBSurface(screen_width, screen_height)

        CairoCtx(
            screen_height,
            screen_width,
            world_width,
            scale,
            carty,
            pole_width,
            pole_length,
            cart_width,
            cart_height,
            viewer
        )
    elseif mode == :rgb
        screen_height = 400
        screen_width = 600
        world_width = 48f-1
        scale = screen_width/world_width
        carty = 100 # TOP OF CART
        pole_width = 10f0
        pole_length = scale
        cart_width = 50f0
        cart_height = 30f0
        viewer = CairoRGBSurface(screen_width, screen_height)
        cario = CairoCtx(
            screen_height,
            screen_width,
            world_width,
            scale,
            carty,
            pole_width,
            pole_length,
            cart_width,
            cart_height,
            viewer
        )

        RGBCtx(cario)
    else
        error("Unrecognized mode in Ctx(): $(mode)")
    end
end

function render(env::CartPoleEnv, ctx::WebIOCtx)
    ctx.o[] = obs(env, Flux.data(env.state))
end

function render!(env::CartPoleEnv, ctx::CairoCtx)
    viewer = CairoContext(ctx.viewer)
    # Background
    set_source_rgb(viewer, 1, 1, 1)
    rectangle(viewer, 0, 0, ctx.screen_width, ctx.screen_height)
    fill(viewer)

    # Track
    set_source_rgb(viewer, 0, 0, 0)
    move_to(viewer, 0, ctx.screen_height - ctx.carty)
    line_to(viewer, ctx.screen_width, ctx.screen_height - ctx.carty)
    set_line_width(viewer, 0.5)
    stroke(viewer)

    # Cart
    cartx = env.state[1].data * ctx.scale + ctx.screen_width/2f0 # MIDDLE OF CART
    translate(viewer, cartx, ctx.screen_height - ctx.carty - ctx.cart_height/2f0)
    set_source_rgb(viewer, 0, 0, 0)
    rectangle(viewer, 0, 0, ctx.cart_width, ctx.cart_height)
    fill(viewer)

    # Pole
    translate(viewer, ctx.cart_width/2, ctx.cart_height/2)
    rotate(viewer, env.state[3].data)
    set_source_rgb(viewer, 8f-1, 6f-1, 4f-1)
    move_to(viewer, 0, 0)
    line_to(viewer, ctx.pole_width/2, 0)
    line_to(viewer, ctx.pole_width/2, -ctx.pole_length)
    line_to(viewer, -ctx.pole_width/2, -ctx.pole_length)
    line_to(viewer, -ctx.pole_width/2, 0)
    close_path(viewer)
    fill(viewer)

    #Axle
    set_source_rgb(viewer, 5f-1, 5f-1, 8f-1)
    circle(viewer, 0, 0, 5)
    fill(viewer)

    ctx.viewer
end

function render!(env::CartPoleEnv, ctx::RGBCtx)
    render!(env, ctx.cairo)
    ptr = ccall((:cairo_image_surface_get_data, Cairo._jl_libcairo), Ptr{UInt32}, (Ptr{Nothing},), ctx.cairo.viewer.ptr)
    arr = unsafe_wrap(Array, ptr, (ctx.cairo.screen_width, ctx.cairo.screen_height))
    rgb_arr = convert.(Float64, channelview(colorview(RGB{N0f8}, permutedims(reinterpret(RGB24, arr), [2, 1]))))
    return rgb_arr
end