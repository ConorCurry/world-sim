#Initialize Game World

type MapTile{T}
  moisture::T
  fertility::T
end
#MapTile{T}() = MapTile{T}(rand(typemin(T):typemax(T)), rand(typemin(T):typemax(T)))
#=
function main()
  gamemap = [MapTile() for x=0:10, y=0:10]
  print(typeof(gamemap))
end

function zoom(tile::MapTile)::Array
end

main()
=#

#=
function randmap(x::Int, y::Int, mu=10, st=10/3)
  genMap = (randn(x,y) .* st) .+ mu
  for i in 1:length(genMap)
    while genMap[i] < 0 || 20 < genMap[i]
      genMap[i] = randn() * st + mu
    end
  end
  println(mean(genMap), "---", std(genMap))
  return genMap
end
=#

function scaledRandn(st::Real, mu::Real, T::DataType)::T
  r = zero(Float16)
  while true
    r = randn(Float16) * st + mu
    typemin(T) < r < typemax(T) && break
  end
  x = trunc(T, r)
  return x
end

function randmap2(x::Int, y::Int, T=UInt8::DataType)
  lo = typemin(T)
  hi = typemax(T)
  mu = (hi - lo) / 2
  st = mu / 3
  genMap = Array{MapTile{T}}(x, y)
  for i in 1:length(genMap)
    genMap[i] = MapTile{T}(scaledRandn(st, mu, T), scaledRandn(st, mu, T))
    #bound moisture
    while !(lo < genMap[i].moisture < hi)
      genMap[i].moisture = scaledRandn(st, mu, T)
    end
    #bound fertility
    while !(lo < genMap[i].fertility < hi)
      genMap[i].fertility = scaledRandn(st, mu, T)
    end
  end
  return genMap
end

#@time boundedNorm = randmap(1000, 1000)
@time boundedNorm = randmap2(100, 100)
#@show boundedNorm
#@show [e.moisture for e in boundedNorm]

using Gadfly
myplot = plot(x=[e.moisture for e in boundedNorm], Geom.histogram)
draw(PNG("myplot2.png", 4inch, 3inch), myplot)
println("Done")
