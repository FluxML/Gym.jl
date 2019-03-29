# TODO: seed, __getitem__, copy

"""
A tuple (i.e., product) of simpler spaces

Example usage:
self.observation_space = spaces.Tuple((spaces.Discrete(2), spaces.Discrete(3)))
"""
mutable struct TupleSpace <: AbstractSpace
    spaces::NTuple{N, AbstractSpace} where N
    dtype::DataType
    shape::Int
    TupleSpace(space_array::NTuple{N, AbstractSpace}) where N = new(space_array, Nothing, length(space_array))
    TupleSpace(space_array::Array{<:AbstractSpace, 1}) = new(Tuple(space_array), Nothing, length(space_array))
end

sample(self::TupleSpace) = Tuple(sample(space) for space in self.spaces)

function contains(self::TupleSpace, x)
    if isa(x, Array)
        x = Tuple(Array)
    end
    return isa(x, Tuple) && Base.length(x) == Base.length(self.spaces) &&
        all(contains(space, part) for (space, part) in zip(self.spaces, x))
    end

Base.length(self::TupleSpace) = length(self.spaces)

Base.:(==)(self::TupleSpace, other::TupleSpace) = self.spaces == other.spaces
# Base.getindex(::Box, index...)
