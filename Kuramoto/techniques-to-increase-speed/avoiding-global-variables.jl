# avoiding-global-variables.jl

# Let's start with a little demonstration of the differences in speed
# between two basic things. We're going to be using @time to show this
# off.

# BUT FIRST.

# We need to talk about the fuckery that is... Global scope.

########################################################################

println("------------------------")

# Julia's global scoping is freaking weird. For example, this code works
# as-is.

x = 1

for i in 1:3
    println(x, "\t", i)
end

println("----------------")

# # *This* code, meanwhile, will wig out on you if you uncomment it. It'll
# # give you an "UndefVarError: x not defined", at least at the time of
# # writing.
#
# x = 2
#
# for i in 1:3
#     x = x + 2
#     println(x, "\t", i)
# end
#
# # Fucking. Infuriating.

# What's going on here? It turns out that when you open up a loop like a
# for loop, Julia's scope rules get weirdly exclusionary about
# everything. If you want to use that x, you need to first pull it in
# with an explicit "global x" line. Like so:

x = 3

for i in 1:3
    global x
    x = x + 3
    println(x, "\t", i)
end

# And that works just fine. It's one of the most annoying gotchas on the
# planet.

# Except you NEVER EVER EVER want to do that, because global variables
# 💩 the 🛌 in Julia. Let's watch!

println("------------------------")

########################################################################

println("-.-.-.-.-.-.-.-.-.-.-.-.")

# Here is a loop that does something trivially simple: It adds 1 to p, 1,000,000 times.

begin
    p = 1
    for i in 1:1000000
        global p           # REMEMBER THIS PART OR SUFFER <==
        p += 1
    end
end

# And here is that exact same code, wrapped inside a function call.

function f()
    begin
        p = 1
        for i in 1:1000000  # NO GLOBAL NEEDED ANYMORE, GOOD RIDDANCE.
            p += 1
        end
    end
end

f()

# You would expect these two to have roughly the same performance,
# right? Oh, you poor, naive fool. If only you knew.

println("-.-.-.-.-.-.-.")

# Let's bust out the @time macro, which has been nicely baked into the
# Base package, and see how the two code blocks *actually* turn out.

@time begin
    p = 1
    for i in 1:1000000
        global p           # REMEMBER THIS PART OR SUFFER <==
        p += 1
    end
end

function f()
    begin
        p = 1
        for i in 1:1000000  # NO GLOBAL NEEDED ANYMORE, GOOD RIDDANCE.
            p += 1
        end
    end
end

@time f()

println("-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.")

# On my machine, the second one is almost an *order of magnitude* faster
# than the first.

# Not convinced? Let's ramp things up to the point where we human beings
# can actually feel the difference. This code runs 10,000,000 times.

@time begin
    p = 1
    for i in 1:10000000
        global p           # REMEMBER THIS PART OR SUFFER <==
        p += 1
    end
end

function f()
    begin
        p = 1
        for i in 1:10000000  # NO GLOBAL NEEDED ANYMORE, GOOD RIDDANCE.
            p += 1
        end
    end
end

@time f()

println("-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.")
# And this code? 100,000,000 times.

@time begin
    p = 1
    for i in 1:100000000
        global p           # REMEMBER THIS PART OR SUFFER <==
        p += 1
    end
end

function f()
    begin
        p = 1
        for i in 1:100000000  # NO GLOBAL NEEDED ANYMORE, GOOD RIDDANCE.
            p += 1
        end
    end
end

@time f()

# Take a look at the @time performance for all those little
# global assignments. They keep going up. On my machine,
# they're going up from 0.05 seconds, to 0.5 seconds, to 5
# whole seconds. The allocations go up from 1 M allocations,
# to 10 M allocations, to 100 M allocations.

# Meanwhile, the function takes almost the same amount of time *and* allocations every single time.

# Global variables are WACK. Avoid them if you at all can.

########################################################################

println("====================================")
println("TIME TO IMPORT PLOTS and DIFF EQ ::")
# Alright, big woop. What does that have to do with what we're doing?

# I'm glad you asked. Let's look at some example code.

@time using Plots
@time using DifferentialEquations

########################################################################

println("❤❤❤❤❤❤❤❤❤❤❤❤❤❤❤❤❤")
# Here's a Lorenz system. As it is, it's taking me about 1 second to run
# on my system, with @time.

function lorenz(du,u,p,t)
     du[1] = 10.0*(u[2]-u[1])
     du[2] = u[1]*(28.0-u[3]) - u[2]
     du[3] = u[1]*u[2] - (8/3)*u[3]
     return du
end

