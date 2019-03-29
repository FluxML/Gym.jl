import Random


# TODO: seed, copy

"""
A box in R^n.
I.e., each coordinate is bounded.

Example usage:
self.action_space = Box(-10, 10, (1,))

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
    Low = dtype(low) .+ zeros(dtype, shape)
    High = dtype(high) .+ zeros(dtype, shape)
    return Box(Low, High, shape, dtype)
end

function Box(low::Array, high::Array, dtype::Union{DataType, Nothing}=nothing)
    @assert size(low) == size(high)
    shape = size(low)
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
function seed!(self::Box, seed::Int)
    self.seed = seed
end
=#
function sample(self::Box)
    self.dtype <: AbstractFloat ?
        rand(self.dtype, self.shape) .* (self.high .- self.low) .+ self.low :
        rand.(UnitRange.(self.low, self.high))
end

contains(self::Box, x) = size(x) == self.shape && all(x .>= self.low) && all(x .<= self.high)

Base.:(==)(self::Box, other::Box) = isapprox(self.low, other.low) && isapprox(self.high, other.high)
