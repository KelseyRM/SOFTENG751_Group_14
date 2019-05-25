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
function makeGrid(graphWidth::Int64, maxWeight::Int64)
    vertexAmount = graphWidth ^ 2
    graph = SimpleWeightedGraphs.SimpleWeightedGraph(vertexAmount)
    for i::Int64 in 1 : vertexAmount
        if (i % graphWidth > 0)
            LightGraphs.add_edge!(graph, i, i + 1, rand(1:maxWeight))
        end
        if ((i - 1) / graphWidth < graphWidth - 1)
            LightGraphs.add_edge!(graph, i, i + graphWidth, rand(1:maxWeight))
        end
    end
    return graph
end;

# Create an A* graph square graph with size graphWidth x graphWidth
function makeGrid(graphWidth::Int64)
    vertexAmount = graphWidth ^ 2
    graph = SimpleGraph(vertexAmount, 0; seed = -1)
    for i::Int64 in 1 : vertexAmount
        if (i % graphWidth > 0)
            LightGraphs.add_edge!(graph, i, i + 1)
        end
        if ((i - 1) / graphWidth < graphWidth - 1)
            LightGraphs.add_edge!(graph, i, i + graphWidth)
        end
    end
    return graph
end;

# Remove a bunch of edges on g to make a maze
function makeMaze(g::AbstractGraph)
    numberOfVertices = nv(g)
    vertices = LightGraphs.vertices(g)
    
    # Vertex array is a list of unexplored things
    vertexArray = Array{Int64}(undef, numberOfVertices)
    for vertex in vertices
        vertexArray[vertex] = vertex;
    end

    # Create a set which will hold visited vertices
    closedVertices = []
    
    currentVertex = vertexArray[rand(1:length(vertexArray))]
    push!(closedVertices, currentVertex)
    filter!(x -> x ? currentVertex, vertexArray)
    
    # Create an array of nodes which we can reach from current set
    reachable = []
    for reachableVertex in LightGraphs.outneighbors(g, currentVertex) 
        push!(reachable, reachableVertex)
    end
    
    # Make a maze without any edges
    maze = SimpleGraph(numberOfVertices, 0; seed = -1)
    
    # Intersection is vertices which are both reachable and not visited
    intersection = []
    
    for i in 1 : (numberOfVertices - 1)
        # Find reachable unvisited nodes
        intersection = intersect(reachable, vertexArray)
                                
        # Grab a random intersection vertex and close it / remove it from open
        randomIntersection = rand(1:length(intersection))
        currentVertex = intersection[randomIntersection]
        push!(closedVertices, currentVertex)
        filter!(x -> x ? currentVertex, vertexArray)
        
        # Add the reachable things
        for reachableVertex in LightGraphs.outneighbors(g, currentVertex) 
            push!(reachable, reachableVertex)
        end
        
        # Grab a random neighbour of our current one and add an edge to it
        neighbours = LightGraphs.outneighbors(g, currentVertex)
        while true
            random = rand(1:length(neighbours))
            if issubset(neighbours[random], closedVertices)
                add_edge!(maze, currentVertex, neighbours[random])
                break
            end
        end        
    end  
    return maze
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

# Draw a graphWidth x graphWidth with connections defined by maze edges and path overlayed, saves as pictureName.png
function drawEdges(mazeEdges, path, graphWidth::Int64, pictureName::String)
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
    
    sethue("silver")
    for edge in path
        source = edge.src
        dest = edge.dst
        if source < dest
            sourceX = ((source - 1) % graphWidth)
            sourceY = convert(Int64, ((source - 1) ÷ graphWidth))
            destX = ((dest - 1) % graphWidth)
            destY = convert(Int64, ((dest - 1) ÷ graphWidth))
        else
            destX = ((source - 1) % graphWidth)
            destY = convert(Int64, ((source - 1) ÷ graphWidth))
            sourceX = ((dest - 1) % graphWidth)
            sourceY = convert(Int64, ((dest - 1) ÷ graphWidth))
        end

        rect((10 * sourceX) + 1, (10 * sourceY) + 1, 8 + (10 * (destX - sourceX)), 8 + (10 * (destY - sourceY)), :fill)
    end

    Luxor.finish()
end;

# Example code to draw a maze and its path
# graphWidth = 100;
# graph = makeGrid(graphWidth);
# maze = makeMaze(graph);
# path = a_star(maze, 1, 100);
# mazeEdges = LightGraphs.edges(maze);
# drawEdges(mazeEdges, graphWidth, "maze");
# drawEdges(mazeEdges, path, graphWidth, "path");

# graphWidth = 100
# g = makeGrid(graphWidth, 10)
# gEdges = LightGraphs.edges(g)
# primsEdges = LightGraphs.prim_mst(g);
# drawEdges(gEdges, graphWidth, "weightedGraph");
# drawEdges(primsEdges, graphWidth, "mst");





