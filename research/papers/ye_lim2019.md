# Analysis: Tensor Network Ranks (Ye & Lim 2019)

**Paper:** "Tensor Network Ranks"
**Authors:** Ke Ye, Lek-Heng Lim
**Year:** 2019 (arXiv)
**Task:** T-075
**Agent:** PhD-Physics

## 1. The Concept: Graph-Based Rank
Standard Tensor Rank (CP-rank) and Multilinear Rank (Tucker rank) are specific cases of a general concept: **$G$-Rank**.
-   Given any graph $G$, one can define a tensor decomposition based on $G$.
-   **MPS (Matrix Product State):** Corresponds to $G = Path$.
-   **TTN (Tree Tensor Network):** Corresponds to $G = Tree$.
-   **PEPS:** Corresponds to $G = Grid$.

## 2. The Main Result
-   **Separation:** There are tensors that have low $G$-rank but exponentially high $H$-rank for different graphs $G, H$.
-   **Universality:** Almost every tensor has $G$-rank exponentially lower than its full rank.

## 3. Connection to Rank-Width
This paper generalizes the concept of Rank-Width from graphs (matrices) to Tensors.
-   **Graph Rank-Width:** Finds the best *Tree* structure ($G=Tree$) to decompose the adjacency matrix.
-   **Tensor Network Rank:** Finds the best *Graph* structure to decompose a Tensor.
-   **Implication:** If we view a Graph State as a Tensor, minimizing the "bond dimension" of a TTN representation is *exactly* equivalent to minimizing the Rank-Width of the graph.

## 4. Conclusion
This confirms the Physics perspective: **Rank-Width $\equiv$ Minimum Bond Dimension of a Tree Tensor Network**.
It validates our Quantum Simulation roadmap: improving the solver improves the compression of quantum states.
