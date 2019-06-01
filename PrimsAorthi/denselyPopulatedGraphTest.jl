
import Pkg;
Pkg.add("LightGraphs")
Pkg.add("SimpleWeightedGraphs")
Pkg.add("BenchmarkTools")

using LightGraphs
using SimpleWeightedGraphs
using BenchmarkTools

# Create a weighted graph to test with
function createTestGraph(graphSize)
    G = SimpleWeightedGraph(graphSize);

    for i in 1:(graphSize*5)
        add_edge!(G, rand(1:graphSize), rand(1:graphSize), rand(Float64)*10);
    end
    return G;
end

#PARALLEL CODE

# Finds the node with the lowest edge weight currently in key
function parallelMinKey(key, visited, numberOfNodes)
    # Creates atomic global variables
    globalMin = Threads.Atomic{Float64}(Inf);
    globalIndex = Threads.Atomic{Int}(1);

    localMin = Inf;
    localIndex = 1;

    # Goes through each unvisited node and checks to see if its edge weight is small than the current local minimum weight
    Threads.@threads for i in 1:numberOfNodes
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
        nextNode = parallelMinKey(key, visited, numberOfNodes);
        visited[nextNode] = 1;

        # Updates the key array so that it contains the lowest weights of all possible paths
        Threads.@threads for possibleNode in 1:numberOfNodes
            # checks that there is an edge between the nodes, that the node hasn't been visited already and that the weight is smaller than the current edge weight in key
            if ((weights_matrix[nextNode, possibleNode] != 0) && (visited[possibleNode] == 0) && (weights_matrix[nextNode, possibleNode] < key[possibleNode]))
                from[possibleNode] = nextNode;
                key[possibleNode] = weights_matrix[nextNode, possibleNode];
            end
        end
    end

    # Creates an array containing the edges that make up the MST
    edges = [];
    for i in 2:numberOfNodes
        currentEdge = Edge(Int(from[i]), i);
        push!(edges, currentEdge);
    end
    return edges;
end

# SEQUENTIAL CODE

# Finds the node with the lowest edge weight currently in key
function seqMinKey(key, visited, numberOfNodes)
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

function seqPrims(G, numberOfNodes)
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
        nextNode = seqMinKey(key, visited, numberOfNodes);
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
    for i in 2:numberOfNodes
        currentEdge = Edge(Int(from[i]), i);
        push!(edges, currentEdge);
    end
    return edges;
end

#Create test graph
nodes = 100;
g = createTestGraph(nodes);
#primsEdges = LightGraphs.prim_mst(g);
#seqPrim = seqPrims(g, nodes);
#paraPrim = parallelPrims(g, nodes);

#=
println("Number of Vertices: ", nodes)
println("Base library's Prim's (seq):")
@benchmark LightGraphs.prim_mst(g) =#

#=
println("Number of Vertices: ", nodes)
println("Our implementation (seq):")
@benchmark seqPrims(g, nodes) =#

println("Number of Vertices: ", nodes)
println("Our implementation (parallel):")
@benchmark parallelPrims(g, nodes)
