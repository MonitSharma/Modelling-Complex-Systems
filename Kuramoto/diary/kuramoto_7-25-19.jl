# kuramoto_7-25-19.jl
#
# Continuing with our research. Trying to mix some cool new literate
# programming techniques in today, too.

#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#

using Plots, DifferentialEquations, BenchmarkTools

#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#

# It takes me a while to get going sometimes, because I use a lot of the
# first part of my day for things like reviewing flashcards of common
# programs I like to use. Once I have all that in place, though, watch
# out -- I'll be a serious force to be reckoned with.

#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#

# Today, I"m going to take a bit and actually read through the Julia
# documentation. I already have enough programming knowledge to do a
# good job working in it, but it's probably not a bad idea to give it
# some of its own time of day as well. These things can be... finicky.

#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#

# Oh, interesting. UTF-8 is allowed in the names of things.

const ϵ = 0.000002
const δ = 0.000001

function f()
    println(ϵ)
    println(δ)
end

f()

#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#

# I did basically no research today, but I *did* learn a lot about the Julia language. I'll pick up again tomorrow starting from
#
# https://docs.julialang.org/en/v1/manual/strings/#Unicode-and-UTF-8-1
#
# 🙂

#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#
