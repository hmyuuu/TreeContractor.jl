module LocalSearch

using LinearAlgebra
using ..RankWidthAlgorithms: SubCubicTree, RankDecomposition, cut_rank

export refine_decomposition

# ==============================================================================
# 1. Mutable Tree Structure for Easy Manipulation
# ==============================================================================

mutable struct MNode
    id::Int
    parent::Union{MNode, Nothing}
    left::Union{MNode, Nothing}
    right::Union{MNode, Nothing}
    is_leaf::Bool
    leaf_label::Int
end

function MNode(label::Int)
    return MNode(0, nothing, nothing, nothing, true, label)
end

function MNode(id::Int, left::MNode, right::MNode)
    node = MNode(id, nothing, left, right, false, 0)
    left.parent = node
    right.parent = node
    return node
end

# Convert immutable SubCubicTree to MNode
function to_mutable(tree::SubCubicTree)::MNode
    if tree.left isa Int && tree.right isa Int
        # This shouldn't happen for a valid internal node unless it's a tiny tree
        # But wait, SubCubicTree definition: left/right are Union{SubCubicTree, Int}
        # If both are Int, it's a root with 2 leaves?
        l = MNode(tree.left)
        r = MNode(tree.right)
        return MNode(tree.id, l, r)
    end
    
    l = (tree.left isa Int) ? MNode(tree.left) : to_mutable(tree.left)
    r = (tree.right isa Int) ? MNode(tree.right) : to_mutable(tree.right)
    
    return MNode(tree.id, l, r)
end

function to_mutable(val::Int)::MNode
    return MNode(val)
end

# Convert MNode back to SubCubicTree
function to_immutable(node::MNode)::Union{SubCubicTree, Int}
    if node.is_leaf
        return node.leaf_label
    end
    
    l = to_immutable(node.left)
    r = to_immutable(node.right)
    
    return SubCubicTree(node.id, l, r)
end

# ==============================================================================
# 2. Tree Helpers
# ==============================================================================

function get_leaves(node::MNode)::Vector{Int}
    if node.is_leaf
        return [node.leaf_label]
    end
    return vcat(get_leaves(node.left), get_leaves(node.right))
end

"""
    get_internal_edges(root)

Returns a list of (parent, child) pairs representing internal edges.
"""
function get_internal_edges(node::MNode)
    edges = Vector{Tuple{MNode, MNode}}()
    if node.is_leaf
        return edges
    end
    
    # Process children
    if !node.left.is_leaf
        push!(edges, (node, node.left))
        append!(edges, get_internal_edges(node.left))
    end
    if !node.right.is_leaf
        push!(edges, (node, node.right))
        append!(edges, get_internal_edges(node.right))
    end
    
    return edges
end

# ==============================================================================
# 3. Local Search Logic
# ==============================================================================

