# Analysis: Linear Rank-Width of Distance-Hereditary Graphs I (Adler et al. 2017)

**Paper:** "Linear Rank-Width of Distance-Hereditary Graphs I. A Polynomial-Time Algorithm"
**Authors:** Isolde Adler, Mamadou Moustapha Kanté, O-joung Kwon
**Year:** 2017 (Algorithmica, Vol. 78, Issue 1, pp. 342-377)
**Task:** T-077
**Agent:** PhD-Algo

## 1. Overview

This paper provides:
1. **$O(n^2 \log^2 n)$ algorithm** to compute linear rank-width of distance-hereditary graphs
2. **Characterization** via canonical split decompositions and "limbs"
3. **Corollary:** Path-width of matroids with branch-width ≤ 2 in same complexity

## 2. Key Definitions

### 2.1 Linear Rank-Width
For linear layout $(x_1, \ldots, x_n)$:
$$\text{width} = \max_{1 \leq i \leq n-1} \text{cutrk}_G(\{x_1, \ldots, x_i\})$$
$$\text{lrw}(G) = \min_{\text{layouts}} \text{width}$$

### 2.2 Distance-Hereditary Graphs
**Definition:** $G$ is distance-hereditary if for every $u, v \in V(G)$, distance in any connected induced subgraph containing both equals distance in $G$.

**Theorem 2.1 (Oum):**
> Distance-hereditary graphs = graphs of rank-width at most 1.

### 2.3 Upper Bound
**Lemma 2.2:**
$$\text{lrw}(G) \leq \text{rw}(G) \cdot \lfloor \log_2 |V(G)| \rfloor$$

For distance-hereditary graphs (rw ≤ 1):
$$\text{lrw}(G) \leq \lfloor \log_2 n \rfloor$$

## 3. Canonical Split Decomposition

### 3.1 Split Definition
$(X, Y)$ is a **split** in connected $G$ if:
- $|X|, |Y| \geq 2$
- $\text{rank}(A_G[X, Y]) = 1$

### 3.2 Canonical Decomposition
**Theorem 2.7 (Cunningham-Edmonds; Dahlhaus):**
> Every connected graph has unique canonical decomposition, computable in $O(|V| + |E|)$.

For distance-hereditary graphs:
- **Theorem 2.9 (Bouchet):** Each bag is type K (complete) or S (star)
- **Theorem 2.8 (Bouchet):** No marked edges of type KK or $S_pS_c$

## 4. Key Innovation: Limbs

### 4.1 Motivation
When removing bag $B$ from decomposition:
- Sub-decompositions don't directly give limbs
- Need to handle marked vertices with neighbors in $B$

### 4.2 Limb Definition (Definition 3.1)
For unmarked vertex $y$ represented by marked vertex $w$ in bag $B$:

Let $T$ = component of $D \setminus V(B)$ containing $y$, $v = \zeta_c(D, B, T)$:

1. **If $B$ is type K:** $L = T * v \setminus v$
2. **If $B$ is type S and $w$ is leaf:** $L = T \setminus v$
3. **If $B$ is type S and $w$ is center:** $L = T \wedge vy \setminus v$

### 4.3 Canonical Limbs
Transform limb $L$ to canonical form by:
- Recomposing marked edges when bag becomes size 2
- Handling cases with 1 or 2 neighbor bags

### 4.4 Key Lemma 3.3
> If $x$ and $y$ are represented by same vertex $w$ in $B$, then $L_D[B, x]$ is locally equivalent to $L_D[B, y]$.

## 5. Main Characterization

### 5.1 Theorem 4.1
Let $D$ be canonical decomposition of distance-hereditary $G$. Then:
$$\text{lrw}(G) \leq k \iff \text{for each bag } B:$$
- At most **two** components $T$ of $D \setminus V(B)$ have $f_D(B, T) = k$
- All other components $T'$ satisfy $f_D(B, T') \leq k - 1$

### 5.2 Connection to Trees
**Proposition 3.1 (Ellis-Sudborough-Turner):**
> Tree $T$ has path-width ≤ $k$ iff for every vertex $v$, at most two components of $T \setminus v$ have path-width ≤ $k$, others have path-width ≤ $k - 1$.

Theorem 4.1 generalizes this to distance-hereditary graphs!

## 6. Algorithm Structure

### 6.1 k-Critical Nodes
Node $v$ is **$k$-critical** if:
- $f_1(D, v) = k$
- $v$ has two children $v_1, v_2$ with $f_1(D, v_1) = f_1(D, v_2) = k$

