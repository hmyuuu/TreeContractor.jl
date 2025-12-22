using LinearAlgebra
using Random
using Test
using Statistics

include("../src/RankWidthAlgorithms.jl")
using .RankWidthAlgorithms

# --- 1. Circuit Generator ---
"""
    random_graph_state(n::Int, p::Float64=0.3)

Generates a random Erdos-Renyi graph.
"""
function random_graph_state(n::Int, p::Float64=0.3)
    G = Int.(rand(n, n) .< p)
    for i in 1:n; G[i,i] = 0; end
    return Symmetric(G)
end

"""
    perfect_binary_tree_graph(depth::Int)

Generates the adjacency matrix of a perfect binary tree of given depth.
Number of nodes = 2^(depth+1) - 1.
"""
function perfect_binary_tree_graph(depth::Int)
    n = 2^(depth+1) - 1
    G = zeros(Int, n, n)
    for i in 1:(2^depth - 1)
        left = 2*i
        right = 2*i + 1
        if left <= n
            G[i, left] = 1; G[left, i] = 1
        end
        if right <= n
            G[i, right] = 1; G[right, i] = 1
        end
    end
    return G
end

# --- 2. Linear Heuristic (Cuthill-McKee style) ---
"""
    linear_rank_width_heuristic(G)

Approximates Linear Rank-Width by finding a good ordering.
Simple BFS-based ordering (Reverse Cuthill-McKee).
"""
function linear_rank_width_heuristic(G::AbstractMatrix)
    n = size(G, 1)
    # Simple BFS ordering from a random node
    visited = falses(n)
    order = Int[]
    queue = [1]
    visited[1] = true
    
    while !isempty(queue)
        u = popfirst!(queue)
        push!(order, u)
        # Add neighbors
        neighbors = findall(!iszero, G[u, :])
        for v in neighbors
            if !visited[v]
                visited[v] = true
                push!(queue, v)
            end
        end
        
        # If queue empty but graph not disconnected, jump to next unvisited
        if isempty(queue) && length(order) < n
            next_start = findfirst(!, visited)
            if !isnothing(next_start)
                visited[next_start] = true
                push!(queue, next_start)
            end
        end
    end
    
    # Calculate Max Cut-Rank along this linear order
    max_rank = 0
    current_set = Int[]
    for i in 1:(n-1)
        push!(current_set, order[i])
        r = cut_rank(G, current_set)
        max_rank = max(max_rank, r)
    end
    return max_rank
end

# --- 3. Branching Heuristic (Greedy Split) ---
"""
    branching_rank_width_heuristic(G)

Approximates General Rank-Width using a recursive greedy split.
At each step, tries to split the vertex set V into (A, B) to minimize rank(A, B).
Simplification: Randomly tries 10 balanced splits and picks the best.
"""
function branching_rank_width_heuristic(G::AbstractMatrix)
    n = size(G, 1)
    return recursive_split_rank(G, collect(1:n))
end

function recursive_split_rank(G, vertices)
    n = length(vertices)
    if n <= 1
        return 0
    end
    
    best_rank = n # Worst case
    best_A = Int[]
    
    # Try random balanced splits
    n_trials = 20
    for _ in 1:n_trials
        # Randomly shuffle and split in half
        shuffled = shuffle(vertices)
        mid = div(n, 2)
        A = shuffled[1:mid]
        r = cut_rank(G, A)
        
        if r < best_rank
            best_rank = r
            best_A = A
        end
    end
    
    best_B = setdiff(vertices, best_A)
    
    # Recurse
    rank_A = recursive_split_rank(G, best_A)
    rank_B = recursive_split_rank(G, best_B)
    
    return max(best_rank, rank_A, rank_B)
end

# --- 4. Benchmark Runner ---
function run_hypothesis_test()
    println("--- Hypothesis H1 Verification: Linear vs Branching ---")
    println("| Graph Type | N  | Linear RW (Est) | Branching RW (Est) | Reduction |")
    println("|------------|----|-----------------|--------------------|-----------|")
    
    # 1. Random Graphs (High Rank-Width)
    configs = [
        (20, 0.3),
        (40, 0.3),
        (60, 0.3)
    ]
    
    for (n, p) in configs
        G = random_graph_state(n, p)
        lrw = linear_rank_width_heuristic(G)
        brw = branching_rank_width_heuristic(G)
        reduction = round(100 * (lrw - brw) / lrw; digits=1)
        println("| Random(p=$p) | $n | $lrw | $brw | $(reduction)% |")
    end

    # 2. Trees (Low Rank-Width, Med Path-Width)
    # Depth 4 -> 31 nodes
    # Depth 5 -> 63 nodes
    # Depth 6 -> 127 nodes
    tree_depths = [4, 5, 6]
    for d in tree_depths
        G = perfect_binary_tree_graph(d)
        n = size(G, 1)
        lrw = linear_rank_width_heuristic(G)
        brw = branching_rank_width_heuristic(G)
        # Note: True Rank-Width of a tree is 1. 
        # Branching heuristic might not find 1 exactly due to randomness, but should be low.
        reduction = round(100 * (lrw - brw) / lrw; digits=1)
        println("| Tree(d=$d)   | $n | $lrw | $brw | $(reduction)% |")
    end
end

run_hypothesis_test()
