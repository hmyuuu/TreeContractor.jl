# Analysis: Computing Rank-Width Exactly (Oum 2009)

**Paper:** "Computing Rank-Width Exactly"
**Author:** Sang-il Oum
**Year:** 2009 (Information Processing Letters, Vol. 109, Issue 13, pp. 745-748)
**Task:** T-072
**Agent:** PhD-Algo

## 1. Overview

This paper presents an **exact exponential-time algorithm** to compute rank-width in time:
$$O(2^n n^3 \log^2 n \log \log n)$$

This improves over the trivial $O(3^n \log n)$ dynamic programming approach.

## 2. General Framework

### 2.1 Decomposition Definition
A **decomposition** of finite set $V$ is a pair $(T, \mu)$:
- $T$: rooted binary tree (root has 2 incoming edges, non-root nodes have 1 outgoing + 0 or 2 incoming)
- $\mu: V \to \text{leaves}(T)$ bijection

### 2.2 Width of Decomposition
For function $f: 2^V \to \mathbb{Z}$:
- **$f$-width of decomposition:** $\max_e f(\mu^{-1}(X_e))$ where $X_e$ = descendant leaves of $e$
- **Width of $f$ on $V$:** $w(f, V) = \min_{(T,\mu)} (\text{f-width})$

### 2.3 Recursive Characterization
**Lemma 1:**
$$w(f, X) = \begin{cases}
\min_{\emptyset \neq Y \subsetneq X} \max(f(Y), f(X \setminus Y), w(f, Y), w(f, X \setminus Y)) & |X| \geq 2 \\
f(X) & |X| \leq 1
\end{cases}$$

## 3. Trivial Algorithm Analysis

Using Lemma 1 directly:
- Need $w(f, X)$ for all $2^n$ subsets
- Each subset of size $k$ requires iterating over $\binom{n}{k}$ splits
- Total: $\sum_{k=2}^{n} \binom{n}{k} 2^k = O(3^n)$
- With $O(\log M)$ comparison overhead: **$O(3^n \log M)$**

## 4. Fast Subset Convolution

### 4.1 Definition
For functions $f, g: 2^V \to R$ (ring):
$$
(f * g)(S) = \sum_{T \subseteq S} f(T) g(S \setminus T)
$$

### 4.2 Key Result
**Theorem 2 (Björklund et al. 2007):**
> Given $f, g: 2^V \to R$, the convolution $f * g$ can be computed in $O(2^n n^2)$ ring operations.

### 4.3 Algorithm Steps
1. **Möbius Transform (A):** Compute $\hat{f}(k, X) = \sum_{S \subseteq X, |S|=k} f(S)$
2. **Pointwise Product (B):** Compute $(\hat{f} \otimes \hat{g})(k, X) = \sum_{j=0}^{k} \hat{f}(j, X) \hat{g}(k-j, X)$
3. **Inverse Möbius (C):** Compute $(f * g)(k, X) = \sum_{S \subseteq X} (-1)^{|X \setminus S|} (\hat{f} \otimes \hat{g})(k, S)$
4. **Extract (D):** $(f * g)(X) = (f * g)(|X|, X)$

## 5. Main Algorithm

### 5.1 Decision Problem
**Lemma 3:** Given table of whether $f(X) \leq k$ for all $X$, can decide $w(f, V) \leq k$ in:
$$O(2^n n^3 \log n \log \log n)$$

### 5.2 Key Insight
Define indicator function:
$$g_i(X) = \begin{cases}
1 & \text{if } 1 \leq |X| \leq i, X \neq V, w(f,X) \leq k, f(X) \leq k \\
1 & \text{if } i = n, X = V, w(f,X) \leq k \\
0 & \text{otherwise}
\end{cases}$$

Then by Lemma 1:
$$w(f, X) \leq k \iff \begin{cases}
(g_{|X|-1} * g_{|X|-1})(X) \neq 0 & |X| \geq 2 \\
f(X) \leq k & |X| \leq 1
\end{cases}$$

### 5.3 Optimization
**Key observation:** $g_{i+1}$ can be computed from $g_i$ in $O(2^n n)$ ring operations (not $O(2^n n^2)$):
- Only need $(g_i * g_i)(X)$ for $|X| = i + 1$
- Reuse $\hat{g}_j(j, X)$ for $j < i$
- Each ring operation involves $\leq n$-bit integers
- $n$-bit multiplication: $O(n \log n \log \log n)$ (Schönhage-Strassen)

### 5.4 Main Theorem

**Theorem 4:**
$$\text{Time} = O(2^n (n^3 \log n \log \log n \log M + \log^2 M + \alpha))$$

where:
- $M = \max_{X \subseteq V} |f(X)|$
- $\alpha$ = oracle time for $f(X)$

**Proof approach:**
1. Precompute $f(X)$ for all $X$: $O(2^n \alpha)$
2. Binary search on $k \in [-M, M]$: $O(\log M)$ iterations
3. Each iteration: $O(2^n n^3 \log n \log \log n)$