### 6.2 Algorithm Outline (Algorithm 2)
1. Compute modified canonical decomposition $(D, R)$
2. Root decomposition tree $T$ at $R$
3. For each non-root node $v$:
   - Compute sequences of canonical limbs $D_j^v$
   - Track $\alpha_j^v = \max\{f_1(D_j^v, w)\}$ and $\beta_j^v = \text{lrw}(G[D_j^v])$
4. Handle critical nodes via recursive limb computation
5. Return $\beta_{r'}^\eta$ where $r'$ is root's neighbor

### 6.3 Time Complexity
- Each Limb computation: $O(n)$
- Loop iterations: $O(n)$ (number of bags)
- Inner loop: $O(\log n)$ iterations
- **Total:** $O(n^2 \log^2 n)$

## 7. Technical Results

### 7.1 Proposition 5.1 (Order Independence)
Taking canonical limbs with respect to $B_1$ then $B_2$ gives same result (up to local equivalence) as $B_2$ then $B_1$.

### 7.2 Proposition 5.2
Let $T_1$ be component not containing $B_2$, $T_2$ contain $B_1$:
> If $V(B_1)$ induces bag in $LC_D[B_2, y_2]$, then $LC_D[B_1, y_1]$ is locally equivalent to $LC_{LC_D[B_2,y_2]}[B_1', y_1']$.

### 7.3 Proposition 6.5 (Key for Algorithm)
Let $w$ be non-root node of $T_i^v$. Then:
$$\beta_i^w = f_1[D_i^v, w]$$

## 8. Matroid Application

### 8.1 Connectivity Function
For matroid $M$ with rank function $r$:
$$\lambda_M(X) = r(X) + r(E(M) \setminus X) - r(M) + 1$$

### 8.2 Proposition 7.1 (Oum)
For bipartite $G$ with bipartition $(A, B)$ and $M = M(G, A, B)$:
$$\text{cutrk}_G(X) = \lambda_M(X) - 1$$
$$\text{rw}(G) = \text{bw}(M) - 1$$
$$\text{lrw}(G) = \text{pw}(M) - 1$$

### 8.3 Corollary 7.4
> Path-width of $n$-element matroid with branch-width ≤ 2 computable in $O(n^2 \log^2 n)$.

## 9. Comparison Table

| Graph Class | Linear RW Complexity | Notes |
|-------------|---------------------|-------|
| General | NP-hard | Kashyap 2008 |
| Trees/Forests | $O(n)$ | Adler-Kanté 2015 |
| **Distance-Hereditary** | $O(n^2 \log^2 n)$ | **This paper** |
| Bounded rank-width | $O(f(k) \cdot n^3)$ | Jeong-Kim-Oum 2016 |

## 10. Width Parameter Hierarchy

For distance-hereditary graphs:
- $\text{rw}(G) \leq 1$ (by definition)
- $\text{lrw}(G) \leq \lfloor \log_2 n \rfloor$
- Path-width can be **unbounded** (NP-hard even on DH graphs!)

Key insight: Linear rank-width captures different complexity than path-width.

## 11. Implications for Our Implementation

### 11.1 LinearRankWidth.jl
- This paper provides theoretical foundation for computing lrw on DH graphs
- Can specialize our algorithm for rw ≤ 1 case
- $O(n^2 \log^2 n)$ is practical for large graphs

### 11.2 Split Decomposition Integration
- Canonical split decomposition is key data structure
- Limbs generalize sub-decompositions correctly
- Order of limb computation doesn't matter (Prop 5.1)

### 11.3 Quantum Applications
Linear rank-width connects to:
- MPS (Matrix Product States) for 1D systems
- Caterpillar decompositions
- Optimal tensor network contraction order

## 12. Key Quotes

> "We show that the linear rank-width of every n-vertex distance-hereditary graph... can be computed in time $O(n^2 \cdot \log^2 n)$."

> "Our characterization is similar to the known characterization of the path-width of forests given by Ellis, Sudborough, and Turner."

> "We introduce a notion of 'limbs' of canonical split decompositions, which correspond to certain vertex-minors of the original graph."

> "In contrast, computing the path-width of distance-hereditary graphs is known to be NP-hard."

## 13. Open Questions (from Paper)

> "Further research should focus on possible parameterized algorithms on linear rank-width – it is not clear whether or how our polynomial algorithms might be extended to graphs of bounded linear rank-width."

## 14. Summary

1. **Characterization:** lrw via canonical split decompositions + limbs
2. **Algorithm:** $O(n^2 \log^2 n)$ for distance-hereditary graphs
3. **Innovation:** Limbs handle boundary vertices correctly
4. **Application:** Path-width of matroids with bw ≤ 2
5. **Contrast:** Path-width on DH graphs is NP-hard!

**Status:** Completed
