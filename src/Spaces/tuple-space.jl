# TODO: seed, __getitem__, copy

"""
A tuple (i.e., product) of simpler spaces

Example usage:
tuple_obj.observation_space = spaces.Tuple((spaces.Discrete(2), spaces.Discrete(3)))
"""
mutable struct TupleSpace <: AbstractSpace
    spaces::NTuple{N, AbstractSpace} where N
    dtype::DataType
    shape::Int
    TupleSpace(space_array::NTuple{N, AbstractSpace}) where N = new(space_array, Nothing, length(space_array))
    TupleSpace(space_array::Array{<:AbstractSpace, 1}) = new(Tuple(space_array), Nothing, length(space_array))
end

sample(tuple_obj::TupleSpace) = Tuple(sample(space) for space in tuple_obj.spaces)

function contains(x, tuple_obj::TupleSpace)
    if isa(x, Array)
        x = Tuple(Array)
    end
    return isa(x, Tuple) && Base.length(x) == Base.length(tuple_obj.spaces) &&
        all(contains(space, part) for (space, part) in zip(tuple_obj.spaces, x))
    end

Base.length(tuple_obj::TupleSpace) = length(tuple_obj.spaces)

Base.:(==)(tuple_obj::TupleSpace, other::TupleSpace) = tuple_obj.spaces == other.spaces
# Base.getindex(::Box, index...)
