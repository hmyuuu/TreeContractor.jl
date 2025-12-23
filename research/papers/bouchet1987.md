# Analysis: Isotropic Systems (Bouchet 1987)

**Paper:** "Isotropic Systems"
**Author:** André Bouchet
**Year:** 1987 (European Journal of Combinatorics, Vol. 8, pp. 231-244)
**Task:** T-065
**Agent:** PhD-Theory

## 1. Formal Definition

An **Isotropic System** is a pair $(L, V)$ where:
- $V$ is a finite set
- $K$ is a 2-dimensional vector space over $GF(2)$ with bilinear form $xy = 1 \iff 0 \neq x \neq y \neq 0$
- $L \subseteq K^V$ is a **totally isotropic subspace** (every two vectors are orthogonal)
- $\dim(L) = |V|$

**Key Property:** Two vectors $A, B \in K^V$ are orthogonal iff $|\{v \in V : 0 \neq A(v) \neq B(v) \neq 0\}|$ is even.

## 2. Two Fundamental Subclasses

### 2.1 Sum-Decomposable Systems (from Binary Matroids)
Given dual binary matroids $M = (N, V)$ and $M^* = (N^\perp, V)$, and supplementary vectors $A, B$:
$$S = (AN + BN^\perp, V)$$
is an isotropic system. This captures **matroid structure**.

### 2.2 Graphic Systems (from 4-Regular Graphs)
Given a 4-regular graph $G$ with **transition coding** $(T_v : v \in V)$:
- Each vertex $v$ has 4 half-edges partitioned into 3 pairs of **transitions**
- The **tangent mapping** $T: \mathcal{Z}(G) \to K^V$ maps cycles to vectors
- $(L, V) = (\text{Im}(T), V)$ is an isotropic system

**Crucial Result:** Graphic systems correspond exactly to **Circle Graphs**.

## 3. Local Complementation

**Definition:** The local complementation of a simple graph $F$ at vertex $v$ replaces the subgraph induced on $N(v) = \{w : vw \in E(F)\}$ by its complement.

**Theorem (Bouchet):** Every isotropic system is associated to a class of **locally equivalent graphs**. The isotropic system is graphic iff these graphs are **circle graphs**.

This is THE fundamental operation for rank-width theory!

## 4. Connection to Distance-Hereditary Graphs

**Major Result:** A graph is **totally decomposable** (built by successive compositions of graphs of order 3) iff it excludes the 5-cycle as an **i-minor** (vertex-minor).

**Surprising Equivalence:** Totally decomposable graphs = **Distance-Hereditary Graphs**
- A graph is distance-hereditary iff every chordless path is geodetic
- These have **Linear Rank-Width ≤ 1**

This connects directly to our `LinearRankWidth.jl` implementation!

## 5. Touch-Graphs and Projections

For a complete vector $A \in K^V$ and eulerian decomposition $D(A)$:
- **Touch-graph** $\text{Tch}(A)$: vertices = closed trails in $D(A)$, edges = vertices of $G$
- **Projection** $M(A)$: a binary matroid derived from $S$

**Key Formula:** $r(A) = k(A) - k(G)$ where $k(A)$ = number of closed trails, $k(G)$ = components.

## 6. Minors of Isotropic Systems

**Elementary Minor:** $S|_v^x = (L|_v^x, V - v)$ for $v \in V$, $x \in K - 0$

**Theorem:** Minors of graphic systems are graphic systems.

This mirrors **vertex-minor** operations on graphs and explains why rank-width is monotonic under vertex-minors.

## 7. Applications Mentioned

1. **Martin Polynomial** unification with **Tutte Polynomial**
2. **Circle Graph Recognition** in polynomial time
3. **Graph Decomposition** (Cunningham's algorithm improved to $O(n^3)$)
4. Connection to **Jaeger's algebraic graph theory**

## 8. Connection to Rank-Width

Oum & Seymour (2005) later showed:
- **Rank-Width** = Branch-Width of the isotropic system associated to a graph
- The **cut-rank function** $\rho(X) = \text{rank}_{GF(2)}(A[X, \bar{X}])$ comes from projecting the isotropic system

**Why This Matters:**
- Local complementation invariance of rank-width follows naturally
- Vertex-minor monotonicity is built into the theory
- The "pivot" operation in our solver corresponds to changing the complete vector $A$

## 9. Algorithmic Relevance for Our Solver

| Feature | Isotropic System View | Matrix View |
|---------|----------------------|-------------|
| Cut-Rank | Projection dimension | $\text{rank}(A[X,Y])$ |
| Local Complement | Change of basis in $L$ | Row operations |
| Vertex Deletion | Elementary minor | Delete row/col |
| Pivot | Triangle of complete vectors | Gaussian elimination |

**For V1:** We use the matrix view (simpler).
**For V2 (Vertex-Minor Features):** Implement isotropic system operations.

## 10. Conclusion

Bouchet (1987) is the **algebraic foundation** of rank-width theory. Key takeaways:

1. **Isotropic systems unify** 4-regular graphs and binary matroids
2. **Local complementation** is the natural graph operation (= basis change)
3. **Circle graphs** are the "graphic" case
4. **Distance-hereditary graphs** = totally decomposable = linear rank-width ≤ 1
5. **Vertex-minors** = minors of the isotropic system

**Status:** ✅ Completed
