# Report: Validate Implementation Plan for Queyranne Solver
# Task ID: T-024
# Title: Validate Implementation Plan for Queyranne Solver
# Author: PhD-Algo
# Date: 2025-12-22

= Executive Summary
We have validated the implementation plan for the Queyranne Solver. The core component will be an `AbstractSymmetricSubmodularFunction` interface, allowing us to swap between standard GF(2) Rank-Width and the newly proposed Weighted Rank-Width without changing the optimization logic.

= Methodology
1.  **Review:** Analyzed the existing `Queyranne.jl` stub.
2.  **Design:** Created a detailed API specification (`solver_api_design.md`).
3.  **Verification:** Confirmed that the "Pendant Pair" ordering rule is consistent with maximizing connectivity (generalizing Stoer-Wagner).

= Findings
== API Design
-   **Abstract Interface:** `AbstractSymmetricSubmodularFunction` is the key abstraction.
-   **Ordering Rule:** The correct rule for vertex selection is to **maximize** $f(W) + f(v) - f(W \cup v)$. This aligns with the intuition of finding the "most tightly coupled" vertex to the existing set.
-   **Weighted Support:** The design natively supports `WeightedRankFunction` by composition.

== Implementation Strategy
-   We will implement a `RestrictedFunction` wrapper to handle recursion on subsets of vertices without copying the full matrix.
-   The recursive solver will use Queyranne's algorithm to find the split at each node.

= Next Steps
1.  Unpause T-016 (Implement Queyranne).
2.  Implement the `MatrixRankFunction` and `RestrictedFunction` structs.
3.  Implement the `queyranne_min_cut` function following the API design.

= References
-   Queyranne (1998). "Minimizing Symmetric Submodular Functions".
-   `research/papers/solver_api_design.md`
