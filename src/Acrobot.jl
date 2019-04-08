import Flux.Tracker
"""
Copyright 2013, RLPy http://acl.mit.edu/RLPy
Credit: Alborz Geramifard, Robert H. Klein, Christoph Dann,
               William Dabney, Jonathan P. How
License: "BSD 3-Clause"
Author: "Christoph Dann <cdann@cdann.de>"
"""
mutable struct AcrobotEnv
    viewer
    observation_space::Box
    action_space::Discrete
    state
    dt::Float32
    LINK_LENGTH_1::Float32  # [m]
    LINK_LENGTH_2::Float32  # [m]
    LINK_MASS_1::Float32  # [kg] mass of link 1
    LINK_MASS_2::Float32  # [kg] mass of link 2
    LINK_COM_POS_1::Float32  # [m] position of the center of mass of link 1
    LINK_COM_POS_2::Float32  # [m] position of the center of mass of link 2
    LINK_MOI::Float32  # moments of intertia for both links
    MAX_VEL_1::Float32
    MAX_VEL_2::Float32
    AVAIL_TORQUE::Array{Float32, N} where N
    torque_noise_max::Float32
    book_or_nips::String
end


function AcrobotEnv()
    dt = 2f-1
    LINK_LENGTH_1 = 1f0
    LINK_LENGTH_2 = 1f0
    LINK_MASS_1 = 1f0
    LINK_MASS_2 = 1f0
    LINK_COM_POS_1 = 5f-1
    LINK_COM_POS_2 = 5f-1
    LINK_MOI = 1f0

    MAX_VEL_1 = Float32(4 * pi)
    MAX_VEL_2 = Float32(9 * pi)

    AVAIL_TORQUE = [-1f0, 0f0, 1f0]
    torque_noise_max = 0f0

    # use dynamics equations from the nips paper or the book
    book_or_nips = "book"
    # action_arrow = nothing
    # domain_fig = nothing
    # actions_num = 3

    viewer = nothing
    high = [1f0, 1f0, 1f0, 1f0, MAX_VEL_1, MAX_VEL_2] #//
    low = -high
    observation_space = Box(low, high, Float32)
    action_space = Discrete(3)
    state = nothing

    AcrobotEnv(viewer, observation_space, action_space, state, dt, LINK_LENGTH_1,
               LINK_LENGTH_2, LINK_MASS_1, LINK_MASS_2, LINK_COM_POS_1, LINK_COM_POS_2,
               LINK_MOI, MAX_VEL_1, MAX_VEL_2, AVAIL_TORQUE, torque_noise_max, book_or_nips)
end


function reset!(env::AcrobotEnv)
    env.state = param(rand(Float32, 4) * 2f-1 .- 1f-1)
    return _get_ob(env)
end

#=
function custom_reset!(env::AcrobotEnv, args=[-0.04616826f0, -0.04653378f0,  0.07321809f0, -0.04461966f0])
    env.state = param(args)
    return _get_ob(env)
end
=#

function step!(env::AcrobotEnv, action)
    s = env.state
    torque = env.AVAIL_TORQUE[action]

    # Add noise to the force action
    env.torque_noise_max > 0 && (torque += param(env.torque_noise_max * (2rand(Float32) - 1)))

    # Now, augment the state with our force action so it can be passed to _dsdt
    s_augmented = vcat(s, torque)


    ns = rk4(env, _dsdt, s_augmented, [0, env.dt])
    # only care about final timestep of integration returned by integrator
    ns = ns[end, :]
    ns = ns[1:4]  # omit action
    ns.data[1] = wrap(ns[1], -pi, pi).data
    ns.data[2] = wrap(ns[2], -pi, pi).data
    ns.data[3] = bound(ns[3], -env.MAX_VEL_1, env.MAX_VEL_2).data
    ns.data[4] = bound(ns[4], -env.MAX_VEL_1, env.MAX_VEL_2).data
    env.state = ns
    terminal = _terminal(env)
    reward = !all(terminal) ? -1f0 : 0f0

    return _get_ob(env), reward, terminal, Dict()
end


function _get_ob(env::AcrobotEnv)
    s = env.state
    return vcat(cos.(s[1:1]), sin.(s[1:1]), cos.(s[2:2]), sin.(s[2:2]), s[3:3], s[4:4])
end


