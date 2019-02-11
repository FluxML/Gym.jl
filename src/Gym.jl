module Gym

using Flux
using Flux.Tracker
using CuArrays

import Base.show

export step!, reset!, Ctx, render

#Environments
export CartPoleEnv, PendulumEnv

include("CartPole.jl")
include("Pendulum.jl")

end #module
