# Check if two arrays of edges are the same, regardless of directions
function isSame(primsEdges, primsMST)
    for edge in primsEdges
        if(!(in(Edge(edge.dst, edge.src), primsMST)) && !(in(edge, primsMST)))
            return false
        end
    end
    true
end

# Benchmarking PrimsI
@benchmark parallelPrims(graph, numberOfVertices) setup=(graph = randomWeightedGraph(numberOfVertices, connections)) samples=samplesToRun seconds=maxRuntime


# Benchmarking PrimsII
@benchmark prims(graph, numberOfThreads) setup=(graph = randomWeightedGraph(numberOfVertices, connections)) samples=samplesToRun seconds=maxRuntime


# Benchmarking A* 
@benchmark astar(graph, graphWidth, startV, endV) setup=(graph = makeMaze(makeGrid(graphWidth))) samples=samplesToRun seconds=maxRuntime


