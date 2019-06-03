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
In order to run Julia multi-threaded the number of threads to be used needs to be set **BEFORE** opening and running the REPL. To do this, navigate to julia.exe, then:

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
 
julia>
```

### Troubleshooting
Julia has documentation available at https://docs.julialang.org/en/v1/.  
Getting Started: https://docs.julialang.org/en/v1/manual/getting-started/  
Using the REPL: https://docs.julialang.org/en/v1/stdlib/REPL/index.html  
Multi-threading: https://docs.julialang.org/en/v1/manual/parallel-computing/index.html  

### Testing

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

#### Verifying Correctness

#### Benchmarking for Timing

In the REPL run the following command:
```julia 
julia> @benchmark <method_signature> setup=<graph_generation_method> samples=<num_runs> seconds=<num_seconds>
```
Where:
  - <method_signature> is
  - <graph_generation_method>
  - <num_runs>
  - <num_seconds>
  
An example use of the above command is:

```julia
julia> call_the_function()
```



- imports and packages needed
- helper functions? i.e. maze and graph generation
- flow for running each algorithm
  - running it
  - benchmarking it

  
