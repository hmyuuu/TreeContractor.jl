# Report: Investigate Weighted Rank-Width for Mixed States
# Task ID: T-022
# Title: Investigate Weighted Rank-Width for Mixed States
# Author: PhD-Theory
# Date: 2025-12-22

= Executive Summary
This task investigated the theoretical feasibility of adapting Rank-Width to handle mixed quantum states (Clifford vs Non-Clifford resources). We confirmed that a hybrid objective function combining Matrix Rank and Edge Weights is **symmetric submodular**, allowing the use of Queyranne's Algorithm for efficient minimization.

= Methodology
1.  **Search:** Zotero and Web Search for "weighted rank-width" and "submodular function".
2.  **Analysis:** Mathematical verification of the submodularity of $f(S) = \text{rank}(S) + w(S)$.
3.  **Synthesis:** Defined a hybrid cost function for the solver.

= Findings
== Submodularity
The function $g(S) = \text{rank}_{GF(2)}(M_{A,B}) + \lambda \cdot \text{CutWeight}(A, B)$ is symmetric submodular.
-   **Rank:** Submodular (Standard result).
-   **CutWeight:** Submodular (Standard Graph Cut).
-   **Sum:** Submodular.

== Algorithm Adaptation
No major changes are needed for `Queyranne.jl`. The algorithm minimizes *any* symmetric submodular function provided as an oracle. We simply need to implement the oracle to return the weighted sum.

= Next Steps
1.  Implement `weighted_cut_rank` function in Julia.
2.  Update Queyranne implementation to accept a generic `f`.

= References
-   Raz, Orit E.; Wigderson, Avi. (2019). "Subspace arrangements...".
-   TheoremDep. "Matroid: weighted rank is submodular".
