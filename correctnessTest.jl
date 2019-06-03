# Check if two arrays of edges are the same, regardless of directions
function isSame(primsEdges, primsMST)
    for edge in primsEdges
        if(!(in(Edge(edge.dst, edge.src), primsMST)) && !(in(edge, primsMST)))
            return false
        end
    end
    true
end

# Testing PrimsI

function testPrimsI(vertices, connections, attempts)
	sames = 0
	for i in 1 : attempts
		g = randomWeightedGraph(vertices, connections)
		baseLibraryPrims = LightGraphs.prim_mst(g);
		primI = parallelPrims(g, vertices)
		if(isSame(baseLibraryPrims, primI) && isSame(primI, baseLibraryPrims))
			sames += 1
		end
	end
	if (sames == attempts)
		println("Correct")
	else 
		println("Rip")
	end
end

# Testing PrimsII
function testPrimsII(vertices, connections, numberOfThreads, attempts)
	sames = 0
	for i in 1 : attempts
		g = randomWeightedGraph(vertices, connections)
		baseLibraryPrims = LightGraphs.prim_mst(g);
		primII = prims(g, numberOfThreads)
		if(isSame(baseLibraryPrims, primII) && isSame(primII, baseLibraryPrims))
			sames += 1
		end
	end
	if (sames == attempts)
		println("Correct")
	else 
		println("Rip")
	end
end

# Testing A* 
function testAStar(graphWidth, attempts)
	sames = 0
	for i in 1 : attempts
		startVertex = rand(1 : graphWidth * graphWidth)
		endVertex = rand(1 : graphWidth * graphWidth)
		graph = makeMaze(makeGrid(graphWidth));
		baseLibraryAStar = LightGraphs.a_star(graph, startVertex, endVertex)
		ourAStar = astar(graph, graphWidth, startVertex, endVertex)
		if(isSame(baseLibraryAStar, ourAStar) && isSame(ourAStar, baseLibraryAStar))
			sames += 1
		end
	end
	
	if (sames == attempts)
		println("Correct")
	else 
		println("Rip")
	end
end



