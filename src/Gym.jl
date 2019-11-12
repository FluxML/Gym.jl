module Gym

using Flux
using Flux.Tracker

#Spaces
include("Spaces/Space.jl")
using .Space
export sample

using Requires

@init @require Gtk="4c0ca9eb-093a-5379-98c5-f87ac0bbbf44" using Gtk

include("Envs/registry.jl")
export make, register,        	     		# Registry functions
       EnvWrapper, reset!, step!, state,
       trainable, game_over, render!, testmode!  # Environment interaction functions

end #module
