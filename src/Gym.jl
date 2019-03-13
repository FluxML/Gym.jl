module Gym

using Flux
using Flux.Tracker

import Base.show

export step!, reset!, Ctx, render

#Environments
export CartPoleEnv, PendulumEnv, Continuous_MountainCarEnv

include("vis/utils.jl")
include("CartPole.jl")
include("Pendulum.jl")
include("Continuous-MountainCar.jl")

end #module
