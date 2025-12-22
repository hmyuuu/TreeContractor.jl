using LinearAlgebra
using Random
using Printf

# Ensure the package is loaded
include("../code/RankWidthAlgorithms.jl/src/RankWidthAlgorithms.jl")
using .RankWidthAlgorithms

function generate_random_graph(n, p)
    adj = zeros(Int, n, n)
    for i in 1:n
        for j in i+1:n
            if rand() < p
                adj[i, j] = adj[j, i] = 1
            end
        end
    end
    return adj
end

function run_demo()
    println("="^60)
    println("🚀 Rank-Width Solver Demo: MaxCut via GF(2) Rank-Decomposition")
    println("="^60)

    # 1. Setup Problem
    n = 15
    p = 0.3
    println("\n[1] Generating Random Graph (n=$n, p=$p)...")
    Random.seed!(42) # Reproducibility
    G = generate_random_graph(n, p)
    
    # Calculate density
    density = sum(G) / (n*(n-1))
    println("    Graph generated. Density: $(round(density, digits=2))")

    # 2. Compute Decomposition
    println("\n[2] Computing Rank-Width Decomposition...")
    t_start = time()
    
    # We use the full pipeline: Queyranne -> LocalSearch
    rw_decomp = rank_width(G; refine=true)
    
    t_decomp = time() - t_start
    println("    Done in $(round(t_decomp, digits=3))s.")
    println("    Calculated Rank-Width: $(rw_decomp.width)")

    # 3. Build Parse Tree
    println("\n[3] Building Algebraic Parse Tree...")
    t_start = time()
    parse_tree = ParseTrees.build_parse_tree(rw_decomp)
    t_tree = time() - t_start
    println("    Done in $(round(t_tree, digits=3))s.")
    println("    Root Cut Rank: $(parse_tree.cut_rank) (Should be 0)")

    # 4. Solve MaxCut
    println("\n[4] Solving MaxCut via Dynamic Programming...")
    t_start = time()
    max_cut_val = DPSolver.solve_max_cut(parse_tree, G)
    t_solve = time() - t_start
    
    println("    Done in $(round(t_solve, digits=3))s.")
    println("    🏆 MaxCut Value: $max_cut_val")
    
    # 5. Summary
    println("\n" * "="^60)
    println("📊 Performance Summary")
    println("-"^60)
    @printf "Graph Size:       %d vertices\n" n
    @printf "Rank-Width:       %d\n" rw_decomp.width
    @printf "Decomposition:    %.4f s\n" t_decomp
    @printf "Parse Tree:       %.4f s\n" t_tree
    @printf "DP Solve:         %.4f s\n" t_solve
    println("="^60)
end

run_demo()
