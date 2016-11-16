module AgroGame

type MapTile{T<:Unsigned}
  moisture::T
  fertility::T
end

MAPSIZE = (500,500)

function zoom(zoomTile::MapTile)
  return randmap(MAPSIZE..., luck=zoomTile)
end

#gets a random value weighted based on rolls
#random values are on scale of 0-255
#uses accept/reject => higher lucks take longer
#luck is nonlinear. numRolls dictates uniformity
function getRandVal(luck, numRolls=5)
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

function randmap(x::Int, y::Int; T::DataType = UInt8, luck = MapTile(zero(T),zero(T)))
  lo = typemin(T); hi = typemax(T)
  genMap = [MapTile{T}(getRandVal(luck.moisture), getRandVal(luck.fertility)) for xdim in 1:x, ydim in 1:y]
  return genMap
end

@time boundedNorm = randmap(MAPSIZE...)
#@show boundedNorm
@show typeof(boundedNorm), size(boundedNorm)

@show boundedNorm[1,1]
@time zoomed = zoom(MapTile(0xFF, 0xFF))
#@show zoomed
moistureDataOrig = [tile.moisture for tile in boundedNorm]
moistureDataZoomed = [tile.moisture for tile in zoomed]
println("Orig: $(mean(moistureDataOrig))\nZoom: $(mean(moistureDataZoomed))")

print("Starting plot...")

using Gadfly
myplot = plot(x=moistureDataOrig, Geom.histogram)
draw(SVG("myplot.svg", 4inch, 3inch), myplot)
myplotZoomed = plot(x=moistureDataZoomed, Geom.histogram)
draw(SVG("myplotZoomed.svg", 4inch, 3inch), myplotZoomed)

println("Done.")

end #of module
