# Randomized QB Approximation - References and Summary

## Overview

Randomized QB approximation refers to randomized algorithms for computing low-rank matrix approximations using QR decomposition. The "QB" notation comes from the factorization A ≈ QB, where Q is an orthonormal matrix (from QR decomposition) and B is a small matrix. This is an alternative to randomized SVD for low-rank approximations.

## Key References

### 1. Halko, Martinsson, and Tropp (2011)
**Title**: "Finding structure with randomness: Probabilistic algorithms for constructing approximate matrix decompositions"

**Key Points**:
- Introduces randomized algorithms for low-rank matrix approximations
- Two-stage approach: (1) Random sampling to find approximate range, (2) Projection to get low-rank factorization
- Algorithm: A ≈ Q(Q* A) where Q comes from QR of random matrix
- Complexity: O(mn log(k)) for m×n matrix with rank k approximation
- Provides theoretical guarantees on approximation quality

**Algorithm Sketch**:
```
1. Generate random matrix Ω (n × (k+p)) where p is oversampling
2. Form Y = AΩ
3. Compute QR: Y = QR
4. Form B = Q* A
5. Result: A ≈ QB
```

**Reference**: 
- SIAM Review, 53(2), 217-288, 2011
- arXiv:0909.4061

### 2. Randomized QR with Column Pivoting
**Title**: Various papers on randomized QRCP (QR with Column Pivoting)

**Key Points**:
- Combines randomization with column pivoting for better numerical stability
- Useful for rank-revealing decompositions
- Can be faster than deterministic QRCP for large matrices

**Reference**:
- Martinsson, Rokhlin, Tygert (2006): "A randomized algorithm for the decomposition of matrices"
- Gu, Eisenstat (1996): "Efficient algorithms for computing a strong rank-revealing QR factorization"

### 3. Block Randomized Algorithms
**Title**: Block-based randomized algorithms for large-scale matrix computations

**Key Points**:
- Process matrices in blocks for better cache performance
- Suitable for out-of-core computations
- Can leverage parallel processing

**Reference**:
- Duersch, Gu (2020): "Randomized QR with Column Pivoting"
- SIAM J. Sci. Comput., 42(1), A405-A429

### 4. Applications to Tensor Networks
**Title**: Randomized methods for tensor decompositions

**Key Points**:
- Randomized QB can be used in tensor network compression
- Alternative to SVD for truncation operations
- Potentially faster for large bond dimensions
- May be useful in MPS/MPO compression algorithms

**Reference**:
- Oseledets, Tyrtyshnikov (2010): "TT-cross approximation for multidimensional arrays"
- Related work on randomized tensor decompositions

## Comparison: Randomized QB vs Randomized SVD

| Aspect | Randomized QB | Randomized SVD |
|--------|---------------|----------------|
| Factorization | A ≈ QB | A ≈ UΣV* |
| Orthonormal basis | Q (explicit) | U (explicit) |
| Computational cost | Lower (no SVD on large matrix) | Higher (SVD on projected matrix) |
| Accuracy | Good for well-conditioned matrices | Optimal (minimal error) |
| Use case | Fast approximation, iterative refinement | High accuracy needed |

## Algorithm Details

### Basic Randomized QB Algorithm

```julia
function randomized_qb(A, k, p=5)
    # A: m×n matrix
    # k: target rank
    # p: oversampling parameter
    
    m, n = size(A)
    Ω = randn(n, k+p)  # Random test matrix
    
    # Stage 1: Find approximate range
    Y = A * Ω  # m × (k+p)
    Q, R = qr(Y)  # QR decomposition
    
    # Stage 2: Project to get B
    B = Q' * A  # (k+p) × n
    
    # Optional: Truncate to rank k
    Q_k = Q[:, 1:k]
    B_k = B[1:k, :]
    
    return Q_k, B_k
end
```

### Power Iteration Variant

For better accuracy, especially for matrices with slow singular value decay:

```julia
function randomized_qb_power(A, k, p=5, q=2)
    # q: number of power iterations
    
    m, n = size(A)
    Ω = randn(n, k+p)
    Y = A * Ω
    
    # Power iteration: Y = (AA*)^q AΩ
    for i in 1:q
        Y = A * (A' * Y)
    end
    
    Q, R = qr(Y)
    B = Q' * A
    return Q[:, 1:k], B[1:k, :]
end
```

## Advantages for Tensor Networks

1. **Speed**: QR decomposition is typically faster than SVD
2. **Memory**: Can be more memory-efficient for large matrices
3. **Iterative refinement**: Easy to refine approximation iteratively
4. **Block operations**: Naturally supports block-wise processing

## Potential Applications in TreeContractor.jl

### Current Implementation
- Uses SVD for tensor-to-MPS conversion (`tensor2mps`)
- Uses SVD for compression (`truncated_svd`)
- Uses QR for canonicalization (`canonical_move_right!`, `canonical_move_left!`)

### Potential Improvements
1. **Randomized QB for large bond dimensions**: When bond dimension χ is very large, randomized QB could be faster than full SVD
2. **Approximate compression**: Use randomized QB for intermediate compression steps, full SVD for final results
3. **Block-wise processing**: Process large tensors in blocks using randomized methods

## Theoretical Guarantees

For a matrix A with exact rank k:
- **Expected error**: E[||A - QB||] ≤ (1 + k/(p-1))^(1/2) σ_{k+1}
- **High probability**: With probability ≥ 1 - 3p^{-p}, ||A - QB|| ≤ (1 + √(k/p)) σ_{k+1}
- Where σ_{k+1} is the (k+1)-th singular value

## Implementation Considerations

1. **Oversampling**: Typically use p = 5 to 10 for better accuracy
2. **Power iterations**: q = 1-2 usually sufficient for most applications
3. **Adaptive rank**: Can adaptively determine rank based on singular values of B
4. **Numerical stability**: QR decomposition is generally stable

## References Summary

1. **Halko, Martinsson, Tropp (2011)**: Foundational paper on randomized matrix decompositions
   - SIAM Review 53(2), 217-288
   - arXiv:0909.4061

2. **Martinsson, Rokhlin, Tygert (2006)**: Randomized algorithms for matrix decomposition
   - Applied and Computational Harmonic Analysis

3. **Duersch, Gu (2020)**: Randomized QR with Column Pivoting
   - SIAM J. Sci. Comput. 42(1), A405-A429

4. **Oseledets, Tyrtyshnikov (2010)**: TT-cross approximation (related tensor methods)
   - Linear Algebra and its Applications

5. **Gu, Eisenstat (1996)**: Efficient rank-revealing QR factorization
   - SIAM J. Sci. Comput. 17(4), 848-869

## Conclusion

Randomized QB approximation provides a fast alternative to SVD for low-rank matrix approximations. It's particularly useful when:
- Speed is more important than optimal accuracy
- Matrices are large and well-conditioned
- Iterative refinement is acceptable
- Memory efficiency is a concern

For tensor network applications like TreeContractor.jl, randomized QB could potentially:
- Speed up compression for very large bond dimensions
- Provide approximate compression for intermediate steps
- Enable block-wise processing of large tensors

However, careful consideration is needed for:
- Numerical stability in iterative algorithms
- Accuracy requirements for final results
- Integration with existing SVD-based compression algorithms
