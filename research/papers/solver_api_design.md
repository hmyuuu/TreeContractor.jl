# Solver API Design: Queyranne & Rank-Width

## 1. Overview
This document defines the architecture for the `RankWidthAlgorithms` package, specifically focusing on the implementation of Queyranne's algorithm and its integration with Weighted Rank-Width.

## 2. Core Types

### Abstract Interface
We define an abstract type for the function oracle to ensure flexibility.

```julia
abstract type AbstractSymmetricSubmodularFunction end

"""
    evaluate(f::AbstractSymmetricSubmodularFunction, S::BitSet)

Returns the value of the function f for the subset S.
"""
function evaluate(f::AbstractSymmetricSubmodularFunction, S::BitSet)::Float64
    error("Not implemented")
end
```

### Concrete Implementations

#### 1. MatrixRankFunction
Standard GF(2) cut-rank.
```julia
struct MatrixRankFunction <: AbstractSymmetricSubmodularFunction
    M::Matrix{Int} # The adjacency matrix
end

function evaluate(f::MatrixRankFunction, S::BitSet)
    # Compute rank of M[S, V\S]
    return rank_gf2(f.M, S)
end
```

#### 2. WeightedRankFunction (New for T-022)
Hybrid objective for mixed states.
```julia
struct WeightedRankFunction <: AbstractSymmetricSubmodularFunction
    base_rank::MatrixRankFunction
    weights::Matrix{Float64} # Edge weights
    lambda::Float64
end

function evaluate(f::WeightedRankFunction, S::BitSet)
    r = evaluate(f.base_rank, S)
    w = cut_weight(f.weights, S)
    return r + f.lambda * w
end
```

## 3. Algorithm: Queyranne's Method

### Function Signature
```julia
"""
    queyranne_min_cut(V::Int, f::AbstractSymmetricSubmodularFunction)

Returns a tuple (best_cut::BitSet, min_value::Float64).
"""
function queyranne_min_cut(n::Int, f::AbstractSymmetricSubmodularFunction)
    # ...
end
```

### The Pendant Pair Ordering
For each phase, we construct an ordering $v_1, \dots, v_n$.
- **Selection Rule:** At step $i$, choose $v_i \notin W_{i-1}$ that **maximizes**:
  $$ \text{score}(v) = f(W_{i-1}) + f(\{v\}) - f(W_{i-1} \cup \{v\}) $$
  (This term represents the "connectivity" between $v$ and $W_{i-1}$).

- **Note:** This is equivalent to **minimizing** $f(W_{i-1} \cup \{v\}) - f(\{v\})$.

## 4. Recursive Decomposition
To build the full tree:
```julia
function recursive_rank_decomposition(V::Vector{Int}, f::AbstractSymmetricSubmodularFunction)
    if length(V) <= 1
        return Leaf(V[1])
    end
    
    # 1. Find best split using Queyranne
    # Note: Queyranne finds a subset S subset V.
    # We need to map the global indices correctly if working on a subgraph?
    # Actually, Queyranne works on the abstract set.
    # We can restrict f to the current subset V_active.
    
    (S, val) = queyranne_min_cut(length(V), RestrictedFunction(f, V))
    
    # 2. Recurse
    left = recursive_rank_decomposition(S, f)
    right = recursive_rank_decomposition(setdiff(V, S), f)
    
    return Node(left, right)
end
```

## 5. Verification Plan
1.  **Unit Test 1:** Modular function (should return min weight element).
2.  **Unit Test 2:** Cut function of a cycle graph $C_4$. Min cut should be 2.
3.  **Unit Test 3:** Weighted graph.
