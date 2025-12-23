# Analysis: Graph Operations Characterizing Rank-Width (Courcelle & Kanté 2007)

**Paper:** "Graph Operations Characterizing Rank-Width and Balanced Graph Expressions"
**Authors:** Bruno Courcelle, Mamadou Moustapha Kanté
**Year:** 2007 (WG, LNCS 4769)
**Task:** T-067
**Agent:** PhD-Theory

## 1. Historical Significance

This is THE foundational paper that introduces the **algebraic operations** underlying rank-width. It bridges:
- **Bouchet 1987** (Isotropic Systems)
- **Oum & Seymour 2006** (Rank-Width Definition)
- **Ganian & Hliněný 2010** (Parse Trees)

**Key Innovation:** Directly characterizes rank-width via algebraic terms, avoiding the clique-width conversion blowup.

## 2. The Problem with Clique-Width

**Issue:** To solve MS problems on rank-width-$k$ graphs, one typically:
1. Computes a rank-decomposition (width $k$)
2. Converts to clique-width expression (width up to $2^{k+1} - 1$)
3. Runs clique-width algorithm

**Exponential Blowup:** The conversion step causes exponential parameter dependency.

**This Paper's Solution:** Define algebraic operations that *directly* characterize rank-width.

## 3. Vectorial Colorings over GF(2)

### Definition
A **$B^k$-coloring** of graph $G$ is a mapping $\gamma: V_G \to \{0,1\}^k$.
- Vertex $x$ has color $i$ iff $\gamma(x)[i] = 1$
- Vertices can have multiple colors (or none)

### Color Matrix
For $B^k$-colored graph $G$:
- $\Gamma_G$ = $(V_G \times [k])$-matrix where row $x$ is $\gamma_G(x)$
- **Color-rank:** $crk(G) = \text{rank}(\Gamma_G) \leq k$

## 4. The Core Operations

### 4.1 Linear Recolorings
For linear mapping $h: B^k \to B^\ell$ described by matrix $N$:
$$\text{Recol}_h(G) = (V_G, edg_G, h \circ \gamma_G)$$

New color matrix: $\Gamma_H = \Gamma_G \cdot N$

### 4.2 Bilinear Product (THE KEY OPERATION)

For $G$ ($B^k$-colored), $H$ ($B^\ell$-colored), with:
- $f: B^k \times B^\ell \to \{0,1\}$ bilinear (described by matrix $M$)
- $g: B^k \to B^m$ linear (described by matrix $N$)
- $h: B^\ell \to B^m$ linear (described by matrix $P$)

Define $K = G \otimes_{f,g,h} H = G \otimes_{M,N,P} H$:

$$V_K = V_G \cup V_H$$
$$edg_K = edg_G \cup edg_H \cup \{xy : x \in V_G, y \in V_H, \gamma_G(x) \cdot M \cdot \gamma_H(y)^T = 1\}$$
$$\gamma_K(x) = \gamma_G(x) \cdot N \text{ if } x \in V_G$$
$$\gamma_K(x) = \gamma_H(x) \cdot P \text{ if } x \in V_H$$

**This is exactly the join operator in Ganian 2010's parse trees!**

### 4.3 Constants
- $\mathbf{u}$ for $u \in B^\ell$: single vertex with coloring $u$
- $C_k = \{u : u \in B^\ell, \ell \leq k\}$

## 5. Main Theorem: Algebraic Characterization

**Theorem 1 (Courcelle & Kanté):**
> A graph $G$ has rank-width at most $n$ **iff** it is the value of a term in $T(R_n, C_n)$.

Where:
- $R_n$ = set of bilinear products $\otimes_{M,N,P}$ with appropriate dimensions
- $C_n$ = constants $\{u : u \in B^1 \cup \ldots \cup B^n\}$

### Proof Sketch

**"If" Direction:** Given term $t$ defining $G$, use syntactic tree as layout.
- **Claim 2:** For $t = c \bullet t'$ where $c$ is a context:
  - $A_G[V_H, V_G - V_H] = \Gamma_H \cdot B$ for some matrix $B$
  - Therefore $\text{rank}(A_G[V_H, V_G - V_H]) \leq n$

