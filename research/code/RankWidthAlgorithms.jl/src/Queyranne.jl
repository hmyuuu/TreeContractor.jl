module Queyranne

using LinearAlgebra

# ==============================================================================
# 1. Abstract Interface
# ==============================================================================

"""
    AbstractSymmetricSubmodularFunction

Abstract type for a symmetric submodular set function f: 2^V -> R.
Must implement:
- `evaluate(f, S::BitSet)::Float64`
- `ground_set_size(f)::Int`
"""
abstract type AbstractSymmetricSubmodularFunction end

function evaluate(f::AbstractSymmetricSubmodularFunction, S::BitSet)::Float64
    error("Method evaluate not implemented for $(typeof(f))")
end

function ground_set_size(f::AbstractSymmetricSubmodularFunction)::Int
    error("Method ground_set_size not implemented for $(typeof(f))")
end

# ==============================================================================
# 2. Concrete Implementations
# ==============================================================================

"""
    MatrixRankFunction(M::Matrix{Int})

Represents the cut-rank function of a matrix M over GF(2).
f(S) = rank(M[S, V\\S])
"""
struct MatrixRankFunction <: AbstractSymmetricSubmodularFunction
    M::Matrix{Int}
    n::Int
    
    function MatrixRankFunction(M::Matrix{Int})
        rows, cols = size(M)
        if rows != cols
            # For rank-width, we typically work with adjacency matrices (symmetric)
            # But general matrices work for bipartite rank-width.
            # Queyranne assumes symmetric submodularity.
            # Cut-rank is symmetric submodular even for non-symmetric matrices?
            # Yes, rank(M[S, V\S]) = rank(M[V\S, S]^T) = rank(M[V\S, S])? No.
            # WAIT: For general matrices, cut-rank is NOT symmetric.
            # Rank-Width is defined for GRAPHS (Adjacency Matrix is symmetric).
            # If M is symmetric, then M[S, V\S] = M[V\S, S]^T, so ranks are equal.
            if !issymmetric(M)
                error("Matrix must be symmetric for Rank-Width application (to ensure symmetric submodularity).")
            end
        end
        new(M, rows)
    end
end

ground_set_size(f::MatrixRankFunction) = f.n

function evaluate(f::MatrixRankFunction, S::BitSet)::Float64
    # Create the submatrix M[S, V\S]
    # In Julia, we can index with arrays.
    S_indices = collect(S)
    if isempty(S_indices) || length(S_indices) == f.n
        return 0.0
    end
    
    V_minus_S = setdiff(1:f.n, S_indices)
    
    submatrix = f.M[S_indices, V_minus_S]
    
    # Compute rank over GF(2)
    return Float64(rank_gf2(submatrix))
end

"""
    rank_gf2(A::Matrix{Int})

Computes the rank of a binary matrix A over GF(2).
"""
function rank_gf2(A::Matrix{Int})
    rows, cols = size(A)
    if rows == 0 || cols == 0
        return 0
    end
    
    M = copy(A) .% 2
    rank_val = 0
    
    # Gaussian elimination over GF(2)
    pivot_row = 1
    pivot_col = 1
    
    while pivot_row <= rows && pivot_col <= cols
        # Find pivot
        sel = -1
        for i in pivot_row:rows
            if M[i, pivot_col] == 1
                sel = i
                break
            end
        end
        
        if sel == -1
            # No pivot in this column
            pivot_col += 1
            continue
        end
        
        # Swap rows
        if sel != pivot_row
            M[pivot_row, :], M[sel, :] = M[sel, :], M[pivot_row, :]
        end
        
        # Eliminate
        for i in 1:rows
            if i != pivot_row && M[i, pivot_col] == 1
                M[i, :] = (M[i, :] .+ M[pivot_row, :]) .% 2
            end
        end
        
        rank_val += 1
        pivot_row += 1
        pivot_col += 1
    end
    
    return rank_val
end

# ==============================================================================
# 3. Queyranne's Algorithm
# ==============================================================================

"""
    queyranne_min_cut(f::AbstractSymmetricSubmodularFunction)

Finds a non-trivial subset A of V that minimizes f(A).
Returns (min_val, min_cut_set).
"""
function queyranne_min_cut(f::AbstractSymmetricSubmodularFunction)
    n = ground_set_size(f)
    V = collect(1:n)
    
    # Current merged nodes. Initially each index i is a set {i}.
    # We track them by their representative index.
    nodes = [[i] for i in 1:n]
    
    best_val = Inf
    best_cut = BitSet()
    
    # We need n-1 phases
    # In each phase, we merge two nodes.
    while length(nodes) > 1
        # 1. Pendant Pair Identification
        # Start with arbitrary node (e.g., the last one in our list)
        # We need to order the current 'nodes' as v_1, ..., v_k
        # v_1 is arbitrary.
        # v_i maximizes f(W_{i-1} U {v_i}) - f({v_i})?
        # Actually, for Queyranne, the score is f(W) + f(v) - f(W U v).
        # We want to maximize this "connectivity".
        
        k = length(nodes)
        ordered_indices = Int[] # Indices into the 'nodes' array
        
        # Start with index 1 (arbitrary)
        push!(ordered_indices, 1)
        
        in_W = falses(k)
        in_W[1] = true
        
        # Build the set W incrementally
        # W is the UNION of the sets represented by ordered_indices
        W_set = BitSet(nodes[1])
        
        for _ in 2:k
            best_idx = -1
            max_score = -Inf
            
            # Try adding each v not in W
            for i in 1:k
                if !in_W[i]
                    # v is nodes[i]
                    v_set = BitSet(nodes[i])
                    
                    # Score = f(W) + f(v) - f(W U v)
                    # Optimization: f(W) is constant for this step.
                    # So we just maximize f(v) - f(W U v).
                    
                    # Note: We need to evaluate f on the actual sets of original indices
                    val_v = evaluate(f, v_set)
                    
                    # W U v
                    W_U_v = union(W_set, v_set)
                    val_W_U_v = evaluate(f, W_U_v)
                    
                    score = val_v - val_W_U_v
                    
                    if score > max_score
                        max_score = score
                        best_idx = i
                    end
                end
            end
            
            # Add best_idx to order
            push!(ordered_indices, best_idx)
            in_W[best_idx] = true
            union!(W_set, nodes[best_idx])
        end
        
        # 2. The last two nodes in the order are the "Pendant Pair" (t, u)
        # t = v_{k-1}, u = v_k
        t_idx = ordered_indices[k-1]
        u_idx = ordered_indices[k]
        
        u_set = BitSet(nodes[u_idx])
        
        # 3. Evaluate the cut separating u (and its merged components) from the rest
        # The cut value is f(u_set)
        cut_val = evaluate(f, u_set)
        
        if cut_val < best_val
            best_val = cut_val
            best_cut = copy(u_set)
        end
        
        # 4. Merge t and u
        # We merge u into t, and remove u from the list
        append!(nodes[t_idx], nodes[u_idx])
        
        # Remove u_idx from nodes. 
        # Be careful with indices changing.
        # ordered_indices contains indices into the *current* nodes array.
        deleteat!(nodes, u_idx)
    end
    
    return (best_val, best_cut)
end

end # module
