module Gym

using Flux
using Flux.Tracker

using Reexport

#Spaces
include("Spaces/Space.jl")
@reexport using .Space

# Renderer
include("Envs/vis/utils.jl")
export Ctx

include("Envs/registry.jl")
export make, register,        	     		# Registry functions
       EnvWrapper, reset!, step!, state, 
       trainable, game_over, render, render!, testmode!  # Environment interaction functions

end #module
