# Analysis: Approximating Clique-Width and Branch-Width (Oum-Seymour 2006)

**Paper:** "Approximating Clique-Width and Branch-Width"
**Authors:** Sang-il Oum, Paul Seymour
**Year:** 2006 (Journal of Combinatorial Theory, Series B, Vol. 96, Issue 4, pp. 514-528)
**Task:** T-076
**Agent:** PhD-Algo

## 1. Overview

This is the **foundational paper** that:
1. **Introduces rank-width** as a graph parameter
2. **Proves** rank-width is equivalent to clique-width (up to exponential factors)
3. **Provides first polynomial-time approximation** for both parameters
4. **Establishes the well-linked set technique** for branch-width approximation

## 2. Main Results

### 2.1 Theorem 1.1 (Clique-Width Approximation)
For fixed $k$, there is an algorithm that:
- **Input:** $n$-vertex graph $G$
- **Output:** Either decides $\text{cw}(G) > k$, or outputs $(2^{3k+2}-1)$-expression
- **Time:** $O(n^9 \log n)$

### 2.2 Theorem 1.2 (Matroid Branch-Width)
For fixed $k$, there is an algorithm that:
- **Input:** $n$-element matroid $M$ (rank oracle)
- **Output:** Branch-decomposition of width $\leq 3k-1$ or confirm $\text{bw}(M) > k$
- **Time:** $O(n^{3.5})$

## 3. Submodular Functions Framework

### 3.1 Definitions
A function $f: 2^V \to \mathbb{Z}$ is:
- **Submodular:** $f(X) + f(Y) \geq f(X \cap Y) + f(X \cup Y)$
- **Symmetric:** $f(X) = f(V \setminus X)$

### 3.2 Branch-Width
For symmetric submodular $f$:
- **Branch-decomposition:** $(T, L)$ where $T$ is subcubic tree, $L: V \to \text{leaves}(T)$ bijection
- **Width of edge $e$:** $f(L^{-1}(X))$ where $X$ = descendant leaves of one component
- **Branch-width:** $\text{bw}(f) = \min_{(T,L)} \text{width}(T,L)$

## 4. Interpolation of Submodular Functions

### 4.1 Definition 4.1
An **interpolation** $f^*: 3^V \to \mathbb{Z}$ of submodular $f$ satisfies:

**(i)** $f^*(X, V \setminus X) = f(X)$ for all $X \subseteq V$

**(ii)** (Uniform) If $C \cap D = \emptyset$, $A \subseteq C$, $B \subseteq D$, then $f^*(A,B) \leq f^*(C,D)$

**(iii)** (Submodular) $f^*(A,B) + f^*(C,D) \geq f^*(A \cap C, B \cup D) + f^*(A \cup C, B \cap D)$

**(iv)** $f^*(\emptyset, \emptyset) = f(\emptyset)$

### 4.2 Canonical Interpolation
**Proposition 4.2:** $f_{\min}(X,Y) = \min_{X \subseteq Z \subseteq V \setminus Y} f(Z)$ is an interpolation.

## 5. Well-Linked Sets

### 5.1 Definition 5.1
$W \subseteq V$ is **well-linked** with respect to $f$ if for every partition $(X,Y)$ of $W$ and every $Z$ with $X \subseteq Z \subseteq V \setminus Y$:
$$f(Z) \geq \min(|X|, |Y|)$$

### 5.2 Theorem 5.1 (Lower Bound)
> If there is a well-linked set of size $k$, then $\text{bw}(f) \geq k/3$.

**Proof Sketch:**
- For any branch-decomposition, there exists an edge $e$ with $|A \cap W| \geq k/3$ and $|B \cap W| \geq k/3$
- Well-linkedness forces $f(A) \geq k/3$

### 5.3 Theorem 5.2 (Upper Bound)
> If there is no well-linked set of size $k$, then $\text{bw}(f) \leq k$.

**Proof Idea:**
- Iteratively extend partial branch-decompositions
- When stuck at leaf $t$ with $|L^{-1}(t)| > 1$:
  - Find base $X$ of matroid induced by $f^*$
  - If $X$ not well-linked, find witness $Z$ to split $L^{-1}(t)$

## 6. Cut-Rank Function

### 6.1 Definition 6.1
For graph $G$ and disjoint $X, Y \subseteq V(G)$:
$$\text{cutrk}^*_G(X, Y) = \text{rank}(A(G)[X,Y]) \text{ over GF(2)}$$
$$\text{cutrk}_G(X) = \text{cutrk}^*_G(X, V(G) \setminus X)$$

### 6.2 Corollary 6.2 (Submodularity)
$$\text{cutrk}^*_G(X_1, Y_1) + \text{cutrk}^*_G(X_2, Y_2) \geq \text{cutrk}^*_G(X_1 \cap X_2, Y_1 \cup Y_2) + \text{cutrk}^*_G(X_1 \cup X_2, Y_1 \cap Y_2)$$

## 7. Rank-Width Definition

**Rank-decomposition:** Branch-decomposition of $\text{cutrk}_G$

**Rank-width:** $\text{rwd}(G) = \text{bw}(\text{cutrk}_G)$

## 8. Rank-Width vs Clique-Width

### 8.1 Proposition 6.3
$$\text{rwd}(G) \leq \text{cwd}(G) \leq 2^{\text{rwd}(G)+1} - 1$$

### 8.2 Proof: rwd(G) ≤ cwd(G)
- Given $k$-expression, construct rank-decomposition from tree structure
- Key insight: Vertices with same label have identical neighbors outside their subtree
- At most $k$ distinct neighbor patterns → cut-rank $\leq k$

