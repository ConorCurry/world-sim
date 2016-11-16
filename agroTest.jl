module AgroRun
include("agro.jl")

#TODO: Tests of getRandVal. What are the expected results?
#@show mean([getRandVal(1024,4) for i in 1:1000])

#TESTING PARAMETERS
#Tile size of simulated map
MAP_SIZE = (64,64)
#True for zoom based on first tile value in rootMap
#False for map based on MAX LUCK EFFECT
ZOOM_SWITCH = false
#True to generate histograms for moisture data (using Gadfly, slow)
MOISTURE_HIST = true
ROOT_HIST_PATH = "moistureRoot.svg"
ZOOM_HIST_PATH = "moistureZoom.svg"
#Params to print rootMap and zoomMap using Cairo graphics.
PRINT_ROOT = true
PRINT_ZOOM = true
#Determines image size for the printed maps
IMAGE_SIZE = (0x200, 0x200)

#Generate rootMap
print("Generating rootMap...")
@time rootMap = AgroGame.randmap(MAP_SIZE...)

#Generate zoomMap
print("Generating zoomMap...")
if ZOOM_SWITCH
  @show rootMap[1,1]
  @time zoomMap = AgroGame.zoom(rootMap[1,1], MAP_SIZE)
else
  @time zoomMap = AgroGame.zoom(AgroGame.MapTile(0xFF, 0xFF), MAP_SIZE)
end

moistureDataRoot = [tile.moisture for tile in rootMap]
moistureDataZoom = [tile.moisture for tile in zoomMap]
println("\nRoot Mean: $(mean(moistureDataRoot))\nZoom Mean: $(mean(moistureDataZoom))")

@time if MOISTURE_HIST
  println("\nStarting plot...")

  print("\tImporting Gadfly...")
  @time using Gadfly
  print("\tPlotting root...")
  @time moisturePlotRoot = plot(x=moistureDataRoot, Geom.histogram)
  print("\tDrawing SVG...")
  @time draw(SVG(ROOT_HIST_PATH, 4inch, 3inch), moisturePlotRoot)
  println("\t\tSaved as $ROOT_HIST_PATH")
  print("\tPlotting zoom...")
  @time moisturePlotZoom = plot(x=moistureDataZoom, Geom.histogram)
  print("\tDrawing SVG...")
  @time draw(SVG(ZOOM_HIST_PATH, 4inch, 3inch), moisturePlotZoom)
  println("\t\tSaved as $ZOOM_HIST_PATH")

  print("Finished histograms in")
end
println()

if PRINT_ROOT
  AgroGame.printMap(rootMap, "rootMap", IMAGE_SIZE)
end
if PRINT_ZOOM
  AgroGame.printMap(zoomMap, "zoomMap", IMAGE_SIZE)
end

println("TESTS COMPLETE.")

end #ofModule
