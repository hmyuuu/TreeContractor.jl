# Analysis: Almost-Linear Time Parameterized Algorithm for Rankwidth via Dynamic Rankwidth (Korhonen-Sokołowski 2024)

**Paper:** "Almost-linear time parameterized algorithm for rankwidth via dynamic rankwidth"
**Authors:** Tuukka Korhonen, Marek Sokołowski
**Year:** 2024 (arXiv:2402.12364)
**Task:** T-081
**Agent:** PhD-Algo

## 1. Overview

This paper achieves **almost-linear time** for computing rank-width, a dramatic improvement over all previous algorithms:

| Algorithm | Time Complexity | Approximation |
|-----------|-----------------|---------------|
| Oum-Seymour 2006 | $O(8^k n^9 \log n)$ | $3k+1$ |
| Oum 2008 | $O(f(k) \cdot n^3)$ | $3k-1$ |
| Fomin-Korhonen 2021 | $O_k(n^2)$ | $2k$ |
| **This paper** | $O_k(n^{1+o(1)}) + O(m)$ | $k$ exact / $4k$ dynamic |

The key innovation: **Dynamic rank decomposition maintenance** with subpolynomial amortized update time.

## 2. Main Results

### 2.1 Theorem 1 (Static Algorithm)
> Given graph $G$ with $n$ vertices and $m$ edges and integer $k$, in time $O_k(n^{1+o(1)}) + O(m)$ either:
> - Output a rank decomposition of width $\leq k$, or
> - Determine that $\text{rw}(G) > k$

**Corollary:** $(2^{k+1}-1)$-expression for clique-width in same time.

### 2.2 Theorem 2 (Dynamic Algorithm)
> Fully dynamic data structure for $n$-vertex graph $G$ under edge insertions/deletions:
> - Maintains rank decomposition of width $\leq 4k$
> - Under promise that $\text{rw}(G)$ never exceeds $k$
> - **Amortized update time:** $O_k(2^{\sqrt{\log n} \log \log n})$

### 2.3 Theorem 3 (CMSO₁ Maintenance)
> The dynamic data structure can additionally maintain whether $G$ satisfies a fixed $\mathsf{CMSO}_1$ property within the same time complexity.

### 2.4 Theorem 4 (Dense Updates)
> Framework for "dense" edge updates inside vertex set $X$:
> - New edges described by $\mathsf{CMSO}_1$ sentence + vertex labels
> - **Amortized time:** $O_k(|X| \cdot 2^{\sqrt{\log n} \log \log n})$

## 3. Key Technical Concepts

### 3.1 Subpolynomial Factor
The factor $2^{\sqrt{\log n} \log \log n}$ is **subpolynomial** in $n$:
- Grows slower than any $n^\epsilon$ for $\epsilon > 0$
- Represents the cost of maintaining tree-like decomposition under updates

### 3.2 O_k Notation
The $O_k(\cdot)$ notation hides factors depending only on parameter $k$:
- These are typically tower-exponential in $k$
- For fixed $k$, this is a constant

### 3.3 Width Guarantee
| Setting | Width Bound |
|---------|-------------|
| Static algorithm | $k$ (exact) |
| Dynamic maintenance | $4k$ (4-approximation) |

The 4× factor arises from maintaining decomposition under dynamic updates.

## 4. Algorithm Structure

