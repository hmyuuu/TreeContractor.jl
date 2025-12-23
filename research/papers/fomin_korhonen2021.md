# Analysis: Fast FPT-Approximation of Branchwidth (Fomin-Korhonen 2021)

**Paper:** "Fast FPT-Approximation of Branchwidth"
**Authors:** Fedor V. Fomin, Tuukka Korhonen
**Year:** 2021 (arXiv:2111.03492, FOCS 2021)
**Task:** T-079
**Agent:** PhD-Algo

## 1. Overview

This paper **breaks the cubic barrier** for rank-width computation and develops a general framework for:
1. FPT **2-approximation** algorithms for branchwidth of connectivity functions
2. **$2^{2^{O(k)}} n^2$** algorithm for rank-width (first sub-cubic!)
3. **$2^{O(k)} n$** algorithm for graph branchwidth

## 2. Main Results

### 2.1 Theorem 1 (Rank-Width)
> For integer $k$ and $n$-vertex graph $G$, there is an algorithm that in time $2^{2^{O(k)}} n^2$ either:
> - Constructs a rank decomposition of width $\leq 2k$, or
> - Concludes that $\text{rw}(G) > k$

**Corollary 1.1:** $(2^{2k+1}-1)$-expression for clique-width in same time.

### 2.2 Theorem 2 (Graph Branchwidth)
> For integer $k$ and $n$-vertex graph $G$, there is an algorithm that in time $2^{O(k)} n$ either:
> - Constructs branch decomposition of width $\leq 2k$, or
> - Concludes that $\text{bw}(G) > k$

### 2.3 Historical Significance
| Algorithm | Time | Approximation |
|-----------|------|---------------|
| Oum & Seymour 2006 | $O(8^k n^9 \log n)$ | $3k+1$ |
| Oum 2008 | $O(h(k) \cdot n^3)$ | $3k-1$ |
| Jeong, Kim, Oum 2018 | $O(2^{2^{O(k^2)}} n^3)$ | exact |
| **This paper** | $O(2^{2^{O(k)}} n^2)$ | $2k$ |

## 3. The Refinement Framework

### 3.1 Key Concept: W-Improvement
**Definition 4.3:** A tripartition $(C_1, C_2, C_3)$ of $V$ is a **W-improvement** if for every $i \in \{1,2,3\}$:
- $f(C_i) < f(W)/2$
- $f(C_i \cap W) < f(W)$
- $f(C_i \cap \overline{W}) < f(W)$

### 3.2 Main Combinatorial Theorem (Theorem 3)
> If $W \subseteq V$ with $f(W) > 2 \cdot \text{bw}(f)$, then there exists a W-improvement.

**Proof idea:** Take optimal branch decomposition, orient edges based on $W$. Either find disoriented edge (Lemma 4.3) or oriented internal node (Lemma 4.4).

### 3.3 Refinement Operation (Definition 4.2)
Given decomposition $(T, L)$, edge $uv$, and tripartition $(C_1, C_2, C_3)$:
1. Create partial decompositions $(T_i, L_i) = (T, L \restriction_{C_i})$
2. Insert node $w_i$ on edge $u_i v_i$ in each $T_i$
3. Connect $w_1, w_2, w_3$ to new center node $t$
4. Simplify (remove unlabeled leaves, suppress degree-2 nodes)

### 3.4 Global T-Improvement (Theorem 6)
> Let $(r, C_1, C_2, C_3)$ be a global T-improvement. Then for every $i$ and node $w$:
> $$f(T_r[w] \cap C_i) \leq f(T_r[w])$$
> Moreover, $f(T_r[w] \cap C_i) = f(T_r[w])$ iff $T_r[w] \subseteq C_i$.

## 4. Minimum W-Improvement

**Definition 4.4:** $(C_1, C_2, C_3)$ is minimum W-improvement if:
1. **Minimum width:** $\max\{f(C_1), f(C_2), f(C_3)\}$ is minimized
2. **Minimum arity:** Subject to (1), number of non-empty $C_i$ is minimum
3. **Minimum sum-width:** Subject to (1,2), $f(C_1) + f(C_2) + f(C_3)$ is minimized
4. **Minimum intersection:** Subject to (1-3), intersects minimum nodes of $T$

**Key Lemma 4.2:** If $(C_1, C_2, C_3)$ is minimum W-improvement and $W' \subseteq W$:
$$f(W' \cap C_i) \leq f(W')$$

## 5. Algorithmic Framework

### 5.1 Potential Function (Definition 5.3)
$$\phi_k(T) = \sum_{e: f(e) < k} f(e) \cdot 3^{f(e)} + \sum_{e: f(e) \geq k} 3^{f(e)} \cdot 3^{f(e)}$$

**Key Property (Lemma 5.3):** Refining with edit set $R$ decreases potential by at least $|R|$.

### 5.2 Algorithm Structure (Algorithm 5.1)
```
1. Start with DFS on decomposition T
2. For each heavy edge uv (f(uv) = bw(T)):
   - If W-improvement exists: Refine T
   - If not: Conclude bw(T) ≤ 2·bw(f)
3. Continue until width decreases or proven 2-approx
```

### 5.3 Time Complexity Analysis
- Total sum of edit set sizes: $O(2^{O(k)} n)$ (by potential argument)
- Per-refinement work: $O(t(k) \cdot |R|)$ where $t(k)$ = DP time per node
- **Total:** $O(t(k) \cdot 2^{O(k)} \cdot n)$

## 6. Rank-Width Implementation

