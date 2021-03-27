# kuramoto_7-24-19.jl
#
# Back to work.

@time begin
    using Plots
    using DifferentialEquations

    function KuramotoModel(N, K, omega)
        @assert(N==size(omega)[1], "number of oscillators != N")

        function Kuramoto(dtheta, theta, p, t)
            for i in 1:N
                theta[i] = mod2pi(theta[i])

                stabilizers = map(theta_j -> sin(theta_j - theta[i]), theta)
                stabilizing_term = (K / N) * sum(stabilizers)

                dtheta[i] = omega[i] + stabilizing_term

                theta[i] = mod2pi(theta[i])
            end
        end

        return Kuramoto
    end
end
# This code takes about 30 seconds to run on my machine. Oof.

#######################################################################
# Simulate a two-oscillator Kuramoto model, over 60 seconds.

tspan = (0.0, 60.0)

K2 = KuramotoModel(2, 1.0, [1.0, 1.0])

theta0 = [0.0, pi]
prob = ODEProblem(K2, theta0, tspan)

@time sol = solve(prob, Euler(), dt=0.001) # Yes, Euler() is important.
@time plot(sol)

# Success!

# But how long does it take?
# sol = solve(...) takes around 4.2 seconds on my machine, and
# the plotting takes a full 17.7 seconds JESUS CHRIST

# I'm going to see if I can improve this a bit over in the
# techniques-to-increase-speed folder.

#######################################################################
# Simulate a 12-oscillator Kuramoto model, all with natural frequency 1
# radians / second, over 10 seconds.

tspan = (0.0, 10.0)

N = 12;
K = 1.0;

omega_n = Array{Float64}(undef, N)
for i in 1:N
    omega_n[i] = 1.0
end

theta_0 = Array{Float64}(undef, N)
for j in 1:N
    theta_0[j] = mod2pi(j)
        # This is just an easy hack to space these out. ∀ n_1, n_2 ∈ N :
        # n_1 != n_2 ⟹ mod2pi(n_1) != mod2pi(n_2). I got that from...
        # Somewhere. Trust me.
end

K12 = KuramotoModel(N, 1.0, omega_n)

prob = ODEProblem(K12, theta_0, tspan)

@time sol = solve(prob, Euler(), dt=0.0001) # Yes, Euler() is important.
@time plot(sol)
#######################################################################
# How about a *thousand*? 😉

tspan = (0.0, 10.0)

N = 1000;
K = 1.0;

omega_n = Array{Float64}(undef, N)
for i in 1:N
    omega_n[i] = 1.0
end

theta_0 = Array{Float64}(undef, N)
for j in 1:N
    theta_0[j] = mod2pi(j)
        # This is just an easy hack to space these out. ∀ n_1, n_2 ∈ N :
        # n_1 != n_2 ⟹ mod2pi(n_1) != mod2pi(n_2). I got that from...
        # Somewhere. Trust me.
end

K1000 = KuramotoModel(N, 1.0, omega_n)

prob = ODEProblem(K1000, theta_0, tspan)

sol = solve(prob, Euler(), dt=0.0001) # Yes, Euler() is important.
plot(sol)
