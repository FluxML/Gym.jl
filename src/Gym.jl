module Gym

using Flux
using Flux.Tracker

import Base.show

export step!, reset!, Ctx, render

#Spaces
include("Spaces/Space.jl")
using .Space
export sample, contains,
    Box, Discrete, TupleSpace, DictSpace, MultiBinary, MultiDiscrete
#Environments
export CartPoleEnv, PendulumEnv, Continuous_MountainCarEnv, CartPoleEnv1

include("vis/utils.jl")
include("CartPole.jl")
include("CartPole-v1.1.jl")
include("Pendulum.jl")
include("Continuous-MountainCar.jl")

end #module
