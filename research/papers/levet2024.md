# Research Note: Canonizing Graphs of Bounded Rank-Width (Levet et al. 2024)

**Citation:**
Levet, M., Rombach, P., & Sieger, N. (2024). Canonizing Graphs of Bounded Rank-Width in Parallel via Weisfeiler-Leman. *SWAT 2024* / *arXiv:2306.17777*.

## 1. Group Meeting Summary
**Date:** 2025-12-22
**Participants:** Principal Investigator (PI), Theoretical Physicist (TP), Algorithm Engineer (AE)

**Discussion Log:**
*   **PI:** We have solvers for *properties* (MaxCut, contraction). What about *identity*? Can we tell if two tensor networks are the same?
*   **AE:** That's the Graph Isomorphism (GI) problem. For general graphs, it's quasi-polynomial (Babai). For bounded rank-width $k$, it was known to be Polynomial Time (Grohe & Schweitzer 2015).
*   **TP:** This paper (Levet 2024) improves that. It puts it in $TC^2$ (highly parallelizable).
*   **AE:** The key tool is the **Weisfeiler-Leman (WL)** algorithm. They show that $(6k+3)$-dimensional WL is sufficient to distinguish graphs of rank-width $k$.
*   **PI:** Does this help us build a better solver?
*   **AE:** Not directly for *contraction*, but for **Caching**.
    *   If we encounter a subgraph (tensor block), we can compute its "Canonical Label".
    *   If we see the same label again, we reuse the contraction result.
    *   For low rank-width, the label is efficient to compute.
*   **TP:** This is also "Symmetry Detection". If a tensor network has rotational symmetry, WL will find it.

**Decisions:**
1.  **Future Feature: Caching via WL**: We can implement a simplified 1-WL or 2-WL hashing for our `DynamicGraph` to detect repeated substructures.
2.  **Theoretical Guarantee**: We know that exact symmetry detection is tractable for our target graphs.

---

## 2. Deep Analysis

### 2.1 The Weisfeiler-Leman (WL) Dimension
*   **1-WL**: Color refinement (checking degrees, then neighbor colors).
*   **k-WL**: Colors $k$-tuples of vertices.
*   **Result**: To distinguish graphs of rank-width $k$, you need dimension $\approx 6k$.
*   **Implication**: For small $k$ (e.g., $k=2$ for Distance-Hereditary), low-dimensional WL is enough.

### 2.2 Parallelism ($TC^2$)
*   The algorithm runs in $O(\log n)$ rounds.
*   This suggests that **Distributed Contraction** strategies are viable. We can analyze the graph structure in parallel before deciding how to contract it.

### 2.3 Connection to Rank-Decomposition
*   The canonization algorithm *uses* the rank-decomposition tree.
*   It processes the tree bottom-up (like our `DPSolver`), computing signatures for each node.
*   This confirms our `ParseTrees.jl` approach is the correct foundation for structural analysis, not just optimization.

## 3. Unresearched Opportunities
*   **Spectral WL**: Can we combine WL colors with the *spectrum* of the adjacency matrix (GF(2) rank) to get a faster heuristic?
    *   Levet's result is for *exact* isomorphism.
    *   For heuristic caching, 1-WL + Rank might be "good enough".

## 4. Integration Plan
*   **Code**: No immediate action. The complexity of implementing $6k$-WL is high.
*   **Roadmap**: Add "Isomorphism Testing" to the feature wish list in `README.md`.

