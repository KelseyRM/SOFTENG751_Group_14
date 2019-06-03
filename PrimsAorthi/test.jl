#comment adding these packages in and out as needed
#import Pkg;
Pkg.add("LightGraphs")
Pkg.add("SimpleWeightedGraphs")
Pkg.add("BenchmarkTools")

using LightGraphs
using SimpleWeightedGraphs
using BenchmarkTools

# Create a weighted graph to test with
function randomWeightedGraph(graphLength, connections)
    g = LightGraphs.SimpleGraph(connections)
    g = barabasi_albert!(g, graphLength, connections)

    sources = Array{Int64, 1}(undef, ne(g))
    dests = Array{Int64, 1}(undef, ne(g))
    weights = Array{Float64, 1}(undef, ne(g))

    unweightedEdges = LightGraphs.edges(g)

    i = 1
    for edge in unweightedEdges
        sources[i] = edge.src
        dests[i] = edge.dst
        weights[i] = rand(Float64) * 100.0
        i += 1
    end

    weightedG = SimpleWeightedGraphs.SimpleWeightedGraph(sources, dests, weights)
end

#Create test graph
nodes = 100;
connections = 5;
g = randomWeightedGraph(nodes, connections);
paraPrim = parallelPrims(g, nodes);
println("Number of Vertices: ", nodes)
println("Our implementation (parallel):")
@benchmark parallelPrims(g, nodes)
