module Gym

using Flux
using Flux.Tracker

import Base.show

export step!, reset!, Ctx, render

#Spaces
include("Spaces/Space.jl")
using .Space
export sample,
    Box, Discrete, TupleSpace, DictSpace, MultiBinary, MultiDiscrete
#Environments
export CartPoleEnv, PendulumEnv, Continuous_MountainCarEnv

include("vis/utils.jl")
include("CartPole.jl")
include("Pendulum.jl")
include("Continuous-MountainCar.jl")

end #module