## 6. Applications

### 6.1 Rank-Width
$$\rho_G(X) = \text{rank}_{GF(2)}(A[X, V \setminus X])$$

**Corollary 5:** Rank-width computable in $O(2^n n^3 \log^2 n \log \log n)$
- $M \leq \lfloor n/2 \rfloor$
- $\alpha = O(n^3)$ (GF(2) rank computation)

### 6.2 Carving-Width
$$\eta_G(X) = |\{e \in E : e \cap X \neq \emptyset, e \cap (V \setminus X) \neq \emptyset\}|$$

**Corollary 6:** Carving-width in $O(2^n n^3 \log n \log \log n \log m)$

### 6.3 Branch-Width
$$b_G(X) = |\{v \in V : v \text{ incident to edge in both } X \text{ and } E \setminus X\}|$$

Can compute in $O(2^m m^{O(1)})$ where $m = |E|$.

(Note: Fomin et al. achieved $O((2\sqrt{3})^n n^{O(1)})$ via triangulations)

### 6.4 Matching-Width
$$\pi_G(X) = \max_{M \text{ perfect matching}} |\delta_G(X) \cap M|$$

**Corollary 7:** Matching-width in $O(2^n n^3 \log^2 n \log \log n)$
- Uses min-weight perfect matching as oracle

## 7. Symmetric Function Optimization

**Remark:** If $f(X) = f(V \setminus X)$ (symmetric):
- Can choose root to split $V$ into parts of size $\leq \lceil 2n/3 \rceil$
- Only need $g_1, \ldots, g_{\lceil 2n/3 \rceil}$
- Saves ~1/3 of computation

This applies to rank-width since $\rho_G(X) = \rho_G(V \setminus X)$.

## 8. Comparison

| Algorithm | Time | Space |
|-----------|------|-------|
| Trivial DP | $O(3^n \log n)$ | $O(2^n)$ |
| **This paper** | $O(2^n n^3 \log^2 n \log \log n)$ | $O(2^n n)$ |
| FPT approx (Oum) | $O(8^k n^4)$ | poly$(n)$ |

**Improvement factor:** $\approx 1.5^n / n^3 \log^2 n \log \log n$

## 9. Technical Details

### 9.1 Ring Operations
- Numbers stay within $O(n)$ bits (since $g_i \in \{0,1\}$)
- Schönhage-Strassen: $n$-bit multiplication in $O(n \log n \log \log n)$
- (Fürer 2007: improved to $n \log n \cdot 2^{O(\log^* n)}$)

### 9.2 Memory
- Need to store:
  - $f(X)$ for all $X$: $O(2^n \log M)$ bits
  - $g_i(X)$ tables: $O(2^n n)$ bits
  - Intermediate convolution tables: $O(2^n n^2)$ bits

## 10. Implications for Our Implementation

### 10.1 When to Use Exact Algorithm
- Small graphs: $n \leq 25-30$
- Need provably optimal decomposition
- Verification/benchmarking purposes

### 10.2 Implementation Notes
```julia
# Pseudocode structure
function exact_rank_width(G)
    n = nv(G)
    # Precompute all cut-ranks
    cutrk = Dict{Set{Int}, Int}()
    for mask in 0:(2^n - 1)
        X = Set(i for i in 1:n if mask & (1 << (i-1)) != 0)
        cutrk[X] = compute_cut_rank(G, X)
    end

    # Binary search on width k
    lo, hi = 0, n ÷ 2
    while lo < hi
        k = (lo + hi) ÷ 2
        if width_at_most_k(cutrk, n, k)
            hi = k
        else
            lo = k + 1
        end
    end
    return lo
end
```

### 10.3 Practical Considerations
- For $n \leq 20$: exact is feasible
- For $n > 30$: use heuristics/approximations
- Fast subset convolution requires careful bit manipulation

## 11. Open Questions

From the paper:
> "Is it possible to compute rank-width of an n-vertex graph in time $O(c^n)$ for some $c < 2$?"

This remains open. The bottleneck is the subset enumeration inherent in the problem.

## 12. Key Quotes

> "We prove that the rank-width of an n-vertex graph can be computed exactly in time $O(2^n n^3 \log^2 n \log \log n)$."

> "To improve over a trivial $O(3^n \log n)$-time algorithm, we develop a general framework for decompositions."

> "This framework may be used for other width parameters, including the branch-width of matroids and the carving-width of graphs."

## 13. Summary

1. **Framework:** Generic width computation via set function optimization
2. **Key tool:** Fast subset convolution (Björklund et al.)
3. **Improvement:** $3^n \to 2^n$ base in exponential
4. **Generality:** Applies to rank-width, carving-width, branch-width, matching-width
5. **Practical:** Feasible for $n \leq 25-30$

**Status:** Completed
