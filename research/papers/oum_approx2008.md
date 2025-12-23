# Analysis: Approximating Rank-Width and Clique-Width Quickly (Oum 2008)

**Paper:** "Approximating Rank-Width and Clique-Width Quickly"
**Author:** Sang-il Oum
**Year:** 2008 (ACM Transactions on Algorithms, Vol. 5, No. 1)
**Task:** T-074
**Agent:** PhD-Algo

## 1. Overview

This paper presents **three approximation algorithms** for rank-width:

| Algorithm | Time | Approx | Method |
|-----------|------|--------|--------|
| **First** | $O(n^4)$ | $3k+1$ | Blocking sequences |
| **Second** | $O(n^3)$ | $24k$ | Binary matroids |
| **Third** | $O(n^3)$ | $3k-1$ | MSO logic |

**Historical Context:** Improves Oum-Seymour 2006: $O(n^9 \log n)$ with $3k+1$.

## 2. Background

### 2.1 Cut-Rank Function
For graph $G$ and disjoint $X, Y \subseteq V(G)$:
$$\rho_G^*(X, Y) = \text{rank}(A(G)[X, Y]) \text{ over GF(2)}$$
$$\rho_G(X) = \rho_G^*(X, V(G) \setminus X)$$

### 2.2 Submodularity
**Proposition 2.1:**
$$\rho_G^*(X_1, Y_1) + \rho_G^*(X_2, Y_2) \geq \rho_G^*(X_1 \cap X_2, Y_1 \cup Y_2) + \rho_G^*(X_1 \cup X_2, Y_1 \cap Y_2)$$

### 2.3 Rank-Width ↔ Clique-Width
**Proposition 2.2:**
$$\text{rw}(G) \leq \text{cw}(G) \leq 2^{\text{rw}(G)+1} - 1$$

Conversion: rank-decomposition of width $k$ → $(2^{k+1}-1)$-expression in $O(n^2)$.

## 3. First Algorithm: Blocking Sequences

### 3.1 Blocking Sequence Definition
A sequence $v_1, v_2, \ldots, v_m$ in $V \setminus (A \cup B)$ is a **blocking sequence** for $(A, B)$ if:

1. $\rho_G^*(A, B \cup \{v_1\}) > \rho_G^*(A, B)$
2. $\rho_G^*(A \cup \{v_i\}, B \cup \{v_{i+1}\}) > \rho_G^*(A, B)$ for $i \in \{1, \ldots, m-1\}$
3. $\rho_G^*(A \cup \{v_m\}, B) > \rho_G^*(A, B)$
4. No proper subsequence satisfies (1)-(3)

### 3.2 Key Proposition
**Proposition 3.1:** The following are equivalent:
1. No blocking sequence exists for $(A, B)$
2. $\exists Z$ with $A \subseteq Z \subseteq V \setminus B$ and $\rho_G(Z) = \rho_G^*(A, B)$

### 3.3 Algorithm 3.2: Find Blocking Sequence
1. Construct auxiliary digraph $D$:
   - $(A^\circ, x) \in E$ if $\rho_G^*(A, B \cup \{x\}) > k$
   - $(x, B^\circ) \in E$ if $\rho_G^*(A \cup \{x\}, B) > k$
   - $(x, y) \in E$ if $\rho_G^*(A \cup \{x\}, B \cup \{y\}) > k$
2. Find shortest path from $A^\circ$ to $B^\circ$

