module LocalSearch

using LinearAlgebra
using ..RankWidthAlgorithms
# RankWidthAlgorithms exports cut_rank.

export refine_decomposition

"""
    total_contraction_cost(G::AbstractMatrix, tree::SubCubicTree)

Computes the sum of 2^rank(e) for all edges e in the tree.
For a rooted tree, each node u (except root) defines an edge (parent -> u).
The cut is (Leaves(u), V \\ Leaves(u)).
"""
function total_contraction_cost(G::AbstractMatrix, tree::SubCubicTree)
    cost = 0.0
    
    # Traverse
    # We need a helper that returns the list of leaves for each node
    # to compute the rank.
    
    # Recursive helper returns (leaves_vector, cost_subtree)
    function traverse(node::SubCubicTree)
        (t_leaves_l, t_cost_l) = (node.left isa SubCubicTree) ? traverse(node.left) : ([node.left], 0.0)
        (t_leaves_r, t_cost_r) = (node.right isa SubCubicTree) ? traverse(node.right) : ([node.right], 0.0)
        
        t_leaves = vcat(t_leaves_l, t_leaves_r)
        
        t_r_l = cut_rank(G, t_leaves_l)
        t_r_r = cut_rank(G, t_leaves_r)
        
        # println("Node $(node.id): Left Leaves $(t_leaves_l) Rank $t_r_l. Right Leaves $(t_leaves_r) Rank $t_r_r.")
        
        t_c_l = (2.0)^t_r_l
        t_c_r = (2.0)^t_r_r
        
        t_current_cost = t_cost_l + t_cost_r + t_c_l + t_c_r
        
        # println("Traverse Node $(node.id) returning leaves $t_leaves")
        return (t_leaves, t_current_cost)
    end
    
    # Root
    (leaves_l, cost_l) = (tree.left isa SubCubicTree) ? traverse(tree.left) : ([tree.left], 0.0)
    # println("Root Left returned: $leaves_l")
    (leaves_r, cost_r) = (tree.right isa SubCubicTree) ? traverse(tree.right) : ([tree.right], 0.0)
    
    # Edges from root to children
    r_l = cut_rank(G, leaves_l)
    r_r = cut_rank(G, leaves_r)
    
    # println("ROOT: Left $(leaves_l) Rank $r_l. Right $(leaves_r) Rank $r_r.")
    
    # Root itself doesn't have a parent edge.
    return cost_l + cost_r + (2.0)^r_l + (2.0)^r_r
end

"""
    get_all_internal_edges(tree)

Returns a list of (parent_node, child_direction) identifying internal edges.
Direction: :left or :right.
"""
function get_internal_edges(tree::SubCubicTree)
    edges = []
    
    function recurse(node::SubCubicTree, path)
        if node.left isa SubCubicTree
            push!(edges, (path, :left))
            recurse(node.left, vcat(path, [:left]))
        end
        if node.right isa SubCubicTree
            push!(edges, (path, :right))
            recurse(node.right, vcat(path, [:right]))
        end
    end
    
    recurse(tree, [])
    return edges
end

"""
    apply_rotation(tree, path_to_parent, direction, swap_choice)

Performs an NNI move.
path_to_parent: Path to 'u'
direction: :left or :right (where 'v' is)
swap_choice: :inner_left or :inner_right (which child of 'v' to swap with 'u's other child)

Returns new tree.
"""
function apply_rotation(tree::SubCubicTree, path, direction, swap_choice)
    # Reconstruct tree along the path
    if isempty(path)
        # We are at 'u' (the root of the rotation)
        u = tree
        if direction == :left
            v = u.left
            other_u = u.right # 'A'
            
            # v has children B, C
            if swap_choice == :inner_left
                B = v.left
                C = v.right
                # Swap A and B
                # New u: u(B, v(A, C))
                new_v = SubCubicTree(v.id, other_u, C)
                new_u = SubCubicTree(u.id, B, new_v)
                return new_u
            else # :inner_right
                B = v.left
                C = v.right
                # Swap A and C
                # New u: u(C, v(B, A))
                new_v = SubCubicTree(v.id, B, other_u)
                new_u = SubCubicTree(u.id, C, new_v)
                return new_u
            end
        else # direction == :right
            v = u.right
            other_u = u.left # 'A'
            
            if swap_choice == :inner_left
                B = v.left
                C = v.right
                # Swap A and B
                # New u: u(v(A, C), B) ? 
                # u had A (left), v (right). v had B (left), C (right).
                # Swap A and B.
                # u now has B (left), v (right). v has A (left), C (right).
                new_v = SubCubicTree(v.id, other_u, C)
                new_u = SubCubicTree(u.id, B, new_v)
                return new_u
            else
                B = v.left
                C = v.right
                # Swap A and C
                # u has C (left), v has B, A.
                new_v = SubCubicTree(v.id, B, other_u)
                new_u = SubCubicTree(u.id, C, new_v)
                return new_u
            end
        end
    else
        # Recurse down
        step = path[1]
        if step == :left
            new_left = apply_rotation(tree.left, path[2:end], direction, swap_choice)
            return SubCubicTree(tree.id, new_left, tree.right)
        else
            new_right = apply_rotation(tree.right, path[2:end], direction, swap_choice)
            return SubCubicTree(tree.id, tree.left, new_right)
        end
    end
end

"""
    refine_decomposition(rd::RankDecomposition)

Greedily improves the decomposition by applying tree rotations to minimize cost.
"""
function refine_decomposition(rd::RankDecomposition)
    curr_tree = rd.tree
    G = rd.G
    curr_cost = total_contraction_cost(G, curr_tree)
    
    improved = true
    iter = 0
    max_iter = 100 # Safety break
    
    while improved && iter < max_iter
        improved = false
        iter += 1
        
        # Get all internal edges (potential rotation sites)
        candidates = get_internal_edges(curr_tree)
        
        for (path, dir) in candidates
            # Try both swaps
            for swap in [:inner_left, :inner_right]
                # To apply rotation, we need to ensure the node at 'dir' is actually SubCubicTree
                # get_internal_edges guarantees this.
                
                new_tree = apply_rotation(curr_tree, path, dir, swap)
                new_cost = total_contraction_cost(G, new_tree)
                
                if new_cost < curr_cost
                    curr_tree = new_tree
                    curr_cost = new_cost
                    improved = true
                    # Restart search from new tree (Greedy First Improvement)
                    break 
                end
            end
            if improved; break; end
        end
    end
    
    return RankDecomposition(G, curr_tree, rd.width) # Note: width might have changed, technically should recompute.
end

end # module
