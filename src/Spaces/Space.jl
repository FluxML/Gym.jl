module Space

<<<<<<< HEAD
export sample
=======


export sample,
    Box, Discrete, TupleSpace, DictSpace, MultiBinary, MultiDiscrete
>>>>>>> a25c5d0ecd3f032dc2c0bd7cb0b64457c5226c93

abstract type AbstractSpace end

include("box.jl")
include("discrete.jl")
include("tuple-space.jl")
include("dict-space.jl")
include("multi-binary.jl")
include("multi-discrete.jl")

Base.in(x, space_obj::AbstractSpace) = contains(space_obj, x)
end #module