### 6.1 Augmented Rank Decompositions
Store minimal representatives of $(T[uv], T[vu])$ for each edge.

**Proposition 6.2:** If $\text{cutrk}(A) \leq k$, minimal representative has size $\leq 2^k$.

### 6.2 Embeddings (Definition 6.6)
Embedding $f: V(H) \to 2^{V(G)}$ of bipartite $G[A,B]$ into $H$ satisfies:
- $f(u) \cap f(v) = \emptyset$ for $u \neq v$
- $A = \bigcup_{v \in A_H} f(v)$, $B = \bigcup_{v \in B_H} f(v)$
- Edge condition preserved

**Key (Proposition 6.3):** $\text{cutrk}(A) \leq k$ iff embedding into $R_k$ exists.

### 6.3 Improvement Embeddings
Store 10-tuple $(f^C_1, f^C_2, f^C_3, f^W_1, f^W_2, f^W_3, k_1, k_2, k_3, l)$ for:
- $f^C_i$: embedding of $G[C_i, \overline{C_i}]$ into $R_{k_i}$
- $f^W_i$: embedding of $G[C_i \cap A, C_i \cap \overline{A}]$ into $R_l$

### 6.4 DP Table Size
- Number of AR-representatives: $(2^{2^k})^{|V(H)|} = 2^{2^{O(k)}}$
- Time per DP step: $2^{2^{O(k)}}$
- **Total with iterative compression:** $2^{2^{O(k)}} \cdot n^2$

## 7. Graph Branchwidth Implementation

### 7.1 Border of Tripartition
For $(C_1, C_2, C_3)$ of $A \subseteq E(G)$:
$$R_i = \delta(C_i) \cap \delta(A), \quad k_i = |\delta(C_i) \setminus \delta(A)|$$

### 7.2 DP Table Size
- Number of k-bounded borders: $(2k)^3 \cdot 2^{3k} \cdot 3 = 2^{O(k)}$
- Time per DP step: $2^{O(k)}$
- **Total:** $2^{O(k)} \cdot n$

## 8. Key Technical Insights

### 8.1 Six Fundamental Properties
1. **Submodularity:** $f(A) + f(B) \geq f(A \cup B) + f(A \cap B)$
2. **Symmetry:** $f(A) = f(\overline{A})$
3. **Connectivity:** $f(\emptyset) = 0$
4. **Orientation:** W directly/inversely orients C based on $f(C \cap W)$ vs $f(C \cap \overline{W})$
5. **Edit sets form connected subtrees**
6. **Potential decreases monotonically**

### 8.2 Why 2-Approximation?
- W-improvement exists when $f(W) > 2 \cdot \text{bw}(f)$
- Refinement preserves width $\leq k$
- Heavy edges decrease until $\leq 2 \cdot \text{bw}(f)$

### 8.3 Why Cubic Barrier Broken?
Previous algorithms: Per-iteration work $O(n^3)$ for $n$ iterations
This paper: Amortized analysis via potential function bounds total work

## 9. Implications for Our Implementation

### 9.1 Algorithm Choice
For **practical** implementation:
- If $k$ small: Use this 2-approximation
- If high accuracy needed: Use Oum 2008 (3k-1)-approximation with $O(n^3)$
- If exact needed: Use Jeong-Kim-Oum 2018

### 9.2 LocalSearch.jl Enhancement
The **refinement operation** maps directly to our local search moves:
- Current: 3-way split heuristic
- Enhancement: Use W-improvement detection for provable 2-approximation

### 9.3 DynamicRankWidth.jl
Potential function analysis provides:
- Theoretical bound on total update work
- Amortization argument for dynamic updates

### 9.4 Key Data Structures
1. **Augmented decomposition:** Store representatives for each edge
2. **DP tables:** AR-representatives of improvement embeddings
3. **Edit sets:** Track nodes affected by refinement

## 10. Comparison: Treewidth vs Rank-Width

| Aspect | Treewidth | Rank-Width |
|--------|-----------|------------|
| 2-approx | $2^{O(k)} n$ | $2^{2^{O(k)}} n^2$ |
| Exact FPT | $2^{O(k^3)} n$ | $2^{2^{O(k^2)}} n^3$ |
| DP table | $O(2^k)$ | $O(2^{2^{O(k)}})$ |
| Barrier | None | **Cubic broken!** |

## 11. Open Questions (from Paper)

1. Can rank-width be computed in $f(k) \cdot n$ time? (Currently $n^2$)
2. Can approximation ratio be improved below 2 with same complexity?
3. Can mim-width benefit from similar techniques?

## 12. Key Quotes

> "Breaking the 'cubic barrier' for rankwidth and cliquewidth was an open problem in the area."

> "Our central combinatorial insight is that if the width of $(T, L)$ is more than $2 \cdot \text{bw}(f)$, then for any heavy edge $e$, there is a partition of $V$ into three sets $(C_1, C_2, C_3)$ with some particular properties."

> "The algorithmic ingredient of our general framework strongly uses the combinatorial properties of global T-improvements."

## 13. Summary

1. **Breakthrough:** First sub-cubic algorithm for rank-width ($n^2$ vs $n^3$)
2. **Framework:** General 2-approximation for connectivity function branchwidth
3. **Technique:** Refinement operations + potential function analysis
4. **Key insight:** W-improvement exists when width > 2·optimal
5. **Practical impact:** MSO₁ problems now $f(k) \cdot n^2$ on bounded clique-width

**Status:** Completed
