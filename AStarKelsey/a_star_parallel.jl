function astar(graph, graphWidth, startNode, goal)
    
    endNode = VertexStruct(goal, 0, goal)
    
    openList = PriorityQueue()
    closedList = []
    
    olLock = Threads.Mutex()
    clLock = Threads.Mutex()
    
    enqueue!(openList, VertexStruct(startNode, 0, startNode), 0)
    
    # distribute search across the (4) threads
    Threads.@threads for thread in 1:Threads.nthreads()
                
        # check if the next vertex is the end vertex
        while !isEnd(openList, goal, olLock)

            # get the next vertex off the queue
            lock(olLock) 
            try
                current = peek(openList)
            catch
                unlock(olLock)
                continue
            end
            current = dequeue!(openList)
            unlock(olLock)

            # create vertex for the current to keep track of cost and parent as well 
            currentNode = VertexStruct(current.key, current.cost, current.parent)
            
            # LOCK - can't compare and swap because it's an array of VertexStruct
            # add the element to closedList if it's not already there
            lock(clLock)
            exists = in(currentNode, closedList) 
            if !exists
                push!(closedList, currentNode)
            end
            unlock(clLock)

            neighborVals = LightGraphs.neighbors(graph, currentNode.key)
            neighbors = []
            for neighborVal in neighborVals
                # create vertexStructs out of neighbors, and add them to an array
                push!(neighbors, VertexStruct(neighborVal, 0, currentNode.key))
            end
            for neighbor in neighbors
                cost = currentNode.cost + 1
                # lock the section to avoid race conditions
                lock(olLock)
                lock(clLock)
                if !in(neighbor, keys(openList)) && isnothing(findfirst((vertex -> vertex.key == neighbor.key), closedList))
                    neighbor.cost = cost
                    #  put the new value onto the openList to flag as "reachable"
                    enqueue!(openList, neighbor, cost+heuristic(endNode.key, neighbor.key, graphWidth))
                    neighbor.parent = currentNode.key
                end 
                unlock(olLock)
                unlock(clLock)
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

function isEnd(vertexArray, goalVertex, arrayLock)
    lock(arrayLock)
    isEnd = ((peek(vertexArray)[1]).key == goalVertex)
    unlock(arrayLock)
    return isEnd
end

isnothing(::Any) = false
isnothing(::Nothing) = true

mutable struct VertexStruct
    key::Int64
    cost::Int64
    parent::Int64
end
