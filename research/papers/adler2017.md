# Linear Rank-Width of Distance-Hereditary Graphs (Adler et al., 2017)

**Citation**: Adler, I., Kanté, M. M., & Kwon, O. (2017). *Linear Rank-Width of Distance-Hereditary Graphs I. A Polynomial-Time Algorithm*. Algorithmica, 78(1), 342-377.
**Status**: [Deep Research in Progress]
**Tags**: #linear-rank-width #distance-hereditary #algorithm #polynomial-time

## 1. Paper Overview
**Core Result**: An algorithm to compute the *exact* Linear Rank-Width (LRW) of a Distance-Hereditary (DH) graph in time $O(n^2 \log^2 n)$.
**Key Tool**: **Canonical Split Decomposition**. DH graphs are exactly the graphs of rank-width 1. Their split decomposition consists of bags that are either *Stars* or *Cliques*.
**Relevance**: This paper provides the *exact* solver for the class of graphs most relevant to Quantum Simulation (DH graphs appear frequently in stabilizer formalism and graph states). My current heuristic solver is good, but this is *exact and fast*.

## 2. Deep Dive: The Algorithm

### 2.1. Canonical Split Decomposition
*   A DH graph $G$ can be decomposed into a tree of bags.
*   Each bag is either a **Star** ($K_{1,m}$) or a **Clique** ($K_m$).
*   The connections between bags are via "marked edges".
*   This decomposition is unique (canonical).

### 2.2. Characterization of LRW
The paper proves that for DH graphs, LRW is determined by the "limbs" of the split decomposition.
*   **Limbs**: Substructures attached to the central spine of the decomposition.
*   The algorithm works by:
    1.  Computing the Canonical Split Decomposition (linear time).
    2.  Computing "Canonical Limbs".
    3.  Using dynamic programming (or a recursive labeling scheme) on the decomposition tree to ﬁnd the optimal linearization.

### 2.3. The "Limb" Concept
*   A "Limb" is essentially a vertex-minor of the original graph.
*   The complexity comes from handling the "marked vertices" (connectors) correctly.
*   They define a value `lrw(L)` for each limb $L$.
*   The combination rules allow computing `lrw(Parent)` from `lrw(Children)`.

## 3. Implementation Feasibility
The algorithm is complex ($O(n^2 \log^2 n)$ implies sophisticated data structures).
However, for our `LinearRankWidth.jl` module, we can adopt a **Simplified Strategy**:
1.  **Split Decomposition**: Implement a simple split decomposition (or recognize DH graphs).
2.  **Tree Traversal**: If the graph is DH, traverse the split tree.
3.  **Linearization**: Linearize each bag (Star/Clique) and concatenate.
    *   Star: Center first/last.
    *   Clique: Any order.

Wait, simply linearizing bags is not enough. The *interleaving* of vertices from different bags matters.
The paper says: "It is non-trivial to relate substructures... We introduce a notion of limbs."

**Crucial Insight for Heuristic Solver**:
Even if we don't implement the full exact algorithm, the **Split Decomposition** is the right structure to optimize over.
Instead of optimizing a global permutation of $V$, we should:
1.  Decompose $G$ into bags.
2.  Optimize the ordering of bags (Tree Linearization).
3.  Optimize the ordering within bags.

This suggests that for Quantum Circuit Simulation (where structure is often hierarchical), a **Split-Decomposition-guided** solver would be superior to a flat Local Search.

## 4. Key Definitions extracted
*   **Distance-Hereditary**: Rank-width $\le 1$.
*   **Split**: Partition $(X, Y)$ such that $\text{rank}(X, Y) = 1$.
*   **Split Decomposition**: A tree where edges correspond to splits.

## 5. Action Items
1.  **Update `LinearRankWidth.jl`**: Add a note or a TODO about Split Decomposition.
2.  **Benchmark**: If we encounter DH graphs (e.g. from specific quantum states), our current heuristic might struggle with the "spine".
3.  **Research**: Check if `Korhonen 2024` supersedes this. (Korhonen is for general graphs $O(n)$, this is specific for DH $O(n^2)$ but exact).

## 6. References
*   Adler, I., Kanté, M. M., & Kwon, O. (2017).