u0 = [1.0;0.0;0.0]
tspan = (0.0,1000.0)
prob = ODEProblem(lorenz,u0,tspan)
@time sol = solve(prob)

plot(sol)
png("./techniques-to-increase-speed/plots/lorenz-1")

println("====================")

# Here's a different way to code it without any assignment.

function lorenz(u,p,t)
     return [10.0*(u[2]-u[1]),
             u[1]*(28.0-u[3]) - u[2],
             u[1]*u[2] - (8/3)*u[3]]
end

u0 = [1.0;0.0;0.0]
tspan = (0.0,1000.0)
prob = ODEProblem(lorenz,u0,tspan)
@time sol = solve(prob)

plot(sol)
png("./techniques-to-increase-speed/plots/lorenz-2")

# Here, we have NO ASSIGNMENTS WHATSOEVER. And the code is almost 20
# times faster as a result. If you compare the two PNGs side by side,
# you can see that they are the same thing.

# Let's try this same technique with some of the code we wrote just
# earlier today, and see if we can't wring some performance benefits out
# of the fuckers.

########################################################################

# Here's our original KuramotoModel. Very stateful.

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
# This model has an enormous amount of overhead. For 2 measly
# oscillators, we ended up with 728 MB and over 14 million allocations.
# We can do better. We *must* do better.

# But how? First, let's generate a picture just so we know we aren't
# messing anything up. Fundamentally, this is a refactoring project.

println(":::::::::::::::::::::::::::::::::")

tspan = (0.0, 60.0)

K2 = KuramotoModel(2, 1.0, [1.0, 1.0])

theta0 = [0.0, pi]
prob = ODEProblem(K2, theta0, tspan)

@time sol = solve(prob, Euler(), dt=0.00001) # Yes, Euler() is important.
@time plot(sol)

png("./techniques-to-increase-speed/plots/naive-2-osc-solution_1")

# On a virgin run, plotting all that data takes almost 20 seconds, and
# solving takes almost 8. Let's see if we can do better by paring down
# the state stuff.

########################################################################

# First off, let's try to pare out the stabilizers stuff in there, as well as one of the mod2pi assignments.

function KuramotoModel2(N, K, omega)
    @assert(N==size(omega)[1], "number of oscillators != N")

    function Kuramoto(dtheta, theta, p, t)
        for i in 1:N
            dtheta[i] = omega[i] + (K / N) * sum(map(theta_j -> sin(theta_j - theta[i]), theta))
            theta[i] = mod2pi(theta[i])
        end
    end

    return Kuramoto
end

println(":::::::::::::::::::::::::::::::::")

tspan = (0.0, 60.0)

K2 = KuramotoModel2(2, 1.0, [1.0, 1.0])

theta0 = [0.0, pi]
prob = ODEProblem(K2, theta0, tspan)

@time sol = solve(prob, Euler(), dt=0.00001) # Yes, Euler() is important.
@time plot(sol)

png("./techniques-to-increase-speed/plots/naive-2-osc-solution_2")

# Any luck? Em... Yea, it seems like we got a slight performance
# increase. From 15 to 9 seconds. Not earth-shattering, but reasonable.

########################################################################

# Okay, let's rerun the whole script virgin and see what happens.

# Oh, wait. Actually, the second one seems to run with slightly *worse*
# time. And a whole lot more garbage collection going on. Well... Let's
# see if we can't keep going, aha.

function KuramotoModel3(N, K, omega)
    @assert(N==size(omega)[1], "number of oscillators != N")
    # Let's try initializing dtheta within the function, instead of
    # having it as an explicit argument.

    function Kuramoto(theta, p, t)
        dtheta = Array{Float64}(undef, N)
        for i in 1:N
            dtheta[i] = omega[i] + (K / N) * sum(map(theta_j -> sin(theta_j - theta[i]), theta))
            theta[i] = mod2pi(theta[i])
        end
        return dtheta
    end

    return Kuramoto
end


println(":::::::::::::::::::::::::::::::::")

tspan = (0.0, 60.0)

K2 = KuramotoModel3(2, 1.0, [1.0, 1.0])

theta0 = [0.0, pi]
prob = ODEProblem(K2, theta0, tspan)

@time sol = solve(prob, Euler(), dt=0.00001) # Yes, Euler() is important.
@time plot(sol)

png("./techniques-to-increase-speed/plots/naive-2-osc-solution_3")

#######################################################

# How does our virgin run look now?

# Ah, christ. It looks like we're actually getting even WORSE now as
# time goes on. What gives? Well... At least our plots all look the
# same.

#######################################################

# Let's try moving the dtheta out and see if that makes any difference.



