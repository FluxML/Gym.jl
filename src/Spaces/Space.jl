module Space



export sample, contains,
    Box, Discrete, TupleSpace, DictSpace, MultiBinary, MultiDiscrete

abstract type AbstractSpace end

include("box.jl")
include("discrete.jl")
include("tuple-space.jl")
include("dict-space.jl")
include("multi-binary.jl")
include("multi-discrete.jl")

Base.in(x, self::AbstractSpace) = contains(self, x)
end #module
