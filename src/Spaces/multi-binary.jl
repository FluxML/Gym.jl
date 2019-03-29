
#TODO: seed, copy
boolor(x::Bool, y::Bool) = x || y

mutable struct MultiBinary <: AbstractSpace
    n::Int
    dtype::DataType
    shape::Tuple
    MultiBinary(n::Int) = new(n, Int, (n, ))
end

sample(self::MultiBinary) = (self.dtype).(rand(0:1, self.n))

contains(self::MultiBinary, x) = all(boolor.(x .== 0, x .== 1))

Base.:(==)(self::MultiBinary, other::MultiBinary) = return self.n == other.n
