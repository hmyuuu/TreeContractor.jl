# Analysis: Rank-Width and Well-Quasi-Ordering (Oum 2005/2008)

**Paper:** "Rank-Width and Well-Quasi-Ordering"
**Author:** Sang-il Oum
**Year:** 2005 (PhD Thesis) / 2008 (Journal)
**Task:** T-070
**Agent:** PhD-Theory

## 1. The Main Result

**Theorem 4.1 (Main):**
> Let $k$ be a constant. If $\{G_1, G_2, G_3, \ldots\}$ is an infinite sequence of graphs of rank-width at most $k$, then there exist $i < j$ such that $G_i$ is isomorphic to a **pivot-minor** of $G_j$.

**Equivalently:** Graphs of bounded rank-width are **well-quasi-ordered** by the vertex-minor relation.

## 2. Historical Context

This is THE analog of Robertson-Seymour's Graph Minor Theorem for rank-width:

| Property | Tree-Width | Rank-Width |
|----------|------------|------------|
| Containment | Graph minor | Vertex-minor |
| WQO Theorem | Robertson-Seymour (1990) | **This paper** |
| Intermediate | Matroid minor (Geelen et al. 2002) | Isotropic systems |

## 3. Key Concepts

### 3.1 Well-Quasi-Ordering (WQO)
A binary relation $\leq$ on set $X$ is a **well-quasi-ordering** if:
1. It is reflexive and transitive (quasi-order)
2. For every infinite sequence $a_1, a_2, \ldots$ in $X$, there exist $i < j$ with $a_i \leq a_j$

**Implication:** No infinite antichains and no infinite strictly descending chains.

### 3.2 Local Complementation
For graph $G$ and vertex $v$:
$$G * v = (V, E \triangle \{xy : xv, yv \in E, x \neq y\})$$

Effect: Toggle all edges in the neighborhood of $v$.

### 3.3 Pivoting
For edge $uv \in E(G)$:
$$G \wedge uv = G * u * v * u = G * v * u * v$$

### 3.4 Vertex-Minor vs Pivot-Minor
- **Vertex-minor**: Obtained by vertex deletions + local complementations
- **Pivot-minor**: Obtained by vertex deletions + pivotings
- Every pivot-minor is a vertex-minor (but not vice versa)

## 4. Isotropic Systems

The proof uses **Bouchet's isotropic systems** as the key intermediate structure.

### 4.1 Definition
An isotropic system $S = (V, L)$ consists of:
- Finite set $V$
- Totally isotropic subspace $L \subseteq K^V$ with $\dim(L) = |V|$

where $K = \{0, \alpha, \beta, \gamma\}$ is 2-dimensional vector space over GF(2) with bilinear form.

### 4.2 Connection to Graphs
- Every graph $G$ defines an isotropic system via graphic presentation $(G, a, b)$
- Locally equivalent graphs correspond to the same isotropic system
- **Branch-width of isotropic system = Rank-width of fundamental graph + 1**

### 4.3 αβ-minors
For isotropic system $S$, an **αβ-minor** is $S' = S|_{a}^X$ where $a(v) \in \{\alpha, \beta\}$ for all $v$.

**Lemma 10.2:** If $S_1$ is an αβ-minor of $S_2$, then $G_1$ is a pivot-minor of $G_2$.

## 5. Proof Structure

### 5.1 Key Lemmas

**Lemma 4.3 (Linked Decomposition):**
Every graph of rank-width $n$ has a **linked** rank-decomposition of width $n$.

**Lemma 4.4 (Lemma on Subcubic Trees):**
If leaf edges are WQO'd and root edges are not, then there exists an infinite sequence of non-leaf edges with specific ordering properties.

