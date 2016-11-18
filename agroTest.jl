module AgroRun
include("agro.jl")

#TODO: Tests of getRandVal. What are the expected results?
#@show mean([getRandVal(1024,4) for i in 1:1000])

#TESTING PARAMETERS
#Tile size of simulated map
# MAP_SIZE = (512,512)
# #True for zoom based on first tile value in rootMap
# #False for map based on MAX LUCK EFFECT
# ZOOM_SWITCH = false
# LUCK = 0x80
# #True to generate histograms for moisture data (using Gadfly, slow)
# MOISTURE_HIST = true
# ROOT_HIST_PATH = "moistureRoot.png"
# ZOOM_HIST_PATH = "moistureZoom.png"
# #Params to print rootMap and zoomMap using Cairo graphics.
# PRINT_ROOT = true
# PRINT_ZOOM = true
# #Determines image size for the printed maps
# IMAGE_SIZE = (0x200, 0x200)
using JSON
config = JSON.parsefile("agroTestConfig.json")
config["LUCK"] = convert(UInt8, config["LUCK"])

#Generate rootMap
print("Generating rootMap...")
@time rootMap = AgroGame.randmap(config["MAP_SIZE"]...,
                                 numRolls=config["NUM_ROLLS"])

#Generate zoomMap
print("Generating zoomMap...")
if config["ZOOM_SWITCH"]
  @show rootMap[1,1]
  @time zoomMap = AgroGame.zoom(rootMap[1,1],
                                config["MAP_SIZE"],
                                config["NUM_ROLLS"])
else
  luckTile = AgroGame.MapTile(config["LUCK"], config["LUCK"])
  @time zoomMap = AgroGame.zoom(luckTile,
                                config["MAP_SIZE"],
                                config["NUM_ROLLS"])
end

moistureDataRoot = [tile.moisture for tile in rootMap]
moistureDataZoom = [tile.moisture for tile in zoomMap]
rootMean,zoomMean = round(mean(moistureDataRoot)), round(mean(moistureDataZoom))
println("\nRoot Mean: $rootMean\nZoom Mean: $zoomMean")

@time if config["MOISTURE_HIST"]
  println("\nStarting plot...")

  print("\tImporting Gadfly...")
  @time using Gadfly, Colors
  Gadfly.push_theme(:dark)
  print("\tPlotting root...")
  @time moisturePlotRoot = plot(y=moistureDataRoot,
                                x=moistureDataZoom,
                                Guide.xlabel("Zoom"),
                                Guide.ylabel("Root"),
                                Guide.xticks(ticks=[0,0x80,zoomMean,0xFF]),
                                Guide.yticks(ticks=[0,0x80,rootMean,0xFF]),
                                Geom.histogram2d(xbincount=128,
                                                 ybincount=128))
  print("\tDrawing PNG...")
  @time draw(PNG(config["ROOT_HIST_PATH"], 5inch, 5inch), moisturePlotRoot)
  println("\t\tSaved as $(config["ROOT_HIST_PATH"])")
  print("\tPlotting zoom...")
  @time moisturePlotZoom = plot(layer(x=moistureDataZoom,
                                      Geom.histogram(bincount=128, density=true),
                                      Theme(style(default_color=RGB{U8}(1.0,0.647,0.)))),
                                layer(x=moistureDataRoot,
                                      Geom.histogram(bincount=128, density=true)),
                                      Theme(style(default_color=RGB{U8}(0.678,0.847,0.902))))
  print("\tDrawing PNG...")
  @time draw(PNG(config["ZOOM_HIST_PATH"], 6inch, 4inch), moisturePlotZoom)
  println("\t\tSaved as $(config["ZOOM_HIST_PATH"])")

  print("Finished histograms in")
end
println()

if config["PRINT_ROOT"]
  AgroGame.printMap(rootMap, "rootMap", config["IMAGE_SIZE"])
end
if config["PRINT_ZOOM"]
  AgroGame.printMap(zoomMap, "zoomMap", config["IMAGE_SIZE"])
end

println("TESTS COMPLETE.")

end #ofModule
