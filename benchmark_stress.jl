using Pkg
Pkg.activate("research/code/RankWidthAlgorithms.jl")
Pkg.instantiate()

# Add src to LOAD_PATH so we can find the module
push!(LOAD_PATH, "research/code/RankWidthAlgorithms.jl/src")

# Alternatively, include the file directly if module loading fails
try
    using RankWidthAlgorithms
catch
    include("research/code/RankWidthAlgorithms.jl/src/RankWidthAlgorithms.jl")
    using .RankWidthAlgorithms
end

using LinearAlgebra
using Random
using Test

# Include the generator manually since it's not in the package src yet
include("research/code/RankWidthAlgorithms.jl/benchmark/hard_graphs.jl")
using .HardGraphs

println("=== Rank-Width Solver Stress Test ===")

function test_graph(name, adj)
    n = size(adj, 1)
    println("\nTesting $name (n=$n)...")
    
    t_start = time()
    rw = rank_width(adj)
    t_end = time()
    
    println("  Width: $(rw.width)")
    println("  Time:  $(round(t_end - t_start, digits=4))s")
    return rw.width
end

# 1. Random Graphs (Expected: High Width)
# For G(n, 0.5), rw ~ n/3 or similar.
for n in [10, 15, 20]
    adj = HardGraphs.generate_random_graph(n, 0.5)
    test_graph("Random G($n, 0.5)", adj)
end

# 2. Grid Graphs (Expected: Width ~ min(m,n))
# 3x3 Grid -> n=9. Width should be small (~3)
adj_grid = HardGraphs.generate_grid_graph(3, 3)
test_graph("Grid 3x3", adj_grid)

# 4x4 Grid -> n=16. Width should be higher (~4)
adj_grid4 = HardGraphs.generate_grid_graph(4, 4)
test_graph("Grid 4x4", adj_grid4)

# 3. Paley Graphs (Expander)
# q=13 (13 = 1 mod 4)
adj_paley13 = HardGraphs.generate_paley_graph(13)
test_graph("Paley(13)", adj_paley13)

# q=17 (17 = 1 mod 4)
adj_paley17 = HardGraphs.generate_paley_graph(17)
test_graph("Paley(17)", adj_paley17)

println("\n=== Stress Test Complete ===")
