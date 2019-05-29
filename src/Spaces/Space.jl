module Space

export sample

abstract type AbstractSpace end

include("box.jl")
include("discrete.jl")
include("tuple-space.jl")
include("dict-space.jl")
include("multi-binary.jl")
include("multi-discrete.jl")

Base.in(x, space_obj::AbstractSpace) = contains(x, space_obj)
end #module
