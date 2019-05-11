module Gym

using Flux
using Flux.Tracker

using Reexport

#Spaces
include("Spaces/Space.jl")
@reexport using .Space

include("Envs/registry.jl")
export make, register,        	     		# Registry functions
       EnvWrapper, reset!, step!, state,
       trainable, game_over, render!, testmode!  # Environment interaction functions

end #module