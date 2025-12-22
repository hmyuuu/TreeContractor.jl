module ParseTrees

using ..RankWidthAlgorithms: SubCubicTree, RankDecomposition, cut_rank
using LinearAlgebra

export ParseNode, build_parse_tree

"""
    ParseNode

Represents a node in the algebraic parse tree used for Dynamic Programming.
Unlike SubCubicTree (which just captures topology), ParseNode contains
information needed for the bottom-up computation, such as the basis of the cut.
"""
struct ParseNode
    id::Int
    is_leaf::Bool
    label::Int # For leaves: vertex index in G
    
    # Children
    left::Union{ParseNode, Nothing}
    right::Union{ParseNode, Nothing}
    
    # The basis of the cut between this subtree and the rest of the graph.
    # Stored as a list of indices (rows in G) that form a basis for rows[leaves, rest].
    # Actually, for general Rank-Width, we need the actual basis vectors or a way to project.
    # But for GF(2) adjacency matrices, we can just store the basis indices if we assume row-space.
    # Let's store the basis indices for now.
    basis_indices::Vector{Int} 
    cut_rank::Int
end

"""
    build_parse_tree(rd::RankDecomposition)

Converts a RankDecomposition into a fully annotated ParseTree ready for DP.
"""
function build_parse_tree(rd::RankDecomposition)
    # We traverse the SubCubicTree and compute bases.
    # Note: SubCubicTree is unrooted (conceptually), but stored as rooted.
    # The root of SubCubicTree represents the cut (V, {}), which has rank 0.
    
    n = size(rd.G, 1)
    
    function recurse(node::SubCubicTree)
        # Helper to process a child which might be Int or SubCubicTree
        function process_child(child)
            if child isa Int
                # Leaf
                # Cut is ({child}, V\{child})
                # Basis: if row child is not zero, basis is {child}. Else empty.
                # Actually, we need to compute the rank of the cut in G.
                rank = cut_rank(rd.G, [child])
                # We need to pick a basis. The row 'child' itself is the candidate.
                # If rank is 1, then {child} is the basis index.
                basis = (rank > 0) ? [child] : Int[]
                return ParseNode(child, true, child, nothing, nothing, basis, rank)
            else
                # Internal node
                return recurse(child)
            end
        end
        
        p_left = (node.left === nothing) ? nothing : process_child(node.left)
        p_right = (node.right === nothing) ? nothing : process_child(node.right)
        
        # Now we are at 'node'.
        # The set of vertices in this subtree is Union(leaves(left), leaves(right)).
        leaves = Int[]
        if p_left !== nothing
            append!(leaves, get_subtree_leaves(p_left))
        end
        if p_right !== nothing
            append!(leaves, get_subtree_leaves(p_right))
        end
        
        # Calculate Cut Rank and Basis for this node (edge to parent)
        # Note: For the global root, this should be 0 and empty.
        rank = cut_rank(rd.G, leaves)
        
        # Compute actual basis indices for the cut (leaves, rest)
        # We perform Gaussian elimination on G[leaves, rest] to find independent rows.
        # The indices of these rows (subset of leaves) form the basis.
        basis = compute_basis(rd.G, leaves)
        
        return ParseNode(node.id, false, 0, p_left, p_right, basis, rank)
    end
    
    # Root of SubCubicTree
    # The SubCubicTree struct from RankWidthAlgorithms:
    # left/right are Union{SubCubicTree, Int}.
    
    # We need to handle the case where the root itself is just a leaf (n=1)
    # But RankDecomposition usually has a tree.
    
    if rd.tree.left === nothing && rd.tree.right === nothing
         # Single node tree?
         # If n=1, rank_width returns SubCubicTree(1, nothing, nothing).
         # Wait, logic in rank_width: "if n<=1 return ... SubCubicTree(1, nothing, nothing)"
         # This represents a graph with 1 vertex?
         # But usually a tree has at least leaves.
         return ParseNode(1, true, 1, nothing, nothing, Int[], 0)
    end
    
    return recurse(rd.tree)
end

function get_subtree_leaves(node::ParseNode)
    if node.is_leaf
        return [node.label]
    end
    l = (node.left !== nothing) ? get_subtree_leaves(node.left) : Int[]
    r = (node.right !== nothing) ? get_subtree_leaves(node.right) : Int[]
    return vcat(l, r)
end

"""
    compute_basis(G, rows_subset)

Selects a subset of `rows_subset` that forms a basis for the row-space of G[rows_subset, V \\ rows_subset].
"""
function compute_basis(G::AbstractMatrix, rows_subset::Vector{Int})
    n = size(G, 1)
    cols_subset = setdiff(1:n, rows_subset)
    
    if isempty(rows_subset) || isempty(cols_subset)
        return Int[]
    end
    
    submatrix = G[rows_subset, cols_subset]
    
    # We need to find pivot rows in this submatrix.
    # Gaussian elimination on rows.
    # We want indices in 'rows_subset' that correspond to pivot rows.
    
    # Copy to avoid mutation
    M = copy(submatrix) .% 2
    r, c = size(M)
    
    basis_local_indices = Int[]
    
    pivot_row = 1
    pivot_col = 1
    
    # We transpose the logic? No, we want basis of ROWS.
    # Standard row-reduction finds basis of rows at the top.
    # But we want to know WHICH original rows form the basis.
    # Actually, row-reduction mixes rows. 
    # To find a basis subset of original rows, we should perform column reduction on M^T?
    # Or simply: Greedily select rows that are independent of previously selected ones.
    
    # Let's use a simpler greedy approach with LinearAlgebra (or manual GF2)
    # Iterate rows, check if independent of current basis.
    
    # Optimization: Use Gaussian elimination on M^T (columns = original rows).
    # The pivot columns correspond to the basis rows.
    
    Mt = collect(transpose(M)) # cols are the original rows
    
    # Row reduce Mt.
    # Pivot columns in the reduced Mt correspond to linearly independent columns in Mt,
    # which are linearly independent rows in M.
    
    reduced_Mt, pivots = row_reduce_with_pivots(Mt)
    
    # pivots is a list of column indices where pivots occur.
    # These indices correspond to the index in 'rows_subset'.
    
    return rows_subset[pivots]
end

function row_reduce_with_pivots(A::Matrix{Int})
    M = copy(A)
    rows, cols = size(M)
    pivots = Int[]
    
    current_row = 1
    for j in 1:cols
        if current_row > rows
            break
        end
        
        # Find pivot in column j
        pivot_idx = -1
        for i in current_row:rows
            if M[i, j] != 0
                pivot_idx = i
                break
            end
        end
        
        if pivot_idx != -1
            # Swap
            if pivot_idx != current_row
                M[current_row, :], M[pivot_idx, :] = M[pivot_idx, :], M[current_row, :]
            end
            
            # Record pivot
            push!(pivots, j)
            
            # Eliminate
            for i in 1:rows
                if i != current_row && M[i, j] != 0
                    M[i, :] = (M[i, :] .+ M[current_row, :]) .% 2
                end
            end
            
            current_row += 1
        end
    end
    
    return M, pivots
end

end # module
