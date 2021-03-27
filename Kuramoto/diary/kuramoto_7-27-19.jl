# kuramoto_7-27-19.jl

# Starting off the day strong with some code from my other project,
# grok-the-dot.

function f(x)
  return 2x+1
end

function g(x)
  return x^2
end

function h(x)
  return 4x^2 + 4x + 11   # (2x + 1)^2 = 4x^2 + 4x + 11
end

G = collect(1:1_000_000)  # You can use underscores to
                          # separate out numbers for easier
                          # reading. It's lowkey one of my
                          # favorite features.

@time h.(G)
@time g.(f.(G))

@time map(λ -> λ^2, f.(G))
@time map(λ -> λ^2, map(λ -> 2λ+1, G))



#----------------------------------------------------------#
