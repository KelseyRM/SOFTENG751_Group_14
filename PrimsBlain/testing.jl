sames = 0
graphWidth = 100
numberOfThreads = 4
for i in 1 : 1000
    g = randomWeightedGraph(graphWidth, 10)
    primsEdges = LightGraphs.prim_mst(g);
    primsMST = prims(g, numberOfThreads)
    if(isSame(primsEdges, primsMST) && isSame(primsMST, primsEdges))
        sames += 1
    end
end
sames

@benchmark prims(g, 4) setup=(g = randomWeightedGraph(100, 20)) samples=10

@benchmark LightGraphs.prim_mst(g) setup=(g = randomWeightedGraph(100, 20)) samples=10