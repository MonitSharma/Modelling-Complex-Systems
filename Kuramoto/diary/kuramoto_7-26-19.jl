# kuramoto_7-26-19.jl

# Continuing to read through the Julia documentation.

using BenchmarkTools

#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#


#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#


#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#

str = "∀ x ∈ S : x ∈ T";

println("************")
print("Proof this ran again: \t\t\t\t\t")
println(convert(Int64, trunc(rand()*1000)))
println("String to print: ", str)

println("Idiomatic method:")

for s in str
    print(s)
end
# According to @btime: 606.084 μs (63 allocations: 1.22 KiB)



println("\nInefficient but working method:")



for i = firstindex(str):lastindex(str)
    try
        print(str[i])
    catch
        # Do nothing
    end
end
# According to @btime: 691.052 μs (76 allocations: 1.63 KiB).
# Not a huge difference, but we did like a thousand trials of it,
# so it matters.

println("\nDone")

#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#

# One more @benchmark test, because I love that software.

@benchmark begin
    str = "∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀"
    for s in str
        s
    end
end

@benchmark begin
    str = "∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀"
    i = 1
    for i = firstindex(str):lastindex(str)
        try
            str[i]
        catch
            # Do nothing
        end
    end
end


#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#

# Fun with numpads.

println("Strings to Arrays, 1")

x = "123"
y = "456"
z = "789"

A = [x y z]

display(A)

A_ = [collect(x) collect(y) collect(z)]

display(A_)
A__ = collect.(A)

display(A__)

A___ = collect.(collect.(A))

display(A___)

# Interestingly, this displays very different behavior than when I
# initialize A using punctuation. What gives?


#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#

println("Strings to Arrays, 2")



x = "123"
y = "456"
z = "789"

A = [x; y; z]

display(A)

A_ = [collect(x) collect(y) collect(z)]

display(A_)
A__ = collect.(A)

display(A__)

A___ = collect.(collect.(A))

display(A___)


#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#


println("Strings to Arrays, 3")


x = "123"
y = "456"
z = "789"

A = [x, y, z]

display(A)

A_ = [collect(x) collect(y) collect(z)]

display(A_)
A__ = collect.(A)

display(A__)

A___ = collect.(collect.(A))

display(A___)

#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#

println(x * y * z)
println(x, y, z)
println("$x$y$z")
println("$x\t$y\t$z")
println("$x\n$y\n$z")

ffp = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

for x in ffp
    for y in ffp
        println("$x\t⋅\t$y\t=\t$(x*y)")
    end
end

print("""

There are $(lastindex(ffp)) prime numbers under 100.
So I wish to memorize $(lastindex(ffp)^2) semiprimes.

At a rate of 10 per day,
this will take me about

$(convert(Int64,round(lastindex(ffp)^2 / 10)))

days.
""")

open("diary\\semiprimes-from-primes-under-100.txt", "w") do file
    ffp = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

    for x in ffp
        for y in ffp
            if x*y < 10000
                write(file, "$x ⋅ $y = $(x*y)\n")
            end
        end
    end
end

#------Cell boundary: Use Alt+⬆ and Alt+⬇ to skip quickly in Atom.-----#

# I think that's it for today.
