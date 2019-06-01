# Comment these package adds in and out as needed
#import Pkg;
#Pkg.add("GraphPlot")
#Pkg.add("LightGraphs")
#Pkg.add("Distributed")
#Pkg.add("BenchmarkTools")
#Pkg.add("SimpleTraits")
#Pkg.add("DataStructures")
#Pkg.add("SimpleWeightedGraphs")

using GraphPlot
using LightGraphs
using Distributed
using BenchmarkTools
using SimpleTraits
import DataStructures
import SimpleWeightedGraphs

# Make a graphWidth x graphWidth grid with random weights on edges from 1 : maxWeight
function makeGrid(graphWidth::Int64, maxWeight::Float64)
    vertexAmount = graphWidth ^ 2
    graph = SimpleWeightedGraphs.SimpleWeightedGraph(vertexAmount)
    for i::Int64 in 1 : vertexAmount
        if (i % graphWidth > 0)
            LightGraphs.add_edge!(graph, i, i + 1, rand(Float64) * maxWeight)
        end
        if ((i - 1) / graphWidth < graphWidth - 1)
            LightGraphs.add_edge!(graph, i, i + graphWidth, rand(Float64) * maxWeight)
        end
    end
    return graph
end;

# TEST SCRIPT
graphWidth = 100;
nodes = graphWidth^2;
g = makeGrid(graphWidth, 10.0);

println("Number of Vertices: ", nodes)
println("Base library's Prim's (seq):")
@benchmark LightGraphs.prim_mst(g)
