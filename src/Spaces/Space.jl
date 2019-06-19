module Space

using Zygote: @nograd

export sample

abstract type AbstractSpace end

include("box.jl")
include("discrete.jl")
include("tuple-space.jl")
include("dict-space.jl")
include("multi-binary.jl")
include("multi-discrete.jl")

@nograd contains
Base.in(x, space_obj::AbstractSpace) = contains(x, space_obj)
Base.size(space_obj::AbstractSpace) = space_obj.shape
end #module
