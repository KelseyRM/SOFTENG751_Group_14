#comment adding these packages in and out as needed
#import Pkg;
#Pkg.add("LightGraphs")
#Pkg.add("SimpleWeightedGraphs")

using LightGraphs
using SimpleWeightedGraphs

# Finds the node with the lowest edge weight currently in key
function minKey(key, visited, numberOfNodes)
    # Creates global variables
    globalMin = Inf;
    globalIndex = 1;

    # Create a mutex
    m = Threads.Mutex();

    # Goes through each unvisited node and checks to see if its edge weight is small than the current local minimum weight
    Threads.@threads for i in 1:numberOfNodes
        localMin = globalMin[];
        localIndex = globalIndex[];
        if ((visited[i] == 0) && (key[i] < localMin))
            localMin = key[i];
            localIndex = i;
        end

        # Updates the global variables
        lock(m);
        if (localMin < globalMin[])
            globalMin = localMin;
            globalIndex = localIndex;
        end
        unlock(m);
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
    while 0 in visited
        nextNode = minKey(key, visited, numberOfNodes);
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
