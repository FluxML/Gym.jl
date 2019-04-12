include("registration.jl")

# Classic Control
#=============================================================================#
register("CartPole",
         :CartPoleEnv,
         "/classic_control/CartPole.jl")

register("Pendulum",
         :PendulumEnv,
         "/classic_control/Pendulum.jl")

register("Continuous_MountainCar",
         :Continuous_MountainCarEnv,
         "/classic_control/Continuous-MountainCar.jl")
