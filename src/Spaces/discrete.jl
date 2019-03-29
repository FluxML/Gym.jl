#TODO : seed, copy
"""
{0,1,...,n-1}

Example usage:
self.observation_space = Discrete(2)
"""
mutable struct Discrete <: AbstractSpace
    n::Int
    dtype::DataType

    Discrete(N::Int) = new(N, Int64)
end

sample(self::Discrete) = rand(1:self.n)

function contains(self::Discrete, x::Union{Number, Array})
    as_int::Union{Number, Array, Nothing} = nothing
    try
        as_int = Int.(x)
    catch InexactError
        return false
    end
    return all(1 .<= as_int .<= self.n)
end

Base.:(==)(self::Discrete, other::Discrete) = self.n == other.n

Base.length(self::Discrete) = self.n