### 3.4 Pivoting Reduction
**Proposition 3.3:** If $v_1, \ldots, v_m$ is blocking sequence:
- Find $w \in B$ adjacent to $v_m$
- $v_1, \ldots, v_{m-1}$ is blocking sequence in $G \wedge wv_m$
- Eventually: $\rho_{G'}^*(A, B) = \rho_G^*(A, B) + 1$

### 3.5 Algorithm 3.4: Minimize Cut-Rank
Iterate: find blocking sequence → pivot → repeat until done.

**Time:** $O(n^5)$ general, $O(n^3)$ if $|A|, |B| \leq l$ (fixed constant)

### 3.6 Main Result
**Theorem 3.7:** For fixed $k$, $O(n^4)$-time algorithm:
- Output rank-decomposition of width $\leq 3k+1$, or
- Confirm $\text{rw}(G) > k$

## 4. Second Algorithm: Binary Matroids

### 4.1 Graph to Bipartite Graph
**Definition:** $B(G)$ is bipartite on $V \times \{1,2,3,4\}$:
- $(v, i)$ adjacent to $(v, i+1)$ for $i \in \{1,2,3\}$
- $(v, 1)$ adjacent to $(w, 4)$ if $vw \in E$

### 4.2 Width Relationship
**Proposition 4.1:** $\text{rw}(B(G)) \leq \max(2 \cdot \text{rw}(G), 1)$

**Proposition 4.2:** $\text{rw}(G) \leq 4 \cdot \text{rw}(B(G))$

### 4.3 Binary Matroids
For bipartite $G = A \cup B$:
$$\text{Bin}(G, A, B) = \text{binary matroid on } V$$
represented by $(I_A | A(G)[A, B])$

**Proposition 4.3:** $\lambda_M(X) = \rho_G(X) + 1$

**Corollary 4.4:** $\text{bw}(M) = \text{rw}(G) + 1$

### 4.4 Using Hliněný's Algorithm
**Theorem 4.5 (Hliněný 2005):** For fixed $k$, $O(n^3)$ algorithm for:
- Branch-decomposition of width $\leq 3k+1$, or
- Confirm $\text{bw}(M) > k+1$

**Corollary 4.6:** $O(n^3)$ algorithm for rank-width with approximation $24k$:
1. Construct $B(G)$
2. Run Hliněný on $\text{Bin}(B(G), \ldots)$ with $2k$
3. If width $\leq 6k$, transform back to rank-decomposition of $G$

## 5. Third Algorithm: MSO Logic

### 5.1 Tangles
A **$\rho_G$-tangle of order $k+1$** is set $\mathcal{T}$ satisfying:
- (T1) If $\rho_G(X) \leq k$: either $X \in \mathcal{T}$ or $V \setminus X \in \mathcal{T}$
- (T2) $X_1 \cup X_2 \cup X_3 \neq V$ for $X_1, X_2, X_3 \in \mathcal{T}$
- (T3) $V \setminus \{v\} \notin \mathcal{T}$ for all $v$

**Theorem 5.1 (Robertson-Seymour):**
$$\text{No } \rho_G\text{-tangle of order } k+1 \iff \text{rw}(G) \leq k$$

### 5.2 Key Lemma
**Lemma 5.3:** If $\rho_G(B) \leq 3k-1$ and $|B| \geq 2$ and $\text{rw}(G) \leq k$:

$\exists$ partition $(X, Y)$ of $B$ with $X, Y \neq \emptyset$ and $\rho_G(X), \rho_G(Y) \leq 3k-1$

This enables **greedy decomposition**!

### 5.3 MSO Formula for Cut-Rank
**Lemma 5.4:** For each $k$, $\exists$ MSO formula $\mu_k(X)$:
$$\mu_k(X) \text{ is true} \iff \rho_G(X) \leq k$$

**Construction:** Check if every $k+1$ vertices of $X$ have dependent rows:
$$\exists Z \subseteq \{x_1, \ldots, x_{k+1}\}: \forall y \notin X: |N(y) \cap Z| \equiv 0 \pmod 2$$

### 5.4 Algorithm 5.5: Iterative Refinement
**Input:** Graph $G$, $l$-expression $t$, subset $B$ with $\rho_G(B) \leq 3k-1$

1. If $|B| = 1$: return trivial decomposition
2. Find partition $(X, Y)$ of $B$ with $\rho_G(X), \rho_G(Y) \leq 3k-1$ using MSO
3. Recursively decompose $X$ and $Y$
4. Combine decompositions

**Key:** MSO formula with $l$-expression → linear time search (Courcelle et al. 2000)

### 5.5 Algorithm 5.7: Main Algorithm
For $i = 2, \ldots, n$:
1. Start with decomposition of $G_{i-1}$
2. Add $v_i$ to get decomposition of width $\leq 3k$
3. Convert to $(2^{3k+1}-1)$-expression
4. Apply Algorithm 5.5 to reduce width to $3k-1$

**Theorem 5.8:** For fixed $k$, $O(n^3)$ algorithm for rank-width with approximation $3k-1$.

## 6. Summary Table

| Paper | Time | $f(k)$ | Remark |
|-------|------|--------|--------|
| Oum-Seymour 2006 | $O(n^9 \log n)$ | $3k+1$ | Generic submodular |
| **Section 3** | $O(n^4)$ | $3k+1$ | Blocking sequences |
| **Section 4** | $O(n^3)$ | $24k$ | Binary matroids |
| **Section 5** | $O(n^3)$ | $3k-1$ | MSO logic |

## 7. Corollaries

**Corollary 1.1:** $O(n^3)$ algorithm for $(8k-1)$-expression or confirm $\text{cw}(G) > k$

**Theorem 1.2:** $O(n^3)$ algorithm to test $\text{rw}(G) \leq k$ (via Courcelle-Oum 2007)

## 8. Local Complementation

**Definition 2.3:** $G * v$ toggles edges in $N(v)$

**Proposition 2.4:** $\rho_G(X) = \rho_{G*v}(X)$ (preserves cut-rank!)

**Lemma 2.5:** For $G \wedge vw$:
$$\rho_{G \setminus v}(X_1) + \rho_{G \wedge vw \setminus v}(Y_1) \geq \rho_G(X_1 \cap Y_1) + \rho_G(X_2 \cap Y_2) - 1$$

## 9. Implications for Our Implementation

### 9.1 Queyranne.jl
- Based on blocking sequence approach (Section 3)
- Our implementation uses similar submodular minimization

### 9.2 LocalSearch.jl
- Pivoting operations from this paper
- Local complementation preserves cut-rank

### 9.3 Implementation Choices
- **For $n \leq 1000$:** Use $O(n^4)$ algorithm (simpler)
- **For large $n$:** Use $O(n^3)$ matroid-based approach
- **For best approximation:** Use $3k-1$ MSO-based algorithm

### 9.4 Future: MSO Approach
Could implement Algorithm 5.5 using:
- Parse tree from ParseTrees.jl as "expression"
- MSO formula evaluation via dynamic programming

## 10. Technical Details

### 10.1 Blocking Sequence Complexity
- Build auxiliary digraph: $O(n^4)$ (rank computations)
- Shortest path: $O(n^2)$
- Pivoting iterations: at most $n$
- Total: $O(n^5)$ general, $O(n^3)$ for bounded $|A|, |B|$

### 10.2 Matroid Conversion
- $G \to B(G)$: $O(n^2)$
- $B(G) \to \text{Bin}$: $O(n^2)$
- Hliněný's algorithm: $O(n^3)$
- Back-conversion: $O(n)$

### 10.3 MSO Overhead
- Expression size: $O(n)$
- Formula evaluation: $O(n)$ per query
- Recursive calls: $O(n)$
- Total per vertex: $O(n^2)$

## 11. Key Quotes

> "We develop three separate algorithms of this kind with faster running time."

> "For fixed k, there is an O(|V|³)-time algorithm to test whether the rank-width of a graph G is at most k."

> "Rank-width solves this dilemma in some way; there is a polynomial-time algorithm to decide whether the rank-width of an input graph is at most k."

## 12. Open Questions (at time of publication)

1. Can we achieve $O(n^3)$ with $3k+1$ directly?
2. Is $3k-1$ optimal for polynomial-time approximation?
3. Can we get $O(n^{3-\epsilon})$ for some $\epsilon > 0$?

## 13. Summary

1. **Three independent algorithms** with different trade-offs
2. **Blocking sequences:** Direct combinatorial approach
3. **Binary matroids:** Leverage matroid algorithms
4. **MSO logic:** Use decidability for approximation
5. **Best result:** $O(n^3)$ with approximation $3k-1$

**Status:** Completed
