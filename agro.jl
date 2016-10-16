module AgroGame

type MapTile{T}
  moisture::T
  fertility::T
end

#gets a random value weighted based on rolls
#random values are on scale of 0-255
#uses accept/reject => higher lucks take longer
#luck is nonlinear. numRolls dictates uniformity
function getRandVal(luck, numRolls=2)
  hiVal = Int(typemax(UInt8))
  m = hiVal/numRolls
  rolls = Array{UInt8}(numRolls)
  for i in 1:numRolls
    while true
      rolls[i] = rand(0:m)
      if luck != 0
        accRejVal = Int(rand(0:hiVal))
        y = -(luck/hiVal)*rolls[i]*numRolls + luck
        accRejVal > y && break
      else
        break
      end
    end
  end
  return UInt8(sum(rolls))
end

#@show mean([getRandVal(1024,4) for i in 1:1000])

function randmap(x::Int, y::Int, luck=0, T=UInt8::DataType)
  lo = typemin(T); hi = typemax(T)
  genMap = [MapTile{T}(getRandVal(luck,2), getRandVal(luck,2)) for xdim in 1:x, ydim in 1:y]
  return genMap
end

@time boundedNorm = randmap(1000, 1000)
#@show boundedNorm
@show typeof(boundedNorm), size(boundedNorm)


end #of module
