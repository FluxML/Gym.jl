#TODO : seed, copy
"""
{0,1,...,n-1}

Example usage:
discrete_obj.observation_space = Discrete(2)
"""
mutable struct Discrete <: AbstractSpace
    n::Int
    dtype::DataType

    Discrete(N::Int) = new(N, Int64)
end

sample(discrete_obj::Discrete) = rand(1:discrete_obj.n)

function contains(x::Union{Number, Array}, discrete_obj::Discrete)
    as_int::Union{Number, Array, Nothing} = nothing
    try
        as_int = Int.(x)
    catch InexactError
        return false
    end
    return all(1 .<= as_int .<= discrete_obj.n)
end

Base.:(==)(discrete_obj::Discrete, other::Discrete) = discrete_obj.n == other.n

Base.length(discrete_obj::Discrete) = discrete_obj.n
