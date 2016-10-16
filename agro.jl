#Initialize Game World

type MapTile{T}
  moisture::T
  fertility::T
end

function scaledRandn(st::Real, mu::Real, T::DataType)::T
  r = zero(Float16)
  while true
    r = randn(Float16) * st + mu
    typemin(T) < r < typemax(T) && break
  end
  x = trunc(T, r)
  return x
end

function randmap(x::Int, y::Int, T=UInt8::DataType)
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

@time boundedNorm = randmap(100, 100)
