module AgroRun
include("agro.jl")
#import AgroGame


#TODO: Flesh out. What are the expected results?
#@show mean([getRandVal(1024,4) for i in 1:1000])

MAPSIZE = (50,50)

@time rootMap = AgroGame.randmap(MAPSIZE...)

@show rootMap[1,1]
#@time zoomMap = zoom(MapTile(0xFF, 0xFF))
@time zoomMap = AgroGame.zoom(rootMap[1,1], MAPSIZE)

moistureDataRoot = [tile.moisture for tile in rootMap]
moistureDataZoom = [tile.moisture for tile in zoomMap]
println("Orig: $(mean(moistureDataRoot))\nZoom: $(mean(moistureDataZoom))")

print("Starting plot...")

using Gadfly
moisturePlotRoot = plot(x=moistureDataRoot, Geom.histogram)
draw(SVG("moistureRoot.svg", 4inch, 3inch), moisturePlotRoot)
moisturePlotZoom = plot(x=moistureDataZoom, Geom.histogram)
draw(SVG("moistureZoom.svg", 4inch, 3inch), moisturePlotZoom)

println("Done.")

end #ofModule
