# Rank-Width Solver Research

This repository contains the research and implementation of a high-performance **Rank-Width Solver** in Julia.

## 🚀 Key Features

*   **Rank-Width Calculation**: Computes the rank-decomposition of a graph over GF(2).
*   **Linear Rank-Width**: Optimized solver for Path/Caterpillar decompositions (essential for Quantum Circuit Simulation).
*   **Dynamic Maintenance**: Supports incremental graph updates (`add_edge!`) while maintaining the decomposition.
*   **MaxCut Solver**: A Dynamic Programming solver that runs on the rank-decomposition.

## 📂 Directory Structure

*   `code/RankWidthAlgorithms.jl`: The main Julia package.
    *   `src/`: Source code.
        *   `RankWidthAlgorithms.jl`: Main entry point.
        *   `LinearRankWidth.jl`: Linear/Path optimization.
        *   `DynamicRankWidth.jl`: Incremental engine.
        *   `DPSolver.jl`: MaxCut solver.
*   `papers/`: Analyzed literature (Korhonen 2024, Fomin 2021, Cheng 2025).
*   `reports/`: Research reports (including `final_report.typ`).
*   `demo/`: Usage examples.

## 📊 Complexity Landscape

We distinguish between two types of problems solvable on Rank-Decompositions (Bergougnoux et al., 2023):

| Problem Type | Complexity | Example | Reason |
| :--- | :--- | :--- | :--- |
| **Algebraic** | $2^{O(k)} \cdot n^{O(1)}$ | **Quantum Simulation**, XOR-SAT, Linear Algebra | State is a vector/subspace. Information is "linear". |
| **Combinatorial** | $2^{\Theta(k^2)} \cdot n^{O(1)}$ | **Independent Set**, Dominating Set, MaxCut | State is a subset. Information is "complex" ($2^{k^2}$ subspaces). |

*   **Note**: Our solver is optimized for the Algebraic case (Quantum Sim), but supports Combinatorial problems within the theoretical limits.
*   **ETH Limit**: The $2^{\Theta(k^2)}$ bound is tight under the Exponential Time Hypothesis.
*   **Exception (Positive Bias)**: If the tensor network has non-negative entries with positive bias, approximate contraction is possible in quasi-polynomial time $n^{O(\log n)}$, even for high rank-width (Jiang et al., 2024).
*   **Canonization**: Graph Isomorphism for rank-width $k$ is in $TC^2$ (Levet et al., 2024). This allows efficient caching of sub-results by canonical labeling.

## 🛠️ Usage

### 1. Installation
The code is a local Julia package.
```julia
using Pkg
Pkg.activate("code/RankWidthAlgorithms.jl")
using RankWidthAlgorithms
```

### 2. Computing Rank-Width (TTNS Optimizer)
This corresponds to optimizing the **Tree Tensor Network State (TTNS)** geometry (Ye & Lim, 2019).
```julia
using LinearAlgebra
# Create a random graph
n = 10
adj = rand(0:1, n, n)
adj = Symmetric(adj)
adj[diagind(adj)] .= 0

# Compute Decomposition
rd = rank_width(adj)
println("Rank-Width: $(rd.width)")
```

### 3. Linear Rank-Width (MPS Optimizer)
This corresponds to optimizing the **Matrix Product State (MPS)** or **Tensor Train (TT)** geometry.
Essential for Quantum Circuit Simulation (Cheng et al., 2025).
```julia
using RankWidthAlgorithms.LinearRankWidth

# Optimize linear ordering
decomp = solve_linear_rank_width(adj)
println("Linear Rank-Width: $(decomp.width)")
println("Ordering: $(decomp.ordering)")
```

### 4. Dynamic Graph
```julia
using RankWidthAlgorithms.DynamicRankWidth

dg = DynamicGraph(10)
add_edge!(dg, 1, 2)
add_edge!(dg, 2, 3)
println("Current Width: $(dg.decomposition.width)")
```

## 📚 References
See `research/reports/final_report.typ` for the complete academic report.
