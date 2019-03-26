"""
{0,1,...,n-1}

Example usage:
self.observation_space = Discrete(2)
"""
mutable struct Discrete
    n::Int
    dtype::DataType

    Discrete(N::Int) = new(N, Int64)
end

sample(self::Discrete) = rand(0:self.n-1)

function contains(self::Discrete, x::Union{Number, Array})
    as_int::Union{Number, Array, Nothing} = nothing
    try
        as_int = Int.(x)
    catch InexactError
        return false
    end
    return all(0 .<= as_int .< self.n)
end
