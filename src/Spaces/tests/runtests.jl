#TODO: Write more tests

#To run tests, load the Space module first (/src/Spaces/Space.jl)
using Test

abstract type AbstractSpace end

include("box.jl")
include("dict-space.jl")
include("multi-binary.jl")
include("multi-discrete.jl")
include("tuple-space.jl")
include("discrete.jl")

test_case1 = (
    Discrete(3),
    TupleSpace((Discrete(5), Discrete(10))),
    TupleSpace((Discrete(5), Box([0, 0], [1, 5], Float32))),
    TupleSpace((Discrete(5), Discrete(2), Discrete(2))),
    MultiDiscrete([2, 2, 100]),
    DictSpace(Dict("position" => Discrete(5),
                   "velocity" => Box([0, 0], [1, 5], Float32)))
)

test_case2 = (
    (Discrete(3), Discrete(4)),
    (MultiDiscrete([2, 2, 100]), MultiDiscrete([2, 2, 8])),
    (MultiBinary(8), MultiBinary(7)),
    (Box([-10, 0], [10, 10], Float32), Box([-10, 0], [10, 9], Float32)),
    (TupleSpace([Discrete(5), Discrete(10)]), TupleSpace([Discrete(1), Discrete(10)])),
    (DictSpace(Dict("position" => Discrete(5))), DictSpace(Dict("position" => Discrete(4)))),
    (DictSpace(Dict("position" => Discrete(5))), DictSpace(Dict("speed" => Discrete(5)))),
)

@testset "samples are in the same space" begin
    @testset "$space" for space in test_case1
        sample_1 = sample(space)
        sample_2 = sample(space)
        @test contains(space, sample_1)
        @test contains(space, sample_2)
    end
end
#=
@testset "test equality" begin
    @testset "$space" for space in test_case1
        space1 = space
        space2 = copy(space)
        @test space1 == space2
    end
end
=#
@testset "test inequality" begin
    @testset "$spaces" for spaces in test_case2
        space1, space2 = spaces
        @test space1 != space2
    end
end
