using Cairo, Images, Colors

abstract type AbstractCtx end
abstract type AbstractDrawParams end

struct CairoCtx <: AbstractCtx
    params::AbstractDrawParams
    viewer::Cairo.CairoSurfaceBase{UInt32}
end

struct RGBCtx <: AbstractCtx
    params::AbstractDrawParams
    viewer::Cairo.CairoSurfaceBase{UInt32}
end

function render!(env::AbstractEnv, ctx::CairoCtx)
    drawcanvas!(env, CairoContext(ctx.viewer), ctx.params)
    display(ctx.viewer)
end

function render!(env::AbstractEnv, ctx::RGBCtx)
    drawcanvas!(env, CairoContext(ctx.viewer), ctx.params)
    ptr = ccall((:cairo_image_surface_get_data, Cairo._jl_libcairo), Ptr{UInt32}, (Ptr{Nothing},), ctx.viewer.ptr)
    arr = unsafe_wrap(Array, ptr, (ctx.params.screen_width, ctx.params.screen_height))
    rgb_arr = convert.(Float64, channelview(colorview(RGB{N0f8}, permutedims(reinterpret(RGB24, arr), [2, 1]))))
    return rgb_arr
end

@init @require Gtk="4c0ca9eb-093a-5379-98c5-f87ac0bbbf44" begin
	using Gtk

	struct GtkCtx <: AbstractCtx
		params::AbstractDrawParams
		canvas::GtkCanvas
		win::GtkWindowLeaf
	end

	function render!(env::AbstractEnv, ctx::GtkCtx)
		!visible(ctx.win) && visible(ctx.win, true)
		@guarded draw(ctx.canvas) do widget
		    drawcanvas!(env, getgc(ctx.canvas), ctx.params)
		end
		reveal(ctx.canvas, true)
		return ctx.canvas
	end
end
