# Analysis: Tensor Cross Interpolation (Nuñez Fernández et al. 2025)

**Paper:** "Learning tensor networks with tensor cross interpolation: New algorithms and libraries"
**Authors:** Yuriel Núñez Fernández, Marc K. Ritter, et al.
**Year:** 2025 (SciPost Physics)
**Task:** T-081
**Agent:** PhD-Algo

## 1. The Core Algorithm: TCI
**Tensor Cross Interpolation (TCI)** is a "black-box" algorithm that learns a Matrix Product State (MPS) representation of a high-dimensional tensor (or function) by querying only a few of its entries.
-   **Input:** A function $f(i_1, \dots, i_d)$ that can be evaluated at any index.
-   **Output:** An MPS approximation of $f$ with low bond dimension.
-   **Mechanism:** It generalizes **Adaptive Cross Approximation (ACA)** (used for matrices) to Tensor Trains.
    -   It builds the MPS site-by-site (sweeping).
    -   It selects "Pivots" (indices) that maximize the interpolation error.
    -   It uses **MaxVol** or **Rank-Revealing LU (rrLU)** to find good pivots.

## 2. Comparison to Rank-Width Solver
| Feature | TCI (This Paper) | Our Rank-Width Solver |
| :--- | :--- | :--- |
| **Target Structure** | Matrix Product State (Linear / 1D) | Rank-Decomposition (Tree / General) |
| **Input** | Function Oracle (Implicit Tensor) | Adjacency Matrix (Explicit Graph) |
| **Method** | Interpolation / Sampling | Decomposition / Partitioning |
| **Objective** | Approximation (Low Error) | Exact/Heuristic Width (Low Rank) |
| **Field** | GF(R) or $\mathbb{C}$ (Float) | GF(2) (Binary) |

## 3. Synergy and differentiation
-   **Differentiation:** TCI is strictly for **Linear** layouts (MPS). It cannot naturally find a "star" or "tree" structure if the underlying data suggests it (e.g., a tree-shaped molecule). Our solver handles arbitrary topologies.
-   **Synergy:**
    -   **Linear Mode:** For our "Linear Rank-Width" mode (T-041), TCI is a state-of-the-art competitor.
    -   **Quantics:** TCI's ability to handle "Quantics" (bit-level) tensors suggests we could use our solver on "Quantics Graphs" (graphs defined by bit-patterns) to find non-linear bit orderings.

## 4. `TensorCrossInterpolation.jl`
This is a high-quality Julia library.
-   **Action:** We should **not** reimplement TCI. We should **wrap** it or **benchmark against** it.
-   **Benchmark Idea:** Generate a graph with known low *Linear* Rank-Width (e.g., a Caterpillar). Convert its adjacency matrix to a function $A(i, j)$. Feed it to TCI. See if TCI recovers the rank.
    -   *Challenge:* TCI works on Float/Complex fields. Rank-Width is GF(2). Rank over $\mathbb{R}$ is $\ge$ Rank over GF(2). So TCI gives an *upper bound* on the linear rank-width.

## 5. Conclusion
A crucial "Neighbor" technology. It solves the "Linear Rank-Width over $\mathbb{R}$" problem efficiently using sampling. Our niche remains "General Rank-Width over GF(2)".