**Theorem 7.2 (Tutte's Linking - Generalized):**
For totally isotropic $L \subseteq K^V$ and $X \subseteq V$:
$$\forall Z \supseteq X: \lambda(L|_{\subseteq Z}) \geq k \iff \exists \text{ complete } a \in K^{V \setminus X} \text{ with } \lambda(L|_a^{V \setminus X}) \geq k$$

### 5.2 Scraps
A **scrap** $P = (V, L, B)$ is:
- Finite set $V$
- Totally isotropic $L \subseteq K^V$
- Ordered basis $B$ of $L^\perp / L$

Scraps are the "local data" carried at nodes in branch-decompositions.

### 5.3 Sum and Connection Type
Two scraps $P_1, P_2$ can be "summed" into a larger scrap $P$ via a **connection type**.
- For bounded λ, there are only finitely many connection types
- This bounds the branching factor in the proof

### 5.4 Main Proposition

**Proposition 9.1:**
If $\{S_1, S_2, \ldots\}$ is an infinite sequence of isotropic systems of branch-width $\leq k$, then there exist $i < j$ such that $S_i$ is simply isomorphic to an αβ-minor of $S_j$.

Proof uses:
1. Linked branch-decompositions → forest structure
2. Associate scraps with edges
3. Define quasi-order on scraps via minor containment
4. Apply Lemma on Trees
5. Connection types bound branching

## 6. Corollaries

### 6.1 Finite Obstruction Set

**Corollary 4.2:**
For each $k$, there exists a **finite** list of graphs $G_1, \ldots, G_m$ such that:
$$\text{rwd}(H) \leq k \iff G_i \not\leq_{\text{vm}} H \text{ for all } i$$

### 6.2 Binary Matroid WQO

**Corollary 11.2:**
Binary matroids of bounded branch-width are WQO by matroid minor relation.

This recovers Geelen-Gerards-Whittle (2002) as a special case!

## 7. Technical Details

### 7.1 The Field K
$K = \{0, \alpha, \beta, \gamma\}$ where:
- $\alpha + \beta + \gamma = 0$
- $\langle x, y \rangle = 1$ iff $x \neq y$ and $x, y \neq 0$

This encodes the "three choices" at each vertex in local complementation.

### 7.2 Connectivity Function
For isotropic system $S = (V, L)$:
$$c(X) = \lambda(L|_{\subseteq X}) = |X| - \dim(L|_{\subseteq X})$$

**Proposition 3.10:** $c(X) = \text{cutrk}_G(X)$ for fundamental graph $G$.

### 7.3 Submodularity
Cut-rank is submodular, which enables the inductive arguments.

## 8. Comparison to Robertson-Seymour

| Aspect | Graph Minor Theorem | This Paper |
|--------|---------------------|------------|
| Objects | Graphs | Graphs (or isotropic systems) |
| Ordering | Minor | Vertex-minor |
| Bounded width | Tree-width | Rank-width |
| Intermediate | Wagner conjecture | Binary matroids |
| Proof length | ~500 pages (20 papers) | ~20 pages |
| Key tool | Grid theorem | Linked decompositions |

## 9. Implications for Algorithms

### 9.1 Polynomial Recognition
Combined with Courcelle-Oum (2007):
- For fixed $k$, can decide rank-width $\leq k$ in polynomial time
- Uses MS definability of vertex-minor containment

### 9.2 Finite Characterization
- Can enumerate obstruction sets for each $k$
- $k = 0$: $K_2$
- $k = 1$: $C_5$ (5-cycle)
- $k \geq 2$: Known to be finite but exponentially large

## 10. Significance for Dense Graph Theory

This is a cornerstone result showing that **rank-width provides the right framework** for dense graph structure theory:

1. **Bounded rank-width** = WQO by vertex-minors ✓
2. **Finite obstructions** exist ✓
3. **Polynomial recognition** possible ✓
4. **MSO tractability** via parse trees ✓

The rank-width theory parallels tree-width theory completely.

## 11. Connection to Quantum Information

The field $K$ and local complementation have quantum interpretations:
- $K$ = Pauli matrices modulo phase
- Local complementation = Local Clifford operation
- Pivot = Basis change (CNOT-like)

WQO implies **entanglement classification** for graph states has finite types at each complexity level.

## 12. Key Quotes

> "We prove that graphs of bounded rank-width are well-quasi-ordered by the vertex-minor relation."

> "This implies that there is a finite list of graphs such that a graph has rank-width at most $k$ if and only if it contains no one in the list as a vertex-minor."

> "The proof uses the notion of isotropic systems defined by Bouchet."

## 13. Summary

This paper establishes that:
1. Graphs of bounded rank-width are WQO by vertex-minors
2. Finite obstruction sets exist for each rank-width level
3. Isotropic systems provide the right algebraic framework
4. The result implies binary matroid WQO as a corollary

**Status:** Completed
