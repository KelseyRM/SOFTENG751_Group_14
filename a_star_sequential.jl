using GraphPlot
using Distributed
using SimpleTraits
using DataStructures
using LightGraphs
using BenchmarkTools

function astar(graph, graphWidth, startNode, goal)
    
    currentNode = VertexStruct(startNode, 0, startNode)
    endNode = VertexStruct(goal, 0, goal)
    
    openList = PriorityQueue()
    closedList = []
    enqueue!(openList, currentNode, 0)

    while !((peek(openList)[1]).key == endNode.key)
        
        # get the current node
        current = dequeue!(openList)
        
        currentNode = VertexStruct(current.key, current.cost, current.parent)
        if !in(currentNode, closedList) 
            push!(closedList, currentNode)
        end
        
        neighborVals = LightGraphs.neighbors(graph, currentNode.key)
        neighbors = []
        
        for neighborVal in neighborVals
            push!(neighbors, VertexStruct(neighborVal, 0, currentNode.key))
        end
            
        for neighbor in neighbors
            cost = currentNode.cost + 1
            if !in(neighbor, keys(openList)) && isnothing(findfirst((vertex -> vertex.key == neighbor.key), closedList))
                neighbor.cost = cost
                enqueue!(openList, neighbor, 1+heuristic(endNode.key, neighbor.key, graphWidth))
                neighbor.parent = currentNode.key
            end 
        end
        
    end
    
    finalVertex = dequeue!(openList)
    
    path = []
    currentVertex = finalVertex
    push!(path, currentVertex)
    
    while currentVertex.key != startNode
        parentVertex = closedList[findfirst((vertex -> vertex.key == currentVertex.parent), closedList)]
        push!(path, parentVertex) 
        currentVertex = parentVertex
    end
    
    path = reverse(path)
    pathEdges = Array{Edge{Int64}}(undef, 0)
    length = size(path)[1]
    prev = path[1]

    for i = 2:length
        push!(pathEdges, Edge(prev.key, path[i].key))
        prev = path[i]
    end
    
    return pathEdges
end

# manhattan distance - no diagonal movement
function heuristic(goal, current, graphWidth)
    
    x1 = (current-1) % graphWidth
    x2 = (goal-1) % graphWidth
    y1 = (current-1) ÷ graphWidth
    y2 = (goal-1) ÷ graphWidth    
    return abs(x1-x2) + abs(y1-y2)
    
end

isnothing(::Any) = false
isnothing(::Nothing) = true

mutable struct VertexStruct
    key::Int64
    cost::Int64
    parent::Int64
end