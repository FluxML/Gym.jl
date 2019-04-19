# TODO: seed, copy

"""
A box in R^n.
I.e., each coordinate is bounded.

Example usage:
box_obj.action_space = Box(-10, 10, (1,))

Two kinds of valid input:
    Box(low=-1.0, high=1.0, shape=(3,4)) # low and high are scalars, and shape is provided
    Box(low=[-1.0,-2.0], high=[2.0,4.0]) # low and high are arrays of the same shape
"""
mutable struct Box <: AbstractSpace
    low::Array
    high::Array
    shape::Tuple
    dtype::DataType
    #seed::Int
end

function Box(low::Number, high::Number, shape::Union{Tuple, Array{Int64, 1}}, dtype::Union{DataType, Nothing}=nothing)
    if isnothing(dtype)
        dtype = high == 255 ? UInt8 : Float32
        @warn "dtype was autodetected as $(dtype). Please provide explicit data type."
    end
    if dtype <: Integer
        low = floor(dtype, low)
        high = floor(dtype, high)
    end

    low > high && ((low, high) = (high, low))  # Preserves sanity if low > high

    Low = dtype(low) .+ zeros(dtype, shape)
    High = dtype(high) .+ zeros(dtype, shape)
    return Box(Low, High, shape, dtype)
end

function Box(low::Array, high::Array, dtype::Union{DataType, Nothing}=nothing)
    @assert size(low) == size(high) "Dimension mismatch between low and high arrays."
    shape = size(low)
    @assert all(low .< high) "elements of low must be lesser than their respective counterparts in high"

    if isnothing(dtype)
        dtype = all(high .== 255) ? UInt8 : Float32
        @warn "dtype was autodetected as $(dtype). Please provide explicit data type."
    end
    if dtype <: Integer
        low = floor.(dtype, low)
        high = floor.(dtype, high)
    else
        low = dtype.(low)
        high = dtype.(high)
    end
    return Box(low, high, shape, dtype)
end
#=
function seed!(box_obj::Box, seed::Int)
    box_obj.seed = seed
end
=#
function sample(box_obj::Box)
    box_obj.dtype <: AbstractFloat ?
        rand(box_obj.dtype, box_obj.shape) .* (box_obj.high .- box_obj.low) .+ box_obj.low :
        rand.(UnitRange.(box_obj.low, box_obj.high))
end

function contains(box_obj::Box, x)
    isa(x, Number) && box_obj.shape == (1,) && (x = [x])
    size(x) == box_obj.shape && all(box_obj.low .<= x .<= box_obj.high)
end

Base.:(==)(box_obj::Box, other::Box) = isapprox(box_obj.low, other.low) && isapprox(box_obj.high, other.high)
