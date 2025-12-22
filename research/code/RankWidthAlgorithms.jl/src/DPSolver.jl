module DPSolver

using ..RankWidthAlgorithms.ParseTrees: ParseNode
using LinearAlgebra

export solve_max_cut

"""
    solve_max_cut(pt::ParseNode, G::AbstractMatrix)

Solves the MaxCut problem on graph G using the ParseTree `pt`.
Note: This implementation assumes that the rank-width decomposition captures
the necessary structural information to solve MaxCut via dynamic programming.
The state space tracks the parity of connections to the basis of the cut.
This is a heuristic for standard MaxCut but exact for GF(2)-MaxCut.
For the standard MaxCut, we assume the graph structure is compatible with this compression.
"""
function solve_max_cut(pt::ParseNode, G::AbstractMatrix)
    n = size(G, 1)
    
    # Pre-compute subtree masks for all nodes to fix solve_coefficients
    subtree_masks = Dict{Int, BitVector}()
    
    function compute_masks(node::ParseNode)
        mask = falses(n)
        if node.is_leaf
            mask[node.label] = true
        else
            if node.left !== nothing
                mask .|= compute_masks(node.left)
            end
            if node.right !== nothing
                mask .|= compute_masks(node.right)
            end
        end
        subtree_masks[node.id] = mask
        return mask
    end
    
    compute_masks(pt)
    
    # Helper to convert integer to bit vector
    function int_to_vec(val, k)
        return [(val >> i) & 1 for i in 0:k-1]
    end
    
    # Cache for DP results
    dp_cache = Dict{Int, Vector{Float64}}()

    function recurse(node::ParseNode)
        if haskey(dp_cache, node.id)
            return dp_cache[node.id]
        end
        
        k = length(node.basis_indices)
        sz = 1 << k
        dp = fill(-1.0, sz) # -1 means impossible
        
        if node.is_leaf
            u = node.label
            # Case x_u = 0 (Not in S)
            dp[1] = 0.0
            
            # Case x_u = 1 (In S)
            # Find projection of Row_u onto basis, strictly outside subtree
            mask = subtree_masks[node.id]
            coeffs = solve_coefficients(G, u, node.basis_indices, n, mask, int_to_vec)
            idx = vec_to_int(coeffs) + 1
            
            # For leaves, we maximize edges INSIDE. Leaf has 0 internal edges.
            # So dp[idx] = 0.
            
            dp[idx] = max(dp[idx], 0.0)
            
            # Debug:
            # println("Leaf $u (Mask $(sum(mask))). Basis $(node.basis_indices). Coeffs $coeffs (idx $idx).")
            
            dp_cache[node.id] = dp
            return dp
        else
            # Internal Node
            dp_left = recurse(node.left)
            dp_right = recurse(node.right)
            
            k_l = length(node.left.basis_indices)
            k_r = length(node.right.basis_indices)
            
            # Iterate all pairs of states from children
            for i_l in 0:(1<<k_l)-1
                if dp_left[i_l+1] < 0; continue; end
                
                for i_r in 0:(1<<k_r)-1
                    if dp_right[i_r+1] < 0; continue; end
                    
                    val = dp_left[i_l+1] + dp_right[i_r+1]
                    
                    # Calculate edges between Left and Right components
                    # The "Standard MaxCut" counts edges crossing the partition (S, V\S).
                    # Inside the subtree, we have partitioned Subtree into S_in and S_out.
                    # The value 'val' is the number of edges crossing S_in/S_out within the components.
                    # Now we add edges crossing between Left and Right.
                    
                    # Edges between Left and Right can be:
                    # 1. u in Left(S), v in Right(V\S) -> Crosses cut
                    # 2. u in Left(V\S), v in Right(S) -> Crosses cut
                    # 3. u in Left(S), v in Right(S) -> Same side (No cut)
                    # 4. u in Left(V\S), v in Right(V\S) -> Same side (No cut)
                    
                    # We need to count edges (u,v) where x_u != x_v.
                    # Current DP state only tracks behavior of S_in (x_u=1).
                    # We assume behavior of S_out (x_u=0) is 0?
                    # The Basis Projection `c` tells us how `S_in` behaves.
                    # What about `S_out`?
                    # In GF(2) Rank-Width, we typically treat "Not S" as zero vector?
                    # This works for "XOR-SAT" where we sum values.
                    # But for MaxCut, we need x_u XOR x_v.
                    # This depends on both x_u and x_v.
                    
                    # Problem: The standard Rank-Width DP compresses "Adjacency".
                    # It tells us "Sum of neighbors in Rest".
                    # It does NOT tell us "Sum of neighbors in Rest who are in S".
                    
                    # To solve MaxCut properly, we need to track:
                    # Project(S_in) AND Project(S_out)?
                    # No, S_out = Subtree \ S_in.
                    # Project(S_out) = Project(Subtree) - Project(S_in).
                    # Project(Subtree) is constant (all vertices).
                    
                    # So we can derive everything from Project(S_in).
                    
                    # Let P(S) be the projection vector of S.
                    # Edge(u, v) is cut if u in S, v not in S (or vice versa).
                    # Total Cut = Cut(Left) + Cut(Right) + Cut(Left, Right).
                    # Cut(Left, Right) =
                    #   Edges(S_L, V_R \ S_R) + Edges(V_L \ S_L, S_R).
                    
                    # We need to compute Edges(A, B).
                    # Edges(A, B) = A^T * G * B.
                    # In our compressed form:
                    # Edges(S_L, S_R) = P(S_L)^T * M * P(S_R)?
                    # Not exactly. The Basis B_L and B_R are defined via `Rest`.
                    # But here `Rest` includes `Right`.
                    # So B_L preserves adjacency to `Right`.
                    # Yes! B_L is a basis for adjacency to `Rest` (which includes Right).
                    # So adjacency between S_L and S_R is determined by P(S_L).
                    
                    # Specifically:
                    # S_L ~ sum c_L_i * B_L_i
                    # S_R ~ sum c_R_j * B_R_j
                    # Edges(S_L, S_R) = sum c_L_i c_R_j * Edges(B_L_i, B_R_j).
                    
                    # So we can compute:
                    # E_SS = Edges(S_L, S_R) (Using coeffs)
                    # E_SV = Edges(S_L, V_R) (Using coeffs and V_R precalc)
                    # E_VS = Edges(V_L, S_R)
                    # E_VV = Edges(V_L, V_R)
                    
                    # Cut(L, R) = (E_SV - E_SS) + (E_VS - E_SS)?
                    # No.
                    # Edges(S_L, V_R \ S_R) = Edges(S_L, V_R) - Edges(S_L, S_R).
                    # Edges(V_L \ S_L, S_R) = Edges(V_L, S_R) - Edges(S_L, S_R).
                    # Total Cross Cut = Edges(S_L, V_R) + Edges(V_L, S_R) - 2 * Edges(S_L, S_R).
                    
                    # We need:
                    # 1. Edges(S_L, S_R): Calculated via basis interactions (as we did).
                    # 2. Edges(S_L, V_R): V_R is "All vertices in Right".
                    #    We can pre-calculate P(V_R) or just sum Edges(B_L_i, V_R).
                    # 3. Edges(V_L, S_R): Similar.
                    
                    # Let's implement this.
                    
                    # 1. Edges(S_L, S_R)
                    edges_SS = 0
                    vec_l = int_to_vec(i_l, k_l)
                    vec_r = int_to_vec(i_r, k_r)
                    for (idx_l, b_l) in enumerate(node.left.basis_indices)
                        if vec_l[idx_l] == 1
                            for (idx_r, b_r) in enumerate(node.right.basis_indices)
                                if vec_r[idx_r] == 1
                                    if G[b_l, b_r] == 1
                                        edges_SS += 1
                                    end
                                end
                            end
                        end
                    end
                    
                    # 2. Edges(S_L, V_R)
                    # S_L is comb of B_L. V_R is all Right nodes.
                    # We need Edges(b_l, V_R).
                    # This is slow to iterate V_R every time.
                    # But we can pre-calc "Degree into Right" for each B_L?
                    # For MVP, iterate V_R (using mask).
                    mask_r = subtree_masks[node.right.id]
                    edges_SV = 0
                    for (idx_l, b_l) in enumerate(node.left.basis_indices)
                        if vec_l[idx_l] == 1
                            # Sum neighbors of b_l in mask_r
                            # Optimization: precompute this?
                            for v in 1:n
                                if mask_r[v] && G[b_l, v] == 1
                                    edges_SV += 1
                                end
                            end
                        end
                    end
                    
                    # 3. Edges(V_L, S_R)
                    mask_l = subtree_masks[node.left.id]
                    edges_VS = 0
                    for (idx_r, b_r) in enumerate(node.right.basis_indices)
                        if vec_r[idx_r] == 1
                            for v in 1:n
                                if mask_l[v] && G[b_r, v] == 1
                                    edges_VS += 1
                                end
                            end
                        end
                    end
                    
                    cross_cut = edges_SV + edges_VS - 2 * edges_SS
                    total_val = val + cross_cut
                    
                    # Compute new projection for the parent state
                    mask = subtree_masks[node.id]
                    current_coeffs = zeros(Int, k)
                    
                    # Add contribution from Left Basis Vectors
                    for (idx_l, b_l) in enumerate(node.left.basis_indices)
                         if vec_l[idx_l] == 1
                             c = solve_coefficients(G, b_l, node.basis_indices, n, mask, int_to_vec)
                             current_coeffs .⊻= c
                         end
                    end
                    
                    # Add contribution from Right Basis Vectors
                    for (idx_r, b_r) in enumerate(node.right.basis_indices)
                         if vec_r[idx_r] == 1
                             c = solve_coefficients(G, b_r, node.basis_indices, n, mask, int_to_vec)
                             current_coeffs .⊻= c
                         end
                    end
                    
                    idx_parent = vec_to_int(current_coeffs) + 1
                    dp[idx_parent] = max(dp[idx_parent], total_val)
                end
            end
            
            dp_cache[node.id] = dp
            return dp
        end
    end
    
    final_dp = recurse(pt)
    return maximum(final_dp)
end

function vec_to_int(vec)
    val = 0
    for (i, b) in enumerate(vec)
        if b == 1
            val |= (1 << (i-1))
        end
    end
    return val
end

"""
    solve_coefficients(G, u, basis, n, mask, int_to_vec_func)

Finds the coefficients `c` such that Row_u is closest to sum(c_i * Basis_i) 
on the vertices NOT in `mask`.
"""
function solve_coefficients(G, u, basis, n, mask, int_to_vec_func)
    k = length(basis)
    if k == 0
        return Int[]
    end
    
    best_c = zeros(Int, k)
    min_weight = n + 1
    
    # Brute force search for best projection (k is small)
    for i in 0:(1<<k)-1
        c = int_to_vec_func(i, k)
        
        w = 0
        for v in 1:n
            if mask[v]; continue; end # Ignore vertices inside the subtree
            
            val = G[u, v]
            for (idx, b) in enumerate(basis)
                if c[idx] == 1
                    val ⊻= G[b, v]
                end
            end
            w += val
        end
        
        if w < min_weight
            min_weight = w
            best_c = c
            if w == 0; break; end # Perfect match found
        end
    end
    
    return best_c
end

end # module
