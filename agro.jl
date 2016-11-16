module AgroGame

#TODO: Want to generate traversal of levels, saving previous level
#      or preserving it's random seed for regeneration, an option?
#      Tradeoff: time <===> space. Time is probably more scalable.

#TODO: Separate library functions and testing into distinct files.

#TODO: More TODOs. Should do more project planning / organization.

type MapTile{T<:Unsigned} #TODO: Does this really need to be unsigned?
  moisture::T
  fertility::T
end

#TODO: Testing file param, shouldn't be here.
MAPSIZE = (500,500)

function zoom(zoomTile::MapTile)
  return randmap(MAPSIZE..., luck=zoomTile)
end

#gets a random value weighted based on rolls
#random values are on scale of 0-255 (UInt8)
#uses accept/reject => higher lucks take longer (kinda unlucky..)
#luck is nonlinear. Really only now has monotonicity property.
#Also, luck currently doesn't impart any negative weight. Desired?
#TODO: Standarize luck values OR evaluate properties of values.
#numRolls dictates relative uniformity
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

#TODO: Move to testing, flesh out. What are the expected results?
#@show mean([getRandVal(1024,4) for i in 1:1000])

#Note here that the default args must be separated by a semi-colon. Unsure why.
function randmap(x::Int, y::Int; T::DataType=UInt8, luck=MapTile(zero(T),zero(T)))
  lo = typemin(T); hi = typemax(T)
  genMap = [MapTile{T}(getRandVal(luck.moisture), getRandVal(luck.fertility))
              for xdim in 1:x, ydim in 1:y]
  return genMap
end


#TODO: Move to testing. All of this should really be in a different file.

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
