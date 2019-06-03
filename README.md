# SOFTENG751 Assignment Group 14

## Parallelisation of Graph Algorithms in Julia
Graph algorithms can have a long runtime, with complexities of up to O(n^3), where n is the number of nodes. This assignment implements A-star shortest path and Prim's algorithms in Julia, a relatively new language. Julia is a high-performance dynamic programming language with many modern features, including experimental support for parallelism. Specifically, the algorithms are implemented using Julia's **Threads** package, and are tested using randomly generated graphs - mazes for A-star and weighted and undirected graphs for Prim's. The implementations' timing data and correctness can be evaluated via experimental runs on multicore systems using native Julia benchamrking tools. 

#### Authors:
- Aorthi Afroza (Aafr770) 
- Blain Cribb (Bcri429)
- Kelsey Murray (Kmur120)

#### License:
- MIT

### Installing Julia
Julia can be downloaded from https://julialang.org/downloads/.  
Double-clicking on the Julia executable will open the Julia 'read-eval-print loop' or 'REPL'.

### Setup
In order to run Julia multi-threaded, the number of threads to be used needs to be set **BEFORE** opening and running the REPL. To do this, navigate to julia.exe, then:

#### On Windows:
1. Open command prompt
2. Run `set JULIA_NUM_THREADS=4` (4 is the number of threads used)
3. Run `start julia.exe`

#### On OSX / Linux:
- Similar to Windows, just change `set` to `export` when setting `NUM_THREADS`
(You will need to open Julia from this command line terminal)

This can be verified by running `Threads.nthreads()` in the Julia REPL; you should see the following output:

```julia
julia> Threads.nthreads()
 4
```

### Troubleshooting
Julia has documentation available at https://docs.julialang.org/en/v1/.
##### Quick-links:
Getting Started: https://docs.julialang.org/en/v1/manual/getting-started/  
Using the REPL: https://docs.julialang.org/en/v1/stdlib/REPL/index.html  
Multi-threading: https://docs.julialang.org/en/v1/manual/parallel-computing/index.html  

### Testing

>Note: Since the graph generation relies on a number of random functions, it can take a while to generate the graphs and therefore run the tests. To avoid this taking too long we recommend setting the **<num_seconds>** parameter when benchmarking, as specified below.

Before running the correctnes and benchmarking tests, the `setup.jl` file needs to be run to import all dependencies.

1. Navigate through directories in the Julia REPL using 
```julia
julia> cd("/myPath/SOFTENG751_Group_14")
```
  View the current directory using
```julia
julia> pwd()
```

2. Run the command 
```julia
julia> include("setup.jl")
```
>This imports all of the required dependencies and packages, including the implemented algorithms and testing and benchmarking files.

#### Verifying Correctness

In the REPL run the respective test for the algorithm. There is a test available for each algorithm, which checks the implemented algorithm against the native Julia sequential implementation. The three tests are:

##### Prim's I algorithm:
```julia
julia> testPrimsI(vertices, connections, attempts)
```

##### Prim's II algorithm:
```julia
julia> testPrimsII(vertices, connections, numberOfThreads, attempts)
```

##### A-star algorithm:
```julia
julia> testAStar(graphWidth, attempts)
```
Where:
  - **vertices** is the desired number of vertices in the graph
  - **connections** is the desired number of connections coming off each vertex
  - **attempts** is the number of times to run the correctness verification test
  - **numberOfThreads** is the number of threads the algorithm is te be run on
  - **graphWidth** is the width of the generated maze/graph

#### Benchmarking for Timing

In the REPL run the following command:
```julia 
julia> @benchmark <algorithm_function> setup=<graph_generation_method> samples=<num_runs> seconds=<num_seconds>
```
Where:
  - **<algorithm_function>** is the function cal to run the specific algorithm
  - **<graph_generation_method>** is the function call to generate the graph for the algorithm
  - **<num_runs>** is the desired number of times to run the algorithm in order to produce statistical timing values
  - **<num_seconds>** is the maximum run time of the benchmark, in seconds, before stopping the run and returning timing results for the amount of runs that _did_ occur in that time
  
An example use of the above command is:

```julia
julia> @benchmark astar(graph, graphWidth, startV, endV) setup=(graph = makeMaze(makeGrid(graphWidth))) samples=samplesToRun seconds=maxRuntime
```

See _benchmarkTest.jl_ for the other algorithm tests.

>_**Note:** to ensure results are printed to the terminal after running the benchmark there must not be a semi-colon at the end of the command._


  
