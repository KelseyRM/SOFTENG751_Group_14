sames = 0
graphWidth = 1000
numberOfThreads = 1
for i in 1 : 10
    g = randomWeightedGraph(graphWidth, 100)
    primsEdges = LightGraphs.prim_mst(g);
    primsMST = prims(g, numberOfThreads)
    if(isSame(primsEdges, primsMST) && isSame(primsMST, primsEdges))
        sames += 1
    end
end
sames