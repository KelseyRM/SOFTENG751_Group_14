# This function finds a new node to start making a tree from
function findNewWork(successor, numberOfThreads)
    
    # Search from (threadID / Number of threads) * successors to the end of successors
    for i in (round(Int64, ((Threads.threadid() - 1) / numberOfThreads) * length(successor)) + 1) : length(successor)
        if successor[i][] == 0
            return i
        end
    end
    
    # Search from 1 to (threadID / Number of threads) * successor
    for i in 1 : round(Int64, ((Threads.threadid() - 1) / numberOfThreads) * length(successor)) + 1
        if successor[i][] == 0
            return i
        end
    end
    
    return 0        
end

# Function intended to be called from different threads to make a subset of the MST of graph g
function partialPrims(g::AbstractGraph{U}, successorArray) where {U}
    
    graphWidth = LightGraphs.nv(g)
    
    # Grab the first root
    root = findNewWork(successorArray, numberOfThreads);
    
    # Create an array of all the edges in the msf
    edgeIterator = 1;
    arrayOfEdges = Array{Edge{Int64}, 1}(undef, graphWidth - 1)
    for edge in 1 : length(arrayOfEdges)
        arrayOfEdges[edge] = Edge(0, 0)
    end
    
    # While there is new work to do
    while (root != 0)
        
        # Add this root as its own parent, if that was already done find a new node
        ret = Threads.atomic_cas!(successorArray[root], 0, root);
        if (ret != 0)
            root = findNewWork(successorArray, numberOfThreads);
            continue
        end
        
        # Priority queue of edges
        edgeQueue = DataStructures.PriorityQueue{Tuple{Int64,Int64},Float64}()
        
        # Create a set which represents the current tree
        subtree = Set{Int64}()
        push!(subtree, root)
        
        # Add edges from root
        for neighbor in LightGraphs.outneighbors(g, root)
            if(!(in(neighbor, subtree)))
                DataStructures.enqueue!(edgeQueue, (root, neighbor), g.weights[root, neighbor])
            end
        end
        
        # Go through the queue of all edges adding small ones
        while (true)
            
            nextEdge = Tuple{Int64, Int64}
            
            somethingFound = false
            
            # Find the next edge which connects subtree to a node outside of it
            while((DataStructures.length(edgeQueue)) > 0)
                nextEdge = DataStructures.dequeue!(edgeQueue)
                if((in(nextEdge[1], subtree)) && (!(in(nextEdge[2], subtree))))
                    somethingFound = true
                    break;
                end
            end
            
            # If there aren't any edges left break loop
            if(((DataStructures.length(edgeQueue)) == 0) && !somethingFound)
                break;
            end
                        
            # Add the edge to the array of MSF
            arrayOfEdges[edgeIterator] = Edge(nextEdge[1], nextEdge[2])
            edgeIterator += 1
            
            # If our destination doesn't have a successor set out roots successor to it successor
            parent = successorArray[root][]
            ret = Threads.atomic_cas!(successorArray[nextEdge[2]], 0, successorArray[parent][]);
            
            # If we do have a successor already
            if(ret != 0)
                parent = successorArray[nextEdge[2]][]
                Threads.atomic_xchg!(successorArray[root], successorArray[parent][])
                break;    
            
            # Add edge to list and add neighbours to explorables
            else
                push!(subtree, nextEdge[2])
                for neighbor in LightGraphs.outneighbors(g, nextEdge[2])
                    if(!(in(neighbor, subtree)))
                        DataStructures.enqueue!(edgeQueue, (nextEdge[2], neighbor), g.weights[nextEdge[2], neighbor])
                    end
                end
            end
        end
        root = findNewWork(successorArray, numberOfThreads);
    end
    return arrayOfEdges
end

# Trace through the successor array recursively to find the true root
function trueRoot(successorArray::AbstractArray, root::Int64, prev::Int64)
    if(successorArray[root][] == prev)
        return prev
    elseif(successorArray[root][] != root)
        return trueRoot(successorArray, successorArray[root][], root)
    else
        return root
    end
end

# Step to connect all subsets created during the partial prims step
function unification(g::AbstractGraph, subtrees)
    subtree = subtrees[1]
    edgeArray = []
    
    for i in 1 : length(subtrees)
        
        # Find lowest edge that links to another subtree
        lowestEdge = Edge(0, 0)
        lowestWeight = 100000.0
        for vertex in subtree
            for neighbor in LightGraphs.outneighbors(g, vertex)
                if !(in(neighbor, subtree))
                    if (g.weights[vertex, neighbor] < lowestWeight)
                        lowestEdge = Edge(vertex, neighbor)
                        lowestWeight = g.weights[vertex, neighbor]
                    end
                end
            end
        end
        
        # Find the subtree the destination belongs too
        subTreeIndex = 1
        for subtreeCheck in 1 : length(subtrees)
            if (in(lowestEdge.dst, subtrees[subtreeCheck]))
                subTreeIndex = subtreeCheck
            end
        end
        
        # add that subtree to our one
        subtree = union(subtree, subtrees[subTreeIndex])
        push!(edgeArray, lowestEdge)
    end
    return edgeArray
end

# Function to run prims on multiple processors
function prims(g::AbstractGraph, numberOfThreads)
    
    # Create a successor array shared between threads, used to unify
    graphWidth = LightGraphs.nv(g)
    successorArray = Vector(undef, graphWidth)
    for i in 1 : (graphWidth)
        successorArray[i] = Threads.Atomic{Int}(0)
    end
    
    totalTree = Array{Array{Edge{Int64}, 1}, 1}(undef, numberOfThreads + 1)
    
    # Run partial prims on multiple threads
    Threads.@threads for i in 1 : numberOfThreads
        subTree = partialPrims(g, successorArray)
        totalTree[i] = subTree
    end
    
    theSets = Array{Array{Int64}, 1}()
    setIterator = 1
    rootDict = Dict()
    doneRoots = Set()

    # Find which unconnected subtree each vertex belongs to
    for i in 1 : length(successorArray)
        trueRootValue = trueRoot(successorArray, successorArray[i][], 0)
        if !(in(trueRootValue, doneRoots))
            push!(doneRoots, trueRootValue)
            
            push!(theSets, [])
            push!(theSets[setIterator], i)
            
            rootDict[trueRootValue] = setIterator
            
            setIterator += 1
        else
            push!(theSets[rootDict[trueRootValue]], i)
        end
    end
    
    # Run through the subtrees to find edges needed to connect islands
    unificationEdges = unification(g, theSets)
    totalTree[numberOfThreads + 1] = unificationEdges
    
    # Add together all valid edges to construct overall graph
    edges = Array{Edge{Int64}, 1}(undef, graphWidth - 1)
    for edge in 1 : length(edges)
        edges[edge] = Edge(0, 0)
    end
    edgeIterator = 0
    for i in 1 : length(totalTree)
        for edge in totalTree[i]
            if(!(in(edge, edges)) && !(in(Edge(edge.dst, edge.src), edges)) && edge.src != 0)
                edgeIterator += 1
                edges[edgeIterator] = edge
            end
        end
    end 
    
    return edges
end