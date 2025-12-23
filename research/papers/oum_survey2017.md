# Analysis: Rank-Width: Algorithmic and Structural Results (Oum 2017)

**Paper:** "Rank-Width: Algorithmic and Structural Results"
**Author:** Sang-il Oum
**Year:** 2017 (Discrete Applied Mathematics, Vol. 231, pp. 15-24)
**Task:** T-071
**Agent:** PhD-Theory

## 1. Overview

This is THE authoritative survey on rank-width, summarizing algorithmic and structural results. Key topics:
1. Definitions and equivalent parameters
2. Algorithms for computing rank-width
3. Structural aspects and vertex-minors
4. Open problems

## 2. Definitions

### 2.1 Cut-Rank Function
For graph $G$ and $X \subseteq V(G)$:
$$\rho_G(X) = \text{rank}(A_X) \text{ over GF(2)}$$

where $A_X$ is the $|X| \times |V(G) - X|$ biadjacency matrix.

**Key Properties:**
1. **Symmetry:** $\rho_G(X) = \rho_G(V(G) - X)$
2. **Submodularity:** $\rho_G(X) + \rho_G(Y) \geq \rho_G(X \cup Y) + \rho_G(X \cap Y)$

### 2.2 Rank-Width
A **rank-decomposition** $(T, L)$ consists of:
- Subcubic tree $T$ (every node degree 1 or 3)
- Bijection $L: V(G) \to \text{leaves}(T)$

**Width of edge $e$:** $\rho_G(L^{-1}(A_e))$ where $T - e$ partitions leaves into $(A_e, B_e)$.

**Rank-width:** $\text{rw}(G) = \min_{(T,L)} \max_e \text{width}(e)$

### 2.3 Linear Rank-Width
**Definition:** Use caterpillar tree instead of general subcubic tree.

Equivalently: minimum over all linear layouts $v_1, \ldots, v_n$ of:
$$\max_{i=1}^{n-1} \rho_G(\{v_1, \ldots, v_i\})$$

**Always:** $\text{rw}(G) \leq \text{lrw}(G)$

## 3. Equivalent Width Parameters

### 3.1 Clique-Width
**Theorem 2.1 (Oum & Seymour):**
$$\text{rw}(G) \leq \text{cw}(G) \leq 2^{\text{rw}(G)+1} - 1$$

**Essentially tight:**
- $n \times n$ grid: rw = $n-1$, cw = $n+1$
- $\exists$ graphs with rw $\leq k+1$ but cw $\geq 2^{\lfloor k/2 \rfloor - 1}$

### 3.2 NLC-Width
$$\text{rw}(G) \leq \text{nlc}(G) \leq 2 \cdot \text{rw}(G)$$

### 3.3 Boolean-Width
$$\log_2 \text{rw}(G) \leq \text{boolw}(G) \leq \frac{\text{rw}(G)^2}{4} + O(\text{rw}(G))$$

### 3.4 F-Rank-Width
Over field $F$ (instead of GF(2)):
- For $F$ of characteristic 0 or 2: $\text{rw}(G) \leq \text{rw}_F(G)$
- Still equivalent to clique-width

## 4. Algorithmic Results

### 4.1 Meta-Theorem
**Theorem 3.1 (Courcelle-Makowsky-Rotics):**
> Every MSO₁ formula can be decided in $O(n^3)$ time for graphs of rank-width at most $k$.

### 4.2 Hardness
Computing rank-width is **NP-hard**:
1. Branch-width of binary matroid = rank-width of fundamental graph + 1
2. Branch-width of cycle matroid = branch-width of graph (non-forest)
3. Computing graph branch-width is NP-hard (Seymour-Thomas)

Computing linear rank-width is also **NP-hard** (via path-width of binary matroids).

### 4.3 Exact Algorithms

| Algorithm | Time | Reference |
|-----------|------|-----------|
| XP (Oum-Seymour) | $O(n^{8k+12} \log n)$ | [72] |
| FPT decision | $O(g(k) n^3)$ | Courcelle-Oum [26] |
| FPT construction | $O(g(k) n^3)$ | Hliněný-Oum [41] |
| Exact exponential | $O(2^n \text{poly}(n))$ | Oum [67] |

### 4.4 Fixed-Parameter Approximations

| Approximation | Time | Reference |
|---------------|------|-----------|
| $3k + 1$ | $O(8^k n^9 \log n)$ | Oum-Seymour [71] |
| $3k + 1$ | $O(8^k n^4)$ | Oum [64] |
| $3k - 1$ | $O(g(k) n^3)$ | Oum [64] |

### 4.5 Special Cases
- **Bipartite circle graphs:** Polynomial time (via planar branch-width)
- **Rank-width 1:** Polynomial (distance-hereditary graphs)

## 5. Open Questions (from Survey)

### Question 1
> Can we compute rank-width of **circle graphs** in polynomial time?

### Question 2
> Does there exist an algorithm with $f(k)$ and constant $c$ finding rank-decomposition of width $\leq f(k)$ in time $O(c^k n^3)$?

### Question 3
> Can we improve $n^3$ to $n^c$ for some $c < 3$?

### Question 4
> Is it possible to compute rank-width exactly in time $O(c^n)$ for some $c < 2$?

### Question 5
> For each bipartite circle graph $H$, does every graph with sufficiently large rank-width contain a pivot-minor isomorphic to $H$?

### Question 6
> Are graphs **well-quasi-ordered under pivot-minors** (unbounded rank-width)?

### Question 7
> Can we decide pivot-minor/vertex-minor containment in **polynomial time**?

## 6. Structural Aspects

### 6.1 Vertex-Minors and Pivot-Minors
- **Local complementation at $v$:** Toggle edges in $N(v)$
- **Pivoting $G \wedge uv$:** $G * u * v * u = G * v * u * v$
- **Key:** Local complementation preserves cut-rank function!

### 6.2 Relation to Tree-Width

| Result | Reference |
|--------|-----------|
| $\text{rw}(G) \leq \text{tw}(G) + 1$ | Oum [66] |
| Incidence graph $I(G)$: rw = bw or bw - 1 | Oum [66] |
| $\text{rw}(L(G)) \in \{bw, bw-1, bw-2\}$ | Oum [68] |
| Trees: $\text{lrw} = \text{pw}$ | Adler-Kanté [2] |

**Theorem 4.4 (Kwon-Oum):**
1. Every graph of rw $k$ is a pivot-minor of a graph of tw $\leq 2k$
2. Every graph of lrw $k$ is a pivot-minor of a graph of pw $\leq k + 1$

### 6.3 Linear Rank-Width Bound
**Theorem 3.2 (Kwon):**
$$\text{lrw}(G) \leq \text{rw}(G) \cdot \lfloor \log_2 n \rfloor$$

### 6.4 Duality: Tangles
**$\rho_G$-tangle of order $k$:** Set $\mathcal{T}$ satisfying:
- (T1) For $\rho_G(A) < k$: either $A \in \mathcal{T}$ or $V(G) - A \in \mathcal{T}$
- (T2) If $A, B, C \in \mathcal{T}$, then $A \cup B \cup C \neq V(G)$
- (T3) $V(G) - \{v\} \notin \mathcal{T}$ for all $v$

**Theorem 4.6 (Robertson-Seymour):**
$G$ has $\rho_G$-tangle of order $k$ $\iff$ $\text{rw}(G) \geq k$

### 6.5 Well-Quasi-Ordering
**Theorem 4.8 (Oum):**
> For all positive integers $k$, every infinite sequence $G_1, G_2, \ldots$ of graphs of rank-width at most $k$ admits $i < j$ with $G_i$ a pivot-minor of $G_j$.

**Extensions:**
- Skew-symmetric/symmetric matrices over finite fields (Oum [69])
- $\sigma$-symmetric matrices (Kanté [51])

### 6.6 Forbidden Vertex-Minors
**Finite obstruction sets exist** for each $k$:
- $k = 0$: $K_2$
- $k = 1$: $C_5$ (5-cycle) — graphs are **distance-hereditary**
- $k \geq 2$: Finite but size bounded by $(6^{k+1} - 1)/5$ vertices

## 7. χ-Boundedness

**Theorem 4.5 (Dvořák-Král'):**
> Graphs of rank-width $\leq k$ are $\chi$-bounded: $\chi(G) \leq f(\omega(G), k)$

**Geelen's Conjecture:** For each fixed $H$, graphs with no $H$ vertex-minor are $\chi$-bounded.

## 8. Random Graphs

**Theorem (Lee-Lee-Oum):**
For $G(n, p)$ with constant $p \in (0, 1)$:
$$\text{rw}(G(n, p)) = \lceil n/3 \rceil - O(1) \text{ a.a.s.}$$

## 9. Software Implementations

1. **Krause:** Simple DP algorithm (in SAGE)
2. **Friedmanský:** Exact exponential algorithm [67]
3. **Bui-Xuan et al.:** 3k+1 approximation in SAGE

## 10. Implications for Our Implementation

### RankWidthSolver Connections

| Survey Topic | Our Module | Status |
|--------------|------------|--------|
| Cut-rank function | `CutRank.jl` | Implemented |
| Rank-decomposition | `RankDecomposition.jl` | Implemented |
| 3k+1 approximation | `Queyranne.jl` | Implemented |
| Local search | `LocalSearch.jl` | Implemented |
| Linear rank-width | `LinearRankWidth.jl` | Implemented |
| Parse trees | `ParseTrees.jl` | Implemented |
| DP solver | `DPSolver.jl` | Implemented |

### Future Work (from Survey)
1. **Question 3:** Faster than $O(n^3)$ — requires matrix rank speedups
2. **Question 5:** Grid theorem for rank-width — structural insight
3. **Question 7:** Polynomial vertex-minor detection — key for forbidden minor approach

## 11. Key Relationships Summary

```
Tree-Width ─────────────────────────────────┐
    │                                       │
    │ rw(G) ≤ tw(G) + 1                     │
    ▼                                       │
Rank-Width ◄────────────────────────────────┤
    │                                       │
    │ cw(G) ≤ 2^(rw(G)+1) - 1               │
    ▼                                       │
Clique-Width                                │
    │                                       │
    │ nlc(G) ≤ 2·rw(G)                      │
    ▼                                       │
NLC-Width                                   │
    │                                       │
    │ log₂(rw(G)) ≤ boolw(G)                │
    ▼                                       │
Boolean-Width ◄─────────────────────────────┘
```

## 12. Key Quotes

> "Rank-width is a width parameter of graphs describing whether it is possible to decompose a graph into a tree-like structure by 'simple' cuts."

> "A class of graphs has bounded clique-width if and only if it has bounded rank-width."

> "Local complementation is a useful tool to study rank-width of graphs, because local complementation preserves the cut-rank function."

> "For all positive integers k, every infinite sequence of graphs of rank-width at most k admits a pair with one a pivot-minor of the other."

## 13. Summary

This survey consolidates:
1. **Equivalences:** rw ≈ cw ≈ nlc ≈ boolw (up to exponential factors)
2. **Algorithms:** FPT for fixed k, 3k+1 approximation in $O(8^k n^4)$
3. **Structure:** WQO by pivot-minors, finite obstructions, tangles
4. **Applications:** MSO₁ decidable in $O(n^3)$

**Status:** Completed
