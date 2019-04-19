include("registration.jl")

# Classic Control
#=============================================================================#
register("CartPole-v0",
         :CartPoleEnv,
         "/classic_control/CartPole.jl",
	     max_episode_steps=200,
		 reward_threshold=195.0)

register("CartPole-v1",
         :CartPoleEnv,
         "/classic_control/CartPole.jl",
	     max_episode_steps=500,
		 reward_threshold=475.0)

register("Pendulum-v0",
         :PendulumEnv,
         "/classic_control/Pendulum.jl",
		 max_episode_steps=200)

register("MountainCarContinuous-v0",
         :Continuous_MountainCarEnv,
         "/classic_control/Continuous-MountainCar.jl",
		 max_episode_steps=999,
		 reward_threshold=90.0)
