# Let's begin, shall we?

# I'm going to begin with just 3 oscillators, because
# I haven't touched differential equations with Julia
# in quite a while. Hopefully the code will generalize.

#######################################################################
# First, of course, we're going to need our tools.


# To get these, you go into the REPL, type a
#
# ]
#
# at which point it'll change from "julia>" to "pkg>".
#
# Then you can just write in
#
# add Plots
# add DifferentialEquations
#
# or whatever other packages we end up using.

using Plots
using DifferentialEquations

# I'm being super verbose here so I don't forget anything.
#
# https://en.wikibooks.org/wiki/Introducing_Julia/Modules_and_packages#Modules_and_packages
# ^ source for my info.
########################################################################
# So first I'm just going to implement a system of equations, nothing
# fancy yet.
#
# http://docs.juliadiffeq.org/latest/tutorials/ode_example.html#Example-2:-Solving-Systems-of-Equations-1
#
# to see the example I'm working from.
#
# https://en.wikipedia.org/wiki/Kuramoto_model
#
# First diff eq is what I'm implementing here; might post LaTeX code
# later if I feel like it, and figure out some literate programming
# approach.

# Let's implement the trivial case, of N = 1 single oscillator.


function kuramoto_one(dtheta, theta, p, t)
    dtheta[1] = 1 + (1/3) * (0) # Included as a formality. 😜
end

theta0 = [0.0]
tspan = (0.0, 100.0)
prob = ODEProblem(kuramoto_one,
                  theta0,
                  tspan)

sol = solve(prob)

plot(sol)

# If I've coded this right, we should literally just get a straight line
# for output. Let's see if that happens.
#
# And it does! Now, the question is can we wrap it around 2pi with a
# modulo operation?
#
# It appears not. The default way that DiffEq solves this actually only
# gives us a few data points, since it (correctly) guesses somehow that
# the output is going to be very simple. I wonder if we can adjust that
# somehow.

sol = solve(prob,Tsit5(),reltol=1e-8,abstol=1e-8)

# That didn't work.
# Aha! I see what we're looking for now. We want a "fixed timestep"
# method. The Euler method is the canonical choice, of course.

fixed_timestep=0.1

sol = solve(prob,Euler(),dt=fixed_timestep)

# Now we need to iterate through sol.u and modulo everything by 2pi.
# Oh cool, there's actually an exact mod2pi function in Base.Math --
# which, apparently, doesn't even need to be imported? Okay. I guess
# anything Base.X is already there, and the X is just to keep things
# organized.

for x in sol.u
    print(mod2pi(x[1]), "\n")
    x[1] = mod2pi(x[1])
end

plot(sol)

# Alright, now THAT is what we're looking for. 😄

########################################################################
# Okay, now let's try to implement this cleanly.

function kuramoto_one_cleaned_up(dtheta, theta, p, t)
    dtheta[1] = 1
    theta[1] = mod2pi(theta[1]) # This seems to work fine.
end

theta0 = [0.0]         # For type reasons, the .0 is significant.
tspan = (0.0, 100.0)    # Otherwise Julia expects the exactness of Ints.
prob = ODEProblem(kuramoto_one_cleaned_up, theta0, tspan)
solution = solve(prob, Euler(), dt=0.01)
plot(solution)

# Great.
########################################################################
# Now let's try an N=2 Kuramoto model. Again, hard coding it, because
# I am not super comfortable yet in Julia.

# K is our coupling constant. Raising it will make our values converge
# faster, and it should be a floating point. Setting this to 0.0 means
# no stabilization whatsoever should occur, but so long as it's non-
# negative, it should work fine. (I guess negative would be like, a
# destabilizing force? Haha!)
K = 0.1

# N is the number of oscillators we have paired. It should stay at 2
# for now.
N = 2

# omega_1 and omega_2 are the "natural frequencies" of our two
# oscillators. They can be whatever value you want. Keep them as
# floats, though, just to be safe.
omega_1 = 1.0
omega_2 = 1.0

function kuramoto_two(dtheta, theta, p, t)
    # First, let's make sure our thetas are wrapped around.
    theta[1] = mod2pi(theta[1])
    theta[2] = mod2pi(theta[2])

    # Now, let's implement the actual Diff EQs.
    dtheta[1] = omega_1 + (K / N) * (sin(theta[2] - theta[1]))
    dtheta[2] = omega_2 + (K / N) * (sin(theta[1] - theta[2]))

    # Finally, we'll wrap around again for good measure.
    theta[1] = mod2pi(theta[1])
    theta[2] = mod2pi(theta[2])
end

theta0 = [0.0, 0.0]
tspan = (0.0, 100.0)
prob = ODEProblem(kuramoto_two, theta0, tspan)
solution = solve(prob, Euler(), dt=0.01)
plot(solution)
# And as you can see, the two are exactly the same.
# Which makes sense - they have the same natural frequencies, and
# the same starting positions.
#
# But what if we vary up the initial conditions a bit?
########################################################################
theta0 = [mod2pi(rand()*(2*pi)), mod2pi(rand()*(2*pi))]
tspan = (0.0, 10.0)
prob = ODEProblem(kuramoto_two, theta0, tspan)
solution = solve(prob, Euler(), dt=0.01)
plot(solution)
# Eheheheheh, *now* we start to see it at work. 😈
########################################################################
# Okay, so that's pretty cool. But let's say we wanted to Monte Carlo
# this up. How might we do that?

# That's where things get a bit tricky. I'll have to read up on this.
# http://docs.juliadiffeq.org/latest/features/ensemble.html#Parallel-Ensemble-Simulations-1

# I'll leave it here for tonight.
########################################################################
