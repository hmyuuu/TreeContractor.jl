# Report: Implement Queyranne's Algorithm for Min-Rank Cut
# Task ID: T-016
# Title: Implement Queyranne's Algorithm for Min-Rank Cut
# Author: PhD-Algo
# Date: 2025-12-22

= Executive Summary
We successfully implemented Queyranne's Algorithm (1998) in Julia, capable of minimizing any symmetric submodular function. We validated it using a `MatrixRankFunction` over GF(2) for graph rank-width. The algorithm correctly identifies the minimum rank cut for Cycle ($C_4$) and Path ($P_3$) graphs.

= Methodology
1.  **Architecture:** Implemented `AbstractSymmetricSubmodularFunction` interface to decouple the algorithm from the specific rank function.
2.  **Algorithm:** Implemented the "Pendant Pair Identification" scheme, which runs in $O(n^3)$ time and generalizes Stoer-Wagner.
3.  **Verification:** Created `test/test_queyranne.jl` with unit tests for:
    -   $C_4$ Cycle (Rank 1 cut exists, separating $\{1,3\}$ from $\{2,4\}$).
    -   $P_3$ Path (Rank 1 cut).
    -   Disjoint Graph (Rank 0 cut).

= Findings
-   **Correctness:** The algorithm passes all logic tests.
-   **Theoretical Insight:** We rediscovered that for $C_4$, the set $\{1, 3\}$ (opposite vertices) has cut-rank 1 because their rows are identical (linearly dependent) in the adjacency matrix. This confirms the solver is finding non-trivial algebraic cuts that a simple geometric heuristic might miss.

= Next Steps
1.  Integrate `queyranne_min_cut` into the main `rank_width` recursive solver.
2.  Implement `WeightedRankFunction` (from T-022) to enable mixed-state optimization.

= References
-   Queyranne (1998). "Minimizing Symmetric Submodular Functions".
-   Source Code: `src/Queyranne.jl`
