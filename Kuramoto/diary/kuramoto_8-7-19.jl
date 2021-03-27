# kuramoto_8-7--19.jl

# Plots takes about 8 seconds, and DifferentialEquations
# about 25, to load in.

@time using BenchmarkTools
@time using Plots
@time using DifferentialEquations

plot_dir = "./diary/images/"

# First, let's grab our previous Kuramoto code, and modify
# it so it doesn't wrap around S_1 again.

function KuramotoModel(N, K, ω_nat, wrapS1=false)
    @assert(N==size(ω_nat)[1], "number of oscillators != N")

    function Kuramoto(dθ, θ, p, t)
        for i in 1:N
            if wrapS1
                θ[i] = mod2pi(θ[i])
            end

            stabilizers = map(θ_j -> sin(θ_j - θ[i]), θ)
            stabilizing_term = (K / N) * sum(stabilizers)
            dθ[i] = ω_nat[i] + stabilizing_term

            if wrapS1
                θ[i] = mod2pi(θ[i])
            end
        end
    end

    return Kuramoto
end

# Scheiss, I completely forget how this code worked again.
# Glad I have notes.

tspan = (0.0, 10.0) # Time span.

ω_n = [1.0          # Natural frequencies of the oscs.
       2.0
       5.0
       1.0
       0.5]

K5_no_wrap = KuramotoModel(5, 1.0, ω_n)
θ_init = [0.0
          0.0
          0.0
          0.0
          0.0]

prob = ODEProblem(K5_no_wrap, θ_init, tspan)

@time solution = solve(prob)

plot!(title = "5 Kuramoto modelled oscillators")

plot(solution.t, solution.u)

# Together, these two take about half a minute together.

png(string(plot_dir, "8-7-19_k5-no-wrap_01.png"))


#----------------------------------------------------------#


# Next question: How do I take the solution and wrap it
# around S_1 correctly?

# If we naively modulate it by 2pi, we'll probably lose the
# correct curving on the plot that makes it clear to see
# what's going on. On the other hand, if we modulate inside
# the ODE itself, we're stuck with fixed timesteps.
