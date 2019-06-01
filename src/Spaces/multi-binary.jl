
#TODO: seed, copy

mutable struct MultiBinary <: AbstractSpace
    n::Int
    dtype::DataType
    MultiBinary(n::Int) = new(n, BitArray{1})
end

sample(multibin_obj::MultiBinary) = (multibin_obj.dtype)(rand(0:1, multibin_obj.n))

contains(x, multibin_obj::MultiBinary) = all((x .== 0) .| (x .== 1))

Base.:(==)(multibin_obj::MultiBinary, other::MultiBinary) = multibin_obj.n == other.n

Base.size(mutlibin_obj::MultiBinary) = (multibin_obj.n, )