### 4.1 High-Level Approach
1. Build initial rank decomposition using dynamic data structure
2. Insert edges one by one, maintaining decomposition
3. Total time: (# edges) × (amortized update time)
4. Result: $O(m) + n \cdot O_k(2^{\sqrt{\log n} \log \log n}) = O_k(n^{1+o(1)}) + O(m)$

### 4.2 Dynamic Maintenance
The data structure maintains:
- Rank decomposition tree $T$ with leaves labeled by $V(G)$
- For each edge $uv \in T$: cut-rank information for $(X_{uv}, V \setminus X_{uv})$
- Efficient updates when graph edges change

### 4.3 Key Operations
1. **Edge insertion:** Find where new cut affects decomposition, locally repair
2. **Edge deletion:** Update cut-ranks, may need tree restructuring
3. **Amortization:** Potential function bounds total restructuring work

## 5. Connection to Fomin-Korhonen 2021

### 5.1 Building Block
This paper **extends** Fomin-Korhonen 2021's framework:
- FK21: Static $O_k(n^2)$ algorithm via refinement operations
- This paper: Makes refinements dynamic with efficient maintenance

### 5.2 Key Improvement
| Aspect | Fomin-Korhonen 2021 | This paper |
|--------|---------------------|------------|
| Approach | Static computation | Dynamic maintenance |
| Time per vertex | $O_k(n)$ | $O_k(2^{\sqrt{\log n} \log \log n})$ |
| Total | $O_k(n^2)$ | $O_k(n^{1+o(1)})$ |
| Approximation | $2k$ | $k$ (static) / $4k$ (dynamic) |

### 5.3 Technical Relationship
- Uses same "W-improvement" concept for width reduction
- Adds data structures for efficient improvement detection
- Amortizes update costs over operation sequence

## 6. Connection to Dynamic Treewidth

### 6.1 Generalization
> "Our dynamic algorithm generalizes the dynamic treewidth algorithm of Korhonen, Majewski, Nadara, Pilipczuk, and Sokołowski [FOCS 2023]"

### 6.2 Key Differences
| Aspect | Treewidth | Rank-Width |
|--------|-----------|------------|
| Cut function | Size of separator | GF(2) rank of adjacency |
| Algebraic structure | Simple counting | Linear algebra |
| DP table size | $O(2^k)$ | $O(2^{2^{O(k)}})$ |
| Challenge | Separator management | Representative management |

### 6.3 Technical Challenges for Rank-Width
- Cut-rank uses GF(2) linear algebra, not simple counting
- Representative sets have double-exponential size
- More complex data structures needed for efficient updates

## 7. CMSO₁ Property Maintenance

### 7.1 Definition
$\mathsf{CMSO}_1$ (Counting Monadic Second-Order Logic with vertex quantification):
- Quantify over vertices and vertex sets
- Count modulo constants
- Express many graph properties (connectivity, colorability, etc.)

### 7.2 Significance
For fixed $\mathsf{CMSO}_1$ formula $\phi$ and bounded rank-width $k$:
- Can decide $G \models \phi$ in **linear time** (Courcelle-Makowsky-Rotics)
- This paper: Maintain answer **dynamically** with subpolynomial update time

### 7.3 Applications
- Maintain whether graph is 3-colorable
- Maintain whether Hamiltonian path exists
- Maintain domination number (bounded parameter)

## 8. Dense Edge Updates

### 8.1 Framework
For vertex set $X \subseteq V$:
- Specify new edges inside $X$ via $\mathsf{CMSO}_1$ formula with vertex labels
- Update all edges at once more efficiently than one-by-one

### 8.2 Complexity
**Amortized time:** $O_k(|X| \cdot 2^{\sqrt{\log n} \log \log n})$

### 8.3 Use Cases
- Replace induced subgraph $G[X]$ with clique/independent set
- Apply local complementation (relevant for vertex-minors!)
- Batch updates following structural patterns

## 9. Implications for Our Implementation

### 9.1 Theoretical Foundation
- **Ultimate goal:** $O_k(n^{1+o(1)})$ rank-width computation
- Current implementation: $O(n^3)$ via Queyranne
- Gap to bridge: Factor of $n^{2-o(1)}$

### 9.2 DynamicRankWidth.jl Relevance
This paper validates our dynamic approach:
- Incremental edge insertion is theoretically optimal!
- Our `add_edge!` interface aligns with this framework
- Future: Implement efficient representative maintenance

### 9.3 Key Data Structures Needed
1. **Augmented decomposition:** Representatives for each cut
2. **Efficient cut-rank computation:** Maintain GF(2) rank incrementally
3. **Tree updates:** Efficient subtree manipulation

### 9.4 Implementation Path
| Phase | Complexity | Status |
|-------|------------|--------|
| 1. Queyranne | $O(n^3)$ | ✓ Implemented |
| 2. Local Search | $O(n^3)$ improved constants | ✓ Implemented |
| 3. Dynamic Basic | $O(n^2)$ per update | ✓ Partial |
| 4. Dynamic Advanced | $O_k(n^{1+o(1)})$ | Future work |

## 10. Open Questions

### 10.1 From Paper
1. Can exact rank-width (not approximation) be computed in almost-linear time?
2. Can the 4× approximation factor for dynamic case be improved?
3. Can similar techniques apply to other width parameters (mim-width)?

### 10.2 For Implementation
1. What are practical constants hidden in $O_k(\cdot)$?
2. How does subpolynomial factor behave for realistic graph sizes?
3. Is the CMSO₁ maintenance practical for typical applications?

## 11. Comparison Table

| Algorithm | Year | Time | Width Bound | Dynamic? |
|-----------|------|------|-------------|----------|
| Oum-Seymour | 2006 | $O(8^k n^9 \log n)$ | $3k+1$ | No |
| Oum | 2008 | $O(f(k) n^3)$ | $3k-1$ | No |
| Jeong-Kim-Oum | 2018 | $O(2^{2^{O(k^2)}} n^3)$ | Exact | No |
| Fomin-Korhonen | 2021 | $O_k(n^2)$ | $2k$ | No |
| **This paper** | 2024 | $O_k(n^{1+o(1)})$ | $k$ / $4k$ | **Yes** |

## 12. Key Quotes

> "We give an algorithm that given a graph G with n vertices and m edges and an integer k, in time $O_k(n^{1+o(1)}) + O(m)$ either outputs a rank decomposition of G of width at most k or determines that the rankwidth of G is larger than k."

> "The main ingredient of our algorithm is a fully dynamic algorithm for maintaining rank decompositions of bounded width."

> "Our dynamic algorithm generalizes the dynamic treewidth algorithm of Korhonen, Majewski, Nadara, Pilipczuk, and Sokołowski [FOCS 2023]."

## 13. Summary

1. **Breakthrough:** First almost-linear time algorithm for rank-width
2. **Key technique:** Dynamic rank decomposition maintenance
3. **Update time:** Amortized $O_k(2^{\sqrt{\log n} \log \log n})$ - subpolynomial!
4. **Bonus:** CMSO₁ property maintenance at no extra cost
5. **Generalization:** Extends dynamic treewidth techniques
6. **Impact:** MSO₁ model checking now almost-linear on bounded rank-width

**Status:** Completed