### 8.3 Proof: cwd(G) ≤ 2^{rwd(G)+1} - 1
- Process rank-decomposition tree bottom-up
- At each internal node, merge labels with identical external neighbors
- GF(2) matrix of rank $\leq k$ has $\leq 2^k - 1$ distinct nonzero rows
- Therefore need $\leq 2^k$ labels

### 8.4 Conversion Algorithm
Rank-decomposition of width $k$ → $(2^{k+1}-1)$-expression in **$O(n^2)$** time.

## 9. Main Algorithm

### 9.1 Corollary 5.3 (General)
For fixed $k$, given symmetric submodular $f$:
- Time: $O(|V|^7 \gamma \log |V|)$ where $\gamma$ = time per $f$ evaluation
- Approximation: $3k+1$

### 9.2 Corollary 5.4 (With Interpolation)
Given interpolation $f^*$:
- Time: $O(|V|^6 \delta \log |V|)$ where $\delta$ = time per $f^*$ evaluation
- Approximation: $3k+1$

### 9.3 Corollary 6.4 (Rank-Width)
- Time: $O(n^9 \log n)$ (since $\text{cutrk}^*_G$ computable in $O(n^3)$)
- Approximation: $3k+1$

### 9.4 Corollary 6.5 (Clique-Width)
- Time: $O(n^9 \log n)$
- Approximation: $2^{3k+2} - 1$

## 10. Matroid Branch-Width

### 10.1 Connectivity Function
For matroid $M$ with rank function $r$:
$$\lambda(X) = r(X) + r(E(M) \setminus X) - r(M) + 1$$

### 10.2 Proposition 7.1 (Geelen's Interpolation)
For base $B$ of $M$:
$$\lambda_B(X, Y) = r(X \cup (B \setminus Y)) + r(Y \cup (B \setminus X)) - |B \setminus X| - |B \setminus Y| + 1$$

### 10.3 Corollary 7.2
Using matroid intersection algorithm:
- Time: $O(n^{3.5})$
- Approximation: $3k-1$

## 11. Comparison: Before and After

| Algorithm | Time | Approximation |
|-----------|------|---------------|
| Johansson 2001 | $O(n^{2k+1})$ | $2^k \log n$ |
| **This paper** | $O(n^9 \log n)$ | $2^{3k+2}-1$ |

Key improvement: **Constant factor approximation** instead of $O(\log n)$.

## 12. Graph Classes and Clique-Width

From the paper:
- **Cographs** (no induced $P_4$): $\text{cw} \leq 2$
- **Complete graphs $K_n$:** $\text{cw} = 2$
- **Trees:** $\text{cw} \leq 3$
- **Bounded tree-width $k$:** $\text{cw} \leq O(2^k)$

Reverse bound:
> If $\text{cw}(G) \leq k$ and $K_{t,t} \not\subseteq G$, then $\text{tw}(G) \leq 3k(t-1) - 1$

## 13. Counterexample: Cut-Rank Not Always Matroidal

The paper shows graph $G$ with $V = \{1,2,3,4,5,6,7\}$, $E = \{12, 23, 34, 45, 56, 16, 17, 47\}$ (7-cycle with chord) has no matroid $M$ with $\text{cutrk}_G + 1$ as connectivity function.

This proves we **cannot always** use faster matroid algorithms for rank-width.

## 14. Implications for Our Implementation

### 14.1 Queyranne.jl
- Our implementation uses the submodular function minimization approach
- The well-linked set technique is the theoretical foundation

### 14.2 Key Algorithmic Components
1. **Interpolation computation:** $O(n^5 \gamma \log n)$ via submodular minimization
2. **Base finding:** $O(n^2)$ using matroid properties
3. **Well-linkedness check:** $O(2^k)$ partition checks
4. **Tree extension:** $O(n)$ iterations

### 14.3 Practical Considerations
- For small $k$, the $O(n^9)$ bound is loose
- Actual runtime depends on $k$ and graph structure
- Later improvements (Oum 2008) reduced to $O(n^4)$ then $O(n^3)$

## 15. Historical Significance

This paper:
1. **Created rank-width** as a tractable alternative to clique-width
2. **First showed** constant-factor approximation is possible
3. **Established framework** for all subsequent rank-width algorithms
4. **Connected** clique-width to matroid theory and submodular optimization

## 16. Key Quotes

> "We construct a polynomial-time algorithm to approximate the branch-width of certain symmetric submodular functions, and give two applications."

> "We define the 'rank-width' of a graph to be the branch-width of a symmetric submodular function determined by a graph."

> "For fixed k, there is an algorithm that with input an n-vertex graph G, either decides that G has clique-width at least k + 1, or outputs a decomposition of G with clique-width at most 2^{3k+2} - 1."

> "However, the problem of deciding whether a graph has clique-width at most k is not known to belong to this class. There is still no polynomial-time algorithm to test whether G has clique-width at most k, for a fixed general k."

## 17. Open Questions (at time of publication)

1. Is there a polynomial-time algorithm to decide $\text{cw}(G) \leq k$?
2. Can the approximation factor be improved?
3. Can the running time be improved?

**Status (2025):** Question 1 remains open. Questions 2 and 3 were addressed by Oum 2008 ($3k-1$ in $O(n^3)$).

## 18. Summary

1. **Rank-width introduced:** Branch-width of cut-rank function
2. **Equivalence:** $\text{rwd} \leq \text{cwd} \leq 2^{\text{rwd}+1} - 1$
3. **Algorithm:** $O(n^9 \log n)$ for $(3k+1)$-approximation
4. **Technique:** Well-linked sets + submodular function minimization
5. **Impact:** Foundation for all rank-width algorithms

**Status:** Completed
