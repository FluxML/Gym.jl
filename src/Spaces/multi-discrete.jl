#TODO: seed

"""
- The multi-discrete action space consists of a series of discrete action spaces with different number of actions in eachs
- It is useful to represent game controllers or keyboards where each key can be represented as a discrete action space
- It is parametrized by passing an array of positive integers specifying number of actions for each discrete action space

Note: A value of 0 always need to represent the NOOP action.

e.g. Nintendo Game Controller
- Can be conceptualized as 3 discrete action spaces:

    1) Arrow Keys: Discrete 5  - NOOP[0], UP[1], RIGHT[2], DOWN[3], LEFT[4]  - params: min: 0, max: 4
    2) Button A:   Discrete 2  - NOOP[0], Pressed[1] - params: min: 0, max: 1
    3) Button B:   Discrete 2  - NOOP[0], Pressed[1] - params: min: 0, max: 1

- Can be initialized as

    MultiDiscrete([ 5, 2, 2 ])
    or MultiDiscrete((5, 2, 3))

"""
mutable struct MultiDiscrete <: AbstractSpace
    nvec::NTuple{N, UInt32} where N
    shape::Tuple
end

function MultiDiscrete(nvec::NTuple{N, Int} where N) # nvec: vector of counts of each categorical variable
    @assert all(nvec .> 0) "nvec (counts) have to be positive"
    MultiDiscrete(nvec, nvec)
end

MultiDiscrete(nvec::Array{Int, 1}) = MultiDiscrete(Tuple(nvec))

sample(multidisc_obj::MultiDiscrete) = [UInt32(rand(1:counts)) for counts in multidisc_obj.nvec]

contains(x, multidisc_obj::MultiDiscrete) = all(0 .< x .<= multidisc_obj.nvec)

Base.:(==)(multidisc_obj::MultiDiscrete, other::MultiDiscrete) = multidisc_obj.nvec == other.nvec
