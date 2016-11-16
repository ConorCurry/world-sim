module AgroGame
using Cairo #for printMap

export MapTile, zoom, randmap, printMap

#TODO: Want to generate traversal of levels, saving previous level
#      or preserving it's random seed for regeneration, an option?
#      Tradeoff: time <===> space. Time is probably more scalable.

#TODO: Separate library functions and testing into distinct files.

#TODO: More TODOs. Should do more project planning / organization.

type MapTile{T<:Unsigned} #TODO: Does this really need to be unsigned?
  moisture::T
  fertility::T
end

function zoom(zoomTile::MapTile, mapSize::Tuple)
  return randmap(mapSize..., luck=zoomTile)
end

#gets a random value weighted based on rolls
#random values are on scale of 0-255 (UInt8)
#uses accept/reject => higher lucks take longer (kinda unlucky..)
#luck is nonlinear. Really only now has monotonicity property.
#Also, luck currently doesn't impart any negative weight. Desired?
#TODO: Standarize luck values OR evaluate properties of values.
#numRolls dictates relative uniformity
function getRandVal(luck, numRolls=20)
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

#Note here that the default args must be separated by a semi-colon. Unsure why.
function randmap(x::Int, y::Int; T::DataType=UInt8, luck=MapTile(zero(T),zero(T)))
  lo = typemin(T); hi = typemax(T)
  genMap = [MapTile{T}(getRandVal(luck.moisture), getRandVal(luck.fertility))
              for xdim in 1:x, ydim in 1:y]
  return genMap
end

function printMap(tiles, mapName, imageSize::Tuple{Unsigned, Unsigned})
  c = CairoRGBSurface(imageSize...)
  cr = CairoContext(c)

  xDenom = imageSize[1]/size(tiles, 1)
  yDenom = imageSize[2]/size(tiles, 2)

  save(cr)
  for i in 1:511
    for j in 1:511
      g = tiles[trunc(Int, i/xDenom)+1,trunc(Int, j/yDenom)+1].moisture/0xFF
      r = 1-g
      set_source_rgb(cr,r,g,0)
      rectangle(cr,i,j,1,1)
      fill(cr)
    end
  end
  print("Writing $mapName.png...")
  write_to_png(c,"$mapName.png")
  println("done.")
end

end #ofModule