**"Only If" Direction:** Given layout of width $n$, construct term.
- **Lemma 1:** Any bipartition $(V_1, V_2)$ with cut-rank $m$ can be expressed as $H \otimes_M K$ where $M$ is $m \times m$ nonsingular.

## 6. Quantifier-Free Operations

**Proposition 2:**
1. $\text{Recol}_N$ operations are **quantifier-free**
2. $\otimes_{M,N,P}$ operations are expressible via $\oplus$ and quantifier-free operations

**Corollary 1:** For each $n$, every MS graph property can be decided in time $O(|t|)$ if $G$ is given as term $t \in T(R_n, C_n)$.

This justifies our `DPSolver.jl` approach!

## 7. Balancing Theorems

### The Problem
For parallel algorithms and labeling schemes, we need **balanced** terms (height $O(\log n)$).

### Flexibility Framework
A signature $(F', C')$ is $(F, C)$-**flexible** if:
1. $F$ and $F'$ are commutative
2. Comb-terms can be "flattened" with controlled operations

### Main Balancing Result

**Theorem 5:**
1. Every graph of m-clique-width $k$ → 3-balanced term of m-clique-width ≤ $2k$
2. **Every graph of rank-width $k$ → 3-balanced term of rank-width ≤ $2k$**
3. Every graph of clique-width $k$ → 3-balanced term of clique-width ≤ $k \cdot 2^{k+1}$

**Implication:** Rank-width balancing only doubles the width! Much better than clique-width.

## 8. Relationship to Other Parameters

**Proposition 1:**
1. $rwd(G) \leq cwd(G) \leq 2^{rwd(G)+1} - 1$
2. $mcwd(G) \leq cwd(G) \leq 2^{mcwd(G)+1}$
3. $mcwd(G) \leq twd(G) + 3$
4. $rwd(G) \leq 4 \times twd(G) + 2$

## 9. Connection to Our Implementation

### `ParseTrees.jl`
Directly implements Definition 2.5 from Ganian 2010, which is based on this paper's $\otimes_{M,N,P}$.

### `DPSolver.jl`
Implements Corollary 1: MS properties in $O(|t|)$ time.

### `LocalSearch.jl`
The "rotation" operations correspond to changing the bilinear product matrices.

## 10. Key Algebraic Properties

**Remark 1 (Symmetries):**
$$G \otimes_{M,N,P} H = H \otimes_{M^T,P,N} G$$
$$\text{Recol}_Q(G) \otimes_{M,N,P} \text{Recol}_{Q'}(H) = G \otimes_{QMQ'^T, QN, Q'P} H$$
$$G \otimes_{M,N,P} \emptyset_k = \text{Recol}_N(G)$$
$$\text{Recol}_Q(G \otimes_{M,N,P} H) = G \otimes_{M,NQ,PQ} H$$

These identities are used for tree rotations in balancing!

## 11. Implications for Algorithm Design

| Approach | Parameter Dependency | Source |
|----------|---------------------|--------|
| Via Clique-Width | $2^{O(2^k)}$ | Courcelle 2000 |
| **Direct Rank-Width** | $2^{O(k^2)}$ | **This Paper** |
| Balanced Terms | Extra factor of 2 in width | Theorem 5 |

## 12. Conclusion

Courcelle & Kanté 2007 establishes the **algebraic foundations** for rank-width algorithms:

1. **Bilinear products** $\otimes_{M,N,P}$ characterize rank-width exactly
2. **Direct MS algorithms** avoid clique-width conversion blowup
3. **Balancing** with only 2× width increase enables parallel algorithms
4. **Quantifier-free** operations enable linear-time property checking

**Key Quote:** "It is thus somewhat natural that [bilinear forms] can generate exactly the set of graphs of rank-width at most $k$ since rank-width is based on ranks of GF(2) matrices."

**Status:** ✅ Completed
