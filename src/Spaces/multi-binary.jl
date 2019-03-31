
#TODO: seed, copy

mutable struct MultiBinary <: AbstractSpace
    n::Int
    dtype::DataType
    shape::Tuple
    MultiBinary(n::Int) = new(n, BitArray{1}, (n, ))
end

sample(self::MultiBinary) = (self.dtype)(rand(0:1, self.n))

contains(self::MultiBinary, x) = all((x .== 0) .| (x .== 1))

Base.:(==)(self::MultiBinary, other::MultiBinary) = self.n == other.n
