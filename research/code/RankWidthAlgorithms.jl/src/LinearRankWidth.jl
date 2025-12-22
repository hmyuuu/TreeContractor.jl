module LinearRankWidth

using LinearAlgebra
using Random
using ..RankWidthAlgorithms: cut_rank, RankDecomposition, SubCubicTree

export LinearRankDecomposition, solve_linear_rank_width

"""
    LinearRankDecomposition

Stores the result of a Linear Rank-Width optimization.
`ordering` is a permutation of 1:n.
`width` is the maximum rank over all linear cuts.
`cut_ranks` stores the rank of the cut at each position i (split between i and i+1).
"""
struct LinearRankDecomposition
    ordering::Vector{Int}
    width::Int
    cut_ranks::Vector{Int}
end

"""
    calculate_linear_width(G, ordering)

Computes the linear rank-width of a specific ordering.
Returns (width, cut_ranks).
"""
function calculate_linear_width(G::AbstractMatrix, ordering::Vector{Int})
    n = length(ordering)
    if n <= 1
        return 0, Int[]
    end
    
    ranks = Int[]
    max_w = 0
    
    # Iterate through all n-1 cuts
    # Optimization: This is O(n * n^3) = O(n^4).
    # For n=100, this is 10^8 ops, acceptable for Julia.
    for i in 1:n-1
        # Cut is first i elements
        A = ordering[1:i]
        r = cut_rank(G, A)
        push!(ranks, r)
        if r > max_w
            max_w = r
        end
    end
    
    return max_w, ranks
end

"""
    initial_ordering(G)

Generates a few candidate orderings:
1. Random
2. BFS
3. DFS
4. Reverse Cuthill-McKee (approx via BFS degree)
"""
function generate_initial_orderings(G::AbstractMatrix)
    n = size(G, 1)
    candidates = Vector{Vector{Int}}()
    
    # 1. Identity
    push!(candidates, collect(1:n))
    
    # 2. Random (3 trials)
    for _ in 1:3
        push!(candidates, shuffle(1:n))
    end
    
    # 3. BFS (from random start)
    start_node = rand(1:n)
    visited = falses(n)
    q = [start_node]
    visited[start_node] = true
    bfs_order = Int[]
    while !isempty(q)
        u = popfirst!(q)
        push!(bfs_order, u)
        neighbors = findall(x -> x != 0, G[u, :])
        # Sort neighbors by degree (heuristic)
        sort!(neighbors, by=v->sum(G[v,:]))
        for v in neighbors
            if !visited[v]
                visited[v] = true
                push!(q, v)
            end
        end
    end
    # Handle disconnected components
    if length(bfs_order) < n
        remaining = setdiff(1:n, bfs_order)
        append!(bfs_order, remaining)
    end
    push!(candidates, bfs_order)
    
    return candidates
end

"""
    refine_ordering!(G, current_ordering)

Applies local search operations (Swap, Insert) to improve the ordering.
"""
function refine_ordering!(G::AbstractMatrix, ordering::Vector{Int})
    n = length(ordering)
    improved = true
    current_width, _ = calculate_linear_width(G, ordering)
    
    # Limit iterations to avoid infinite loops
    max_iter = 100
    iter = 0
    
    while improved && iter < max_iter
        improved = false
        iter += 1
        
        # Strategy: Find the "Bottleneck" cut and try to fix it.
        # But simple Hill Climbing is often robust enough.
        
        # 1. Try Swapping adjacent elements
        for i in 1:n-1
            # Swap i and i+1
            ordering[i], ordering[i+1] = ordering[i+1], ordering[i]
            
            # Check if better
            new_w, _ = calculate_linear_width(G, ordering)
            if new_w < current_width
                current_width = new_w
                improved = true
            else
                # Revert
                ordering[i], ordering[i+1] = ordering[i+1], ordering[i]
            end
        end
        
        if improved; continue; end
        
        # 2. Try Insertion (Move element i to position j)
        # This is expensive O(n^2) * Cost. Limit to random samples?
        # Or just try moving the element at the MAX CUT boundary?
        
        _, ranks = calculate_linear_width(G, ordering)
        max_cut_idx = argmax(ranks)
        
        # Try moving elements around the max cut
        # Elements involved: ordering[max_cut_idx] and ordering[max_cut_idx+1]
        
        # Try moving ordering[max_cut_idx] to somewhere else
        elem = ordering[max_cut_idx]
        best_pos = max_cut_idx
        
        # Try a few random positions
        for _ in 1:10
            target = rand(1:n)
            if target == max_cut_idx; continue; end
            
            # Create temp ordering
            temp_ord = copy(ordering)
            deleteat!(temp_ord, max_cut_idx)
            insert!(temp_ord, target, elem)
            
            w, _ = calculate_linear_width(G, temp_ord)
            if w < current_width
                current_width = w
                ordering[:] = temp_ord
                improved = true
                break
            end
        end
    end
    
    return ordering, current_width
end

"""
    solve_linear_rank_width(G::AbstractMatrix)

Main solver function.
"""
function solve_linear_rank_width(G::AbstractMatrix)
    n = size(G, 1)
    if n <= 1
        return LinearRankDecomposition([1], 0, [])
    end
    
    candidates = generate_initial_orderings(G)
    best_ord = Int[]
    best_w = n + 1
    best_ranks = Int[]
    
    for ord in candidates
        refined_ord, w = refine_ordering!(G, copy(ord))
        if w < best_w
            best_w = w
            best_ord = refined_ord
        end
    end
    
    # Final check
    _, best_ranks = calculate_linear_width(G, best_ord)
    
    return LinearRankDecomposition(best_ord, best_w, best_ranks)
end

"""
    to_parse_tree(decomp::LinearRankDecomposition)

Converts a Linear Decomposition to a Caterpillar ParseTree (SubCubicTree).
Useful for interoperability with the main solver.
"""
function to_parse_tree(decomp::LinearRankDecomposition)
    # TODO: Implement conversion if needed
    error("Not implemented")
end

end # module
