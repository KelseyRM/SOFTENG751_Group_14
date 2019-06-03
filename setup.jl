using Pkg

Pkg.add("LightGraphs")
Pkg.add("SimpleWeightedGraphs")
Pkg.add("DataStructures")
Pkg.add("BenchmarkTools")

# uncomment if you want to draw the thing
#Pkg.add("GraphPlot")
# note: Cairo can cause errors in Compose and Fontconfig, but running the script again resolves this
#Pkg.add("Cairo") 
#Pkg.add("Fontconfig")
#Pkg.add("Compose")
#Pkg.add("Luxor")
#Pkg.add("SimpleTraits")

using LightGraphs
using SimpleWeightedGraphs
using DataStructures
using BenchmarkTools

# uncomment if drawing
#using GraphPlot
#using Cairo
#using Fontconfig
#using Compose
#using Luxor
#using SimpleTraits

# include implemented algorithms
include("primsI.jl") # Aorthi's
include("primsII.jl") # Blain's
include("aStar.jl")
include("helpers.jl")
include("correctnessTest.jl")