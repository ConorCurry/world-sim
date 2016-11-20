
module AgroGame
using Cairo #for printMap

export MapTile, zoom, randmap, printMap

#TODO: Want to generate traversal of levels, saving previous level
#      or preserving it's random seed for regeneration, an option?
#      Tradeoff: time <===> space. Time is probably more scalable.

#TODO: Separate library functions and testing into distinct files.

#TODO: Some functions that move element-wise on one level of a map
#      to perform a mutation on cell visited. Incr or decr a value

#TODO: More TODOs. Should do more project planning / organization.

type MapTile{T<:Unsigned} #TODO: Does this really need to be unsigned?
  moisture::T
  fertility::T
end

function zoom(zoomTile::MapTile, mapSize::Array, numRolls::Integer)
  return randmap(mapSize..., luck=zoomTile, numRolls=numRolls)
end

#gets a random value weighted based on rolls
#random values are on scale of 0-255 (UInt8)
#uses accept/reject => higher lucks take longer (kinda unlucky..)
#luck is nonlinear. Really only now has monotonicity property.
#Also, luck currently doesn't impart any negative weight. Desired?
#TODO: Standarize luck values OR evaluate properties of values.
#numRolls dictates relative uniformity
function getRandVal(luck::UInt8, numRolls::Integer)
  if numRolls > 8
    throw("Too many rolls specified. Decrease to prevent system hang.")
  end
  hiVal = Int(typemax(UInt8))
  m = hiVal/numRolls
  rolls = Array{UInt8}(numRolls)
  for i in 1:numRolls
    while true
      rolls[i] = rand(0:m)
      if luck != 0
        accRejVal = rand(0:m)
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
function randmap(x::Int, y::Int;
                 T::DataType=UInt8,
                 luck=MapTile(zero(T),zero(T)),
                 numRolls::Integer=1)
  lo = typemin(T); hi = typemax(T)
  genMap = [MapTile{T}(getRandVal(luck.moisture, numRolls),
                       getRandVal(luck.fertility, numRolls))
              for xdim in 1:x, ydim in 1:y]
  return genMap
end

function printMap(tiles::Array, mapName::AbstractString, imageSize::Array)
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

using Lazy

type Neighborhood
  region::AbstractArray
  center::AbstractArray{Int}
end


@rec function graze(idx::Array, tileMap, aggression, lifetime)
  if lifetime == 0
    return
  end
  if tileMap[idx...].moisture > aggression
    tileMap[idx...].moisture -= aggression
  else
    tileMap[idx...].moisture = 0
  end
  nHood = getNeighborhood(tileMap, idx)
  #TODO: This is hacky.
  maxIdx = indmax(getfield.(nHood, [:moisture for _ in nHood]))
  if lifetime > 195
    @show idx
    #@show nHood
    @show getfield.(nHood, [:moisture for _ in nHood])
    @show maxIdx
    println("------------------------------------")
  end
  @> maxIdx subArrayPassthrough(nHood) graze(tileMap, aggression, lifetime-1)
  #newIdx = @> tileMap getNeighborhood(idx) indmax() subArrayPassthrough()
  #graze(newIdx, tileMap, aggression, lifetime-1)
end

#Gets the neighbors of a tile
function getNeighborhood(tileMap, tileIndex::Array; dist=1)
  #bound indices to prevent out of bounds exception. Trimmed at edges.
  xRange = intersect(tileIndex[1]-dist:tileIndex[1]+dist, 1:size(tileMap)[1])
  yRange = intersect(tileIndex[2]-dist:tileIndex[2]+dist, 1:size(tileMap)[2])
  #gotta test to make sure there isn't some unforseen edge case
  return @view tileMap[xRange,yRange]
end

#given a subarray and an index,
#translate to an index in the parent array
function subArrayPassthrough(sIdx::Array, sA::SubArray)::Array
  return [sA.indexes[1].start-1 + sIdx[1], sA.indexes[2].start-1 + sIdx[2]]
end

#takes linear index
function subArrayPassthrough(linIdx::Integer, sA::SubArray)::Array
  parentSize = size(sA.parent)
  xIdx = trunc(Int, linIdx/parentSize[1]) + 1
  yIdx = (parentSize[1] % linIdx) + 1
  return subArrayPassthrough([xIdx, yIdx], sA)
end

end #ofModule
