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

# Create a graph with graphLength number of vertices and connections number of edges from each vertex 
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
        weights[i] = rand(Float64) * 100
        i += 1
    end
    
    weightedG = SimpleWeightedGraphs.SimpleWeightedGraph(sources, dests, weights)
end

# Function to draw a graphWidth x graphWidth grid mazeEdges as connections
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
        sourceY = convert(Int64, ((source - 1) ? graphWidth))
        destX = ((dest - 1) % graphWidth)
        destY = convert(Int64, ((dest - 1) ? graphWidth))

        rect((10 * sourceX) + 1, (10 * sourceY) + 1, 8 + (10 * (destX - sourceX)), 8 + (10 * (destY - sourceY)), :fill)
    end

    Luxor.finish()
end;

# Check if two arrays of edges are the same, regardless of directions
function isSame(primsEdges, primsMST)
    for edge in primsEdges
        if(!(in(Edge(edge.dst, edge.src), primsMST)) && !(in(edge, primsMST)))
            return false
        end
    end
    true
end