module RankWidthAlgorithms

using LinearAlgebra
using Random

# Include submodules
include("Queyranne.jl")

export RankDecomposition, SubCubicTree
export rank_width, cut_rank
export Queyranne

"""
    SubCubicTree

A binary tree structure where each internal node has degree 3 (except possibly the root).
Used to represent the topology of a rank-decomposition.
"""
struct SubCubicTree
    id::Int
    left::Any # Union{SubCubicTree, Int}
    right::Any # Union{SubCubicTree, Int}
end

"""
    RankDecomposition

Stores the rank-decomposition of a graph.
"""
struct RankDecomposition
    G::AbstractMatrix
    tree::SubCubicTree
    width::Int
end

"""
    cut_rank(G::AbstractMatrix, A::Vector{Int})

Computes the rank of the cut (A, V \\ A) over GF(2).
"""
function cut_rank(G::AbstractMatrix, A::Vector{Int})
    n = size(G, 1)
    B = setdiff(1:n, A)
    if isempty(A) || isempty(B)
        return 0
    end
    
    submatrix = G[A, B]
    # GF(2) rank using Gaussian elimination
    M = copy(submatrix)
    rows, cols = size(M)
    pivot_row = 1
    for j in 1:cols
        if pivot_row > rows
            break
        end
        # Find pivot
        idx = findfirst(!iszero, @view M[pivot_row:end, j])
        if isnothing(idx)
            continue
        end
        i = pivot_row + idx - 1
        
        # Swap rows
        if i != pivot_row
            M[pivot_row, :], M[i, :] = M[i, :], M[pivot_row, :]
        end
        
        # Eliminate
        for k in 1:rows
            if k != pivot_row && !iszero(M[k, j])
                @view(M[k, :]) .⊻= @view(M[pivot_row, :])
            end
        end
        pivot_row += 1
    end
    return pivot_row - 1
end

"""
    find_best_split(G, vertices)

Helper to find a balanced split of vertices that minimizes cut_rank.
Uses a randomized greedy approach.
"""
function find_best_split(G::AbstractMatrix, vertices::Vector{Int})
    n = length(vertices)
    best_rank = n
    best_A = Int[]
    
    # Heuristic: Try 20 random balanced splits
    # Improvement: Also try linear sweeps or other simple heuristics?
    # For now, just random balanced.
    
    n_trials = 20
    for _ in 1:n_trials
        shuffled = shuffle(vertices)
        mid = div(n, 2)
        if mid < 1; mid = 1; end
        A = shuffled[1:mid]
        
        # Check rank
        # Note: We need to compute rank in the context of the WHOLE graph G
        r = cut_rank(G, A)
        
        if r < best_rank
            best_rank = r
            best_A = A
        end
    end
    
    if isempty(best_A)
        # Fallback
        best_A = vertices[1:div(n,2)]
    end
    
    return best_A, setdiff(vertices, best_A)
end

function build_tree_recursive(G::AbstractMatrix, vertices::Vector{Int}, id_counter::Ref{Int})
    if length(vertices) == 1
        return vertices[1]
    end
    
    A, B = find_best_split(G, vertices)
    
    # Recurse
    left_node = build_tree_recursive(G, A, id_counter)
    right_node = build_tree_recursive(G, B, id_counter)
    
    id_counter[] += 1
    return SubCubicTree(id_counter[], left_node, right_node)
end

"""
    rank_width(G::AbstractMatrix)

Approximates the rank-width of graph G using a recursive randomized heuristic.
Returns a RankDecomposition object.
"""
function rank_width(G::AbstractMatrix)
    n = size(G, 1)
    if n <= 1
        return RankDecomposition(G, SubCubicTree(1, nothing, nothing), 0)
    end
    
    id_counter = Ref(0)
    tree = build_tree_recursive(G, collect(1:n), id_counter)
    
    # Calculate width of the resulting tree
    # Note: The recursive construction minimized cuts locally.
    # We should traverse the tree to find the TRUE max width.
    # For simplicity, we'll re-calculate.
    
    max_w = 0
    # To do: Implement full tree traversal width calculation.
    # For now, we trust the construction logic approx.
    # But wait, we need to return a value.
    # Let's just return the root cut rank as a lower bound?
    # No, let's implement a quick traversal.
    
    # Helper to get leaves of a subtree
    function get_leaves(node::SubCubicTree)
        l = (node.left isa Int) ? [node.left] : get_leaves(node.left)
        r = (node.right isa Int) ? [node.right] : get_leaves(node.right)
        return vcat(l, r)
    end
    function get_leaves(node::Int)
        return [node]
    end

    function compute_width_recursive(node::SubCubicTree)
        # Cut defined by this node's edge to parent? 
        # Actually, in a rooted binary tree, every node defines a cut (subtree leaves vs rest).
        leaves = get_leaves(node)
        r = cut_rank(G, leaves)
        
        w_left = (node.left isa SubCubicTree) ? compute_width_recursive(node.left) : 0
        w_right = (node.right isa SubCubicTree) ? compute_width_recursive(node.right) : 0
        
        return max(r, w_left, w_right)
    end
    
    max_w = compute_width_recursive(tree)
    
    return RankDecomposition(G, tree, max_w)
end

end # module
