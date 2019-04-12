module Gym

using Flux
using Flux.Tracker

#import Base.show

#Spaces
include("Spaces/Space.jl")
using .Space
export sample,
    Box, Discrete, TupleSpace, DictSpace, MultiBinary, MultiDiscrete

#Environments
#export CartPoleEnv, PendulumEnv, Continuous_MountainCarEnv

# Renderer
include("Envs/vis/utils.jl")
export Ctx

#include("Envs/classic_control/CartPole.jl")
#include("Envs/classic_control/Pendulum.jl")
#include("Envs/classic_control/Continuous-MountainCar.jl")

end #module