function _terminal(env::AcrobotEnv)
    s = env.state
    return (cos.(s[1:1])-cos.(s[2:2]+s[1:1])) .> 1f0
end


function _dsdt(env::AcrobotEnv, s_augmented, t)
    m1 = env.LINK_MASS_1
    m2 = env.LINK_MASS_2
    l1 = env.LINK_LENGTH_1
    lc1 = env.LINK_COM_POS_1
    lc2 = env.LINK_COM_POS_2
    I1 = env.LINK_MOI
    I2 = env.LINK_MOI
    g = 98f-1
    a = s_augmented[end:end]
    s = s_augmented[1:end-1]
    theta1 = s[1:1]
    theta2 = s[2:2]
    dtheta1 = s[3:3]
    dtheta2 = s[4:4]

    d1 = m1 * lc1^2 .+ m2 * (l1^2 .+ lc2^2 .+ 2l1 * lc2 * cos.(theta2)) .+ I1 .+ I2

    d2 = m2 * (lc2^2 .+ l1 * lc2 * cos.(theta2)) .+ I2

    phi2 = m2 * lc2 * g * cos.(theta1 .+ theta2 .- pi/2f0)

    phi1 = - m2 * l1 * lc2 * dtheta2.^2 .* sin.(theta2) .-
            2 * m2 * l1 * lc2 * dtheta2 .* dtheta1 .* sin.(theta2) .+
            (m1 * lc1 + m2 * l1) * g * cos.(theta1 .- Float32(pi) / 2) .+ phi2

    if env.book_or_nips == "nips"
        # the following line is consistent with the description in the paper
        ddtheta2 = (a .+ d2./d1 .* phi1 .- phi2) ./
                    (m2 .* lc2^2 .+ I2 .- d2.^2 ./d1)
    else
        # the following line is consistent with the java impelemtation and the
        # book
        ddtheta2 = (a .+ d2 ./ d1 .* phi1 .- m2 .* l1 .* lc2 .* dtheta1.^2 .* sin.(theta2) .-phi2) ./
                    (m2 .* lc2^2 .+ I2 .- d2.^2 ./ d1)
    end
    ddtheta1 = -(d2 .* ddtheta2 .+ phi1) ./ d1

    return vcat(dtheta1, dtheta2, ddtheta1, ddtheta2, 0f1)
end

"""
x : a scalar
m : minimum possible value in range
M : maximum possible value in range
Wraps ``x`` so m <= x <= M; but unlike ``bound()`` which truncates,
``wrap()`` wraps x around the coordinate system defined by m, M.\n
For example, m = -180, M = 180 (degrees), x = 360 --> returns 0.
"""
function wrap(x, m, M)
    diff = M - m
    while x > M
        x -= diff
    end
    while x < m
        x += diff
    end
    return x
end

"""
x : scalar
Either have m as scalar, so bound(x, m, M) which returns m <= x <= M *OR*
have m as length 2 vector, bound(x, m, <IGNORED>) returns m[0] <= x <= m[1].
"""
function bound(x, m, M=nothing)

    if isnothing(M)
        M = m[2]
        m = m[1]
    end
    return min(max(x, m), M)
end

"""

y0 : initial state vector
t : sample times
derivs : returns the derivative of the system and has the
         signature ``dy = derivs(yi, ti)``
args : additional arguments passed to the derivative function
kwargs : additional keyword arguments passed to the derivative function
"""
function rk4(env::AcrobotEnv, derivs, y0, t, args...; kwargs...)
    yout = param(zeros(Float32, length(t), length(y0)))
    yout.data[1, :] = y0.data

    for i=1:(length(t)-1)
        thist = t[i]
        dt = t[i+1] - thist
        dt2 = dt / 2f0
        y0 = yout[i, :]

        k1 = derivs(env, y0, thist, args...; kwargs...)
        k2 = derivs(env, y0 .+ dt2 * k1, thist .+ dt2, args...; kwargs...)
        k3 = derivs(env, y0 .+ dt2 * k2, thist .+ dt2, args...; kwargs...)
        k4 = derivs(env, y0 .+ dt * k3, thist .+ dt, args...; kwargs...)

        yout.data[i+1, :] = (y0 .+ dt / 6f0 * (k1 .+ 2 * k2 .+ 2 * k3 .+ k4)).data

    end
    return yout
end

show(io::IO, env::AcrobotEnv) = print(io, "AcrobotEnv")
