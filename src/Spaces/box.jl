# TODO: seed, copy

"""
A box in R^n, i.e., each coordinate is bounded.

Two kinds of valid input:
    Box(-1.0, 1.0, (3,4)) # low and high are scalars, and shape is provided
    Box([-1.0,-2.0], [2.0,4.0]) # low and high are arrays of the same shape
"""
mutable struct Box <: AbstractSpace
    low::Array
    high::Array
    shape::Tuple
end

function Box(low::Number, high::Number, shape::Union{Tuple, Array{Int64, 1}}, dtype::Union{DataType, Nothing}=nothing)
    if isnothing(dtype)
        dtype = high == 255 ? UInt8 : Float32
        @warn "dtype was autodetected as $(dtype). Please provide explicit data type."
    end

    if low > high
        @warn "low  > high. Swapping values to preserve sanity"
        (low, high) = (high, low)  # Preserves sanity if low > high
    end

    if dtype <: Integer
        if !isa(low, Integer) || !isa(high, Integer)
            @warn "dtype is an Integer, but the values are floating points. Using ceiling of lower bound and floor of upper bound"
        end
        low = ceil(dtype, low)
        high = floor(dtype, high)
    end

    Low = dtype(low) .+ zeros(dtype, shape)
    High = dtype(high) .+ zeros(dtype, shape)
    return Box(Low, High, shape)
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
        if !all(isa.(low, Integer)) || !all(isa(high, Integer))
            @warn "dtype is an Integer, but the values are floating points. Using ceiling of lower bound and floor of upper bound"
        end
        low = ceil.(dtype, low)
        high = floor.(dtype, high)
    else
        low = dtype.(low)
        high = dtype.(high)
    end
    return Box(low, high, shape)
end
#=
function seed!(box_obj::Box, seed::Int)
    box_obj.seed = seed
end
=#

Base.:(==)(box_obj::Box, other::Box) = checkvalidtypes(box_obj, other) && isapprox(box_obj.low, other.low) && isapprox(box_obj.high, other.high)

function sample(box_obj::Box)
    dtype = eltype(box_obj.low)
    dtype <: AbstractFloat ?
        rand(dtype, size(box_obj)) .* (box_obj.high .- box_obj.low) .+ box_obj.low :
        rand.(UnitRange.(box_obj.low, box_obj.high))
end

function contains(x::Union{Real, AbstractArray, NTuple}, box_obj::Box)
    isa(x, Number) && size(box_obj.low) == (1,) && (x = [x])
    size(x) == size(box_obj) && all(box_obj.low .<= x .<= box_obj.high)
end

function checkvalidtypes(box_obj1::Box, box_obj2::Box)
    dtype1, dtype2 = eltype(box_obj1.low), eltype(box_obj2.low)
    dtype1 == dtype2 ||                            # If the dtypes of both boxes are not the same...
            (dtype1 <: Unsigned && dtype2 <: Unsigned) || (dtype1 <: Signed && dtype2 <: Signed)  # then check if they're both signed or both unsigned.
end
