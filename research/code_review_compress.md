# Code Review: SVD Truncation Logic (`src/compress.jl`)

## Overview
This document analyzes the truncation logic in `src/compress.jl` (Lines 181-201) and `src/mps.jl`.
The goal is to determine if the current implementation correctly minimizes the Frobenius norm error and address the `FIXME: why do such truncation?` comments.

## Current Implementation

### `truncated_svd`
```julia
function truncated_svd(M::AbstractMatrix, atol::Real, maxdim::Int)
    # ... checks ...
    res = LinearAlgebra.svd(M)
    r = min(searchsortedfirst(res.S, atol; rev=true) - 1, maxdim, length(res.S))
    
    return res.U[:, 1:r], res.S[1:r], res.Vt[1:r, :], sum(res.S[(r + 1):end] .^ 2) # FIXME
end
```

### `truncated_eigen`
```julia
function truncated_eigen(M::AbstractMatrix, atol::Real, maxdim::Int)
    # ... checks ...
    res = LinearAlgebra.eigen(M; sortby=x -> -x)
    r = min(searchsortedfirst(res.values, atol; rev=true) - 1, maxdim, length(res.values))
    
    return res.values[1:r], res.vectors[:, 1:r], sum(res.values[(r + 1):end] .^ 2) # FIXME
end
```

## Mathematical Analysis

### Eckart-Young-Mirsky Theorem
The optimal rank-$r$ approximation $\tilde{M}$ of a matrix $M$ with singular values $\sigma_1 \ge \sigma_2 \ge \dots$ in the Frobenius norm is obtained by keeping the largest $r$ singular values.
The error is:
$$ || M - \tilde{M} ||_F^2 = \sum_{i=r+1}^{N} \sigma_i^2 $$

### Analysis of the Code
1.  **Truncation Selection:**
    - `searchsortedfirst(res.S, atol; rev=true) - 1` finds the index where singular values drop below `atol`.
    - This effectively keeps all $\sigma_i \ge \text{atol}$.
    - **Issue:** The standard definition of `atol` in many libraries (e.g., NumPy) usually refers to the *absolute* value threshold, which this code implements. However, in Tensor Networks, `atol` often refers to the **truncation error budget** ($\epsilon^2 \approx \sum \sigma_{discard}^2$).
    - **Current Behavior:** It discards singular values smaller than `atol`. This is a valid strategy but different from "discard until the sum of squares is `< atol`".

2.  **Error Calculation:**
    - `sum(res.S[(r + 1):end] .^ 2)` correctly computes the **squared Frobenius norm** of the discarded part.
    - **FIXME Resolution:** The comment asks "why do such truncation?". The answer is: "This returns the squared Frobenius norm of the error, which is the standard metric for controlling tensor network accuracy."

3.  **Eigen vs SVD:**
    - In `truncated_eigen`, `M` is assumed to be a density matrix $\rho \approx M M^\dagger$.
    - The eigenvalues of $\rho$ are $\lambda_i = \sigma_i^2$.
    - **Bug in Error Calc:** The code returns `sum(res.values[(r + 1):end] .^ 2)`. Since `values` are already $\sigma^2$, this computes $\sum (\sigma^2)^2 = \sum \sigma^4$.
    - **Correction:** It should be `sum(res.values[(r + 1):end])` to represent the truncation error (trace distance / probability mass lost).

## Findings & Recommendations

### 1. Bug in `truncated_eigen`
The error calculation squares the eigenvalues, which is incorrect if they represent probabilities (singular values squared).
- **Current:** $\sum \lambda_i^2$
- **Correct:** $\sum \lambda_i$ (Trace of the discarded part)

### 2. Ambiguity in `atol`
The code uses `atol` as a *threshold for individual singular values*.
- **Recommendation:** Clarify in docstrings. Usually, users expect `cutoff` to be the sum of squares. If `atol` is meant to be $\epsilon$, then the condition should be $\sigma_i > \text{atol}$.

### 3. Proposed Fix
I will patch `src/compress.jl` to fix the `truncated_eigen` error calculation and add comments explaining the Frobenius norm logic.
