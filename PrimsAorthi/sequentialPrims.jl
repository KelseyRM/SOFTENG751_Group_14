# Comment these package adds in and out as needed
#import Pkg;
#Pkg.add("GraphPlot")
#Pkg.add("LightGraphs")
#Pkg.add("LightGraphs")
#Pkg.add("Compose")
#Pkg.add("Fontconfig")
#Pkg.add("Cairo")
#Pkg.add("Distributed")
#Pkg.add("BenchmarkTools")
#Pkg.add("SimpleTraits")
#Pkg.add("DataStructures")
#Pkg.add("SimpleWeightedGraphs")
#Pkg.add("Luxor")

using GraphPlot
using LightGraphs
import LightGraphs
import LightGraphs.Parallel
using Compose
using Fontconfig
using Cairo
using Distributed
using BenchmarkTools
using SimpleTraits
import DataStructures
import SimpleWeightedGraphs
using Luxor

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

# Draw a graphWidth x graphWidth with connections defined by maze edges, saves as pictureName.png
function drawEdges(mazeEdges, graphWidth::Int64, pictureName::String)
    Drawing(10 * graphWidth, 10 * graphWidth, pictureName * ".png")
    background("black")
    sethue("purple")
    for j in 0 : graphWidth - 1
        for i in 0 : graphWidth - 1
            rect((10 * i) + 1, (10 * j) + 1, 8, 8, :fill)
        end
    end

    for edge in mazeEdges
        source = edge.src
        dest = edge.dst
        sourceX = ((source - 1) % graphWidth)
        sourceY = convert(Int64, ((source - 1) ÷ graphWidth))
        destX = ((dest - 1) % graphWidth)
        destY = convert(Int64, ((dest - 1) ÷ graphWidth))

        rect((10 * sourceX) + 1, (10 * sourceY) + 1, 8 + (10 * (destX - sourceX)), 8 + (10 * (destY - sourceY)), :fill)
    end

    Luxor.finish()
end;

# Finds the node with the lowest edge weight currently in key
function minKey(key, visited, numberOfNodes)
    # Creates atomic global variables
    globalMin = Threads.Atomic{Float64}(Inf);
    globalIndex = Threads.Atomic{Int}(1);

    localMin = Inf;
    localIndex = 1;

    # Goes through each unvisited node and checks to see if its edge weight is small than the current local minimum weight
    for i in 1:numberOfNodes
       if ((visited[i] == 0) && key[i] < localMin)
            localMin = key[i];
            localIndex = i;

        end

        # Updates the global variables
        if (localMin < globalMin[])
            Threads.atomic_xchg!(globalMin, localMin)
            Threads.atomic_xchg!(globalIndex, localIndex)
        end

    end

    return globalIndex[];
end

function parallelPrims(G, numberOfNodes)
    # Create adjacency matrix
    weights_matrix = weights(G);

    # Intialise arrays
    from = zeros(numberOfNodes); # tracks how to travel to each node
    key = zeros(numberOfNodes); # distance vector containing the current smallest weight to reach each node
    visited = zeros(numberOfNodes); # tracks if a node has been visited

    # Populate key array with Infinity
    for i in 1:numberOfNodes
        key[i] = Inf;
    end

    key[1] = 0;
    from[1] = -1; # -1 indicates that this is the starting point of the MST

    # Chooses which node to travel to based off what has the lowest value in key
    for count in 1:(numberOfNodes-1)
        nextNode = minKey(key, visited, numberOfNodes);
        visited[nextNode] = 1;

        # Updates the key array so that it contains the lowest weights of all possible paths
        for possibleNode in 1:numberOfNodes
            # checks that there is an edge between the nodes, that the node hasn't been visited already and that the weight is smaller than the current edge weight in key
            if ((weights_matrix[nextNode, possibleNode] != 0) && (visited[possibleNode] == 0) && (weights_matrix[nextNode, possibleNode] < key[possibleNode]))
                from[possibleNode] = nextNode;
                key[possibleNode] = weights_matrix[nextNode, possibleNode];
            end
        end
    end

    # Creates an array containing the edges that make up the MST
    edges = [];
    for i in 1:numberOfNodes
        currentEdge = Edge(Int(from[i]), i);
        push!(edges, currentEdge);
    end
    return edges;
end

# MAIN
graphWidth = 100;
nodes = graphWidth^2;
g = makeGrid(graphWidth, 10.0);
gEdges = LightGraphs.edges(g);
primsEdges = LightGraphs.prim_mst(g);
paraPrim = parallelPrims(g, nodes);
drawEdges(paraPrim, graphWidth, "parallel");
drawEdges(primsEdges, graphWidth, "mst");