"""
    refine_decomposition(G, tree_root)

Iteratively attempts to reduce the rank-width of the decomposition.
"""
function refine_decomposition(G::AbstractMatrix, tree_root::SubCubicTree)
    root = to_mutable(tree_root)
    improved = true
    max_iter = 100 # Safety break
    iter = 0
    
    current_width = calculate_width(G, root)
    
    while improved && iter < max_iter
        improved = false
        iter += 1
        
        # Identify critical edges (those with rank == current_width)
        # We want to break the bottleneck.
        edges = get_internal_edges(root)
        
        # Sort edges by rank descending? Or just iterate all?
        # Let's iterate all internal edges and try to optimize.
        
        for (parent, child) in edges
            # An internal edge connects 'parent' and 'child'.
            # 'child' is one of parent's children (say left).
            # The edge separates the tree into 2 components.
            # We focus on the node 'parent' and 'child'.
            # This edge corresponds to a 3-way split if we look at the neighbors.
            
            # Configuration:
            #      U (grandparent)
            #      |
            #      P (parent)
            #     / \
            #    C   Y (sibling of C)
            #   / \
            #  A   B
            
            # The edge P-C partitions vertices into:
            # 1. Leaves(A) U Leaves(B) (below C)
            # 2. Leaves(Y) U Leaves(U...) (above P)
            
            # We can perform a rotation around the edge P-C.
            # Current neighbors of P (excluding U): C, Y
            # Current neighbors of C (excluding P): A, B
            #
            # Current Split: {A, B} vs {Y, Rest}
            #
            # Alternative 1: Swap A and Y.
            # New P connects to A, C'. C' connects to Y, B.
            # New Split at P-C': {Y, B} vs {A, Rest}
            #
            # Alternative 2: Swap B and Y.
            # New Split at P-C'': {Y, A} vs {B, Rest}
            
            # Note: We need to handle the case where P is root correctly.
            # If P is root, "Rest" is empty? No, root has 2 children.
            # If P is root, we have neighbors L, R.
            # If we descend to L, it has L.L, L.R.
            # Root edge doesn't really exist as a "cut" distinct from its children.
            # We only rotate internal edges.
            
            # Let's verify the "child" is indeed a child of "parent"
            is_left_child = (parent.left === child)
            sibling = is_left_child ? parent.right : parent.left
            
            A = child.left
            B = child.right
            Y = sibling
            
            # We have 3 configurations of grouping (A, B, Y):
            # 1. (A, B) - current
            # 2. (A, Y) - swap B and Y
            # 3. (B, Y) - swap A and Y
            
            # We evaluate the max rank of the 3 edges incident to the new central node?
            # Actually, local search typically minimizes the rank of the *central* edge P-C.
            # But we must ensure we don't increase rank of P-Y or C-A or C-B too much.
            
            # Let's calculate the cut ranks for the 3 permutations.
            leaves_A = get_leaves(A)
            leaves_B = get_leaves(B)
            leaves_Y = get_leaves(Y)
            
            # The "Rest" is everything else.
            # Rank(S) = Rank(V \ S).
            
            rank_1 = cut_rank(G, vcat(leaves_A, leaves_B)) # Current P-C edge
            rank_2 = cut_rank(G, vcat(leaves_A, leaves_Y)) # Swap B, Y
            rank_3 = cut_rank(G, vcat(leaves_B, leaves_Y)) # Swap A, Y
            
            # We take the best configuration
            best_r = min(rank_1, rank_2, rank_3)
            
            if best_r < rank_1
                # We found an improvement for this specific cut!
                # Apply the swap.
                # println("Improving edge rank from $rank_1 to $best_r")
                
                if rank_2 == best_r
                    # Swap B and Y
                    # P connects to C, B (now sibling is B)
                    # C connects to A, Y
                    
                    # Update pointers
                    # P.child is still C
                    # P.sibling (other child) becomes B
                    if is_left_child
                        parent.right = B
                        B.parent = parent
                    else
                        parent.left = B
                        B.parent = parent
                    end
                    
                    # C.right (was B) becomes Y
                    child.right = Y
                    Y.parent = child
                    
                    improved = true
                    break # Restart search
                elseif rank_3 == best_r
                    # Swap A and Y
                    # P connects to C, A (now sibling is A)
                    # C connects to B, Y
                    
                    if is_left_child
                        parent.right = A
                        A.parent = parent
                    else
                        parent.left = A
                        A.parent = parent
                    end
                    
                    child.left = Y
                    Y.parent = child
                    
                    improved = true
                    break # Restart search
                end
            end
        end
        
        # Re-calculate global width to see if we improved the global metric
        new_w = calculate_width(G, root)
        if new_w < current_width
            current_width = new_w
        end
    end
    
    # Return immutable tree
    # Note: If root changed? Root structure is preserved (we only swapped descendants).
    return RankDecomposition(G, to_immutable(root), current_width)
end

function calculate_width(G::AbstractMatrix, node::MNode)
    # Calculate max cut rank over all edges in the subtree
    if node.is_leaf
        return 0
    end
    
    
    # Rank of the cut defined by this node (edge to parent)
    # Root edge doesn't count (it separates V from Empty).
    r = 0
    if node.parent !== nothing
        leaves = get_leaves(node)
        r = cut_rank(G, leaves)
    end
    
    w_left = (node.left !== nothing) ? calculate_width(G, node.left) : 0
    w_right = (node.right !== nothing) ? calculate_width(G, node.right) : 0
    
    return max(r, w_left, w_right)
end

end # module
