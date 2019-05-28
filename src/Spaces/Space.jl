module Space



export sample,
    Box, Discrete, TupleSpace, DictSpace, MultiBinary, MultiDiscrete

abstract type AbstractSpace end

include("box.jl")
include("discrete.jl")
include("tuple-space.jl")
include("dict-space.jl")
include("multi-binary.jl")
include("multi-discrete.jl")

Base.in(x, space_obj::AbstractSpace) = contains(space_obj, x)
end #module