function KuramotoModel4(N, K, omega)
    @assert(N==size(omega)[1], "number of oscillators != N")
    # Let's try initializing dtheta within the function, instead of
    # having it as an explicit argument.

    dtheta = Array{Float64}(undef, N)

    function Kuramoto(theta, p, t)
        for i in 1:N
            dtheta[i] = omega[i] + (K / N) * sum(map(theta_j -> sin(theta_j - theta[i]), theta))
            theta[i] = mod2pi(theta[i])
        end
        return dtheta
    end

    return Kuramoto
end


println(":::::::::::::::::::::::::::::::::")

tspan = (0.0, 60.0)

K2 = KuramotoModel4(2, 1.0, [1.0, 1.0])

theta0 = [0.0, pi]
prob = ODEProblem(K2, theta0, tspan)

@time sol = solve(prob, Euler(), dt=0.00001) # Yes, Euler() is important.
@time plot(sol)

png("./techniques-to-increase-speed/plots/naive-2-osc-solution_4")

#######################################################

# I think I might have misunderstood what he meant by "non-allocating".
# Let me try a different approach.


function KuramotoModel5(N, K, omega)
    @assert(N==size(omega)[1], "number of oscillators != N")

    function Kuramoto!(dtheta, theta, p, t)
        for i in 1:N
            dtheta[i] = omega[i] + (K / N) * sum(map(theta_j -> sin(theta_j - theta[i]), theta))
            theta[i] = mod2pi(theta[i])
        end
        return dtheta
    end

    return Kuramoto!
end


println(":::::::::::::::::::::::::::::::::")

tspan = (0.0, 60.0)

K2 = KuramotoModel5(2, 1.0, [1.0, 1.0])

theta0 = [0.0, pi]
prob = ODEProblem(K2, theta0, tspan)

@time sol = solve(prob, Euler(), dt=0.00001) # Yes, Euler() is important.
@time plot(sol)

png("./techniques-to-increase-speed/plots/naive-2-osc-solution_5")

#######################################################

# There is a bit of a speed-up! 🙂 Plotting takes
# longer, however. Let's try another virgin run.

# Yes. According to this, the change we made just now puts us
# comfortable back at around the same place we were with KuramotoModel2.
# KuramotoModel the original is still the fastest though, lol.




function KuramotoModel6(N, K, omega)
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
# This model has an enormous amount of overhead. For 2 measly
# oscillators, we ended up with 728 MB and over 14 million allocations.
# We can do better. We *must* do better.

# But how? First, let's generate a picture just so we know we aren't
# messing anything up. Fundamentally, this is a refactoring project.

println(":::::::::::::::::::::::::::::::::")

tspan = (0.0, 60.0)

K2 = KuramotoModel6(2, 1.0, [1.0, 1.0])

theta0 = [0.0, pi]
prob = ODEProblem(K2, theta0, tspan)

@time sol = solve(prob, Euler(), dt=0.00001) # Yes, Euler() is important.
@time plot(sol)

png("./techniques-to-increase-speed/plots/naive-2-osc-solution_6")
########################################################################

# Let's actually try hard-coding it, and see what happens when we do.

function Kuramoto(du, u, p, t)
    u[1] = mod2pi(u[1])
    u[2] = mod2pi(u[2])
    du[1] = 1.0 + (1.0/2.0) * sin(u[2] - u[1])
    du[2] = 1.0 + (1.0/2.0) * sin(u[1] - u[2])
end

tspan = (0.0, 60.0)

K2 = Kuramoto

theta0 = [0.0, pi]
prob = ODEProblem(K2, theta0, tspan)

@time sol = solve(prob, Euler(), dt=0.00001) # Yes, Euler() is important.
@time plot(sol)

png("./techniques-to-increase-speed/plots/naive-2-osc-solution_7")

# Yea, I hate to admit it but this in-place form is the way to fuckin'
# go. OOF.

########################################################################

# Let's move on to the next tip: STACK allocation.

using StaticArrays

function Kuramoto_Static(u, p, t)
    dx = 1.0 + (1.0/2.0) * sin(u[2] - u[1])
    dy = 1.0 + (1.0/2.0) * sin(u[1] - u[2])
    @SVector [dx, dy]
end

tspan = (0.0, 60.0)

K2 = Kuramoto_Static

theta0 = [0.0, pi]
prob = ODEProblem(K2, theta0, tspan)

@time sol = solve(prob, Euler(), dt=0.00001) # Yes, Euler() is important.
@time plot(sol)

png("./techniques-to-increase-speed/plots/naive-2-osc-solution_8")
