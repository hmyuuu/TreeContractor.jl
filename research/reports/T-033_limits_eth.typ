# Report: Performance Limits of Rank-Width (ETH)
# Task ID: T-033
# Title: Tight Lower Bounds for Rank-Width Parameterized Algorithms
# Author: PhD-Theory
# Date: 2025-12-22

= Executive Summary
We investigated the theoretical lower bounds for solving problems parameterized by rank-width. The paper "Tight Lower Bounds for Problems Parameterized by Rank-Width" (Bergougnoux et al., 2023) establishes that for general NP-hard problems like Independent Set and MaxCut, the optimal running time is **$2^{\Theta(k^2)} n^{O(1)}$**, assuming the Exponential Time Hypothesis (ETH). This contrasts with Treewidth-based algorithms which usually scale as $2^{\Theta(k)}$.

= Analysis
== 1. The $k^2$ Factor
-   The rank-width $k$ over GF(2) implies that there are up to $2^{k^2}$ distinct equivalence classes of "behaviors" across a cut.
-   Unlike Treewidth, where the interface size is $k$ vertices (leading to $2^k$ states), Rank-width defines an algebraic interface.
-   **Exception:** For problems with algebraic structure (like Linear Algebra over GF(2), or Quantum Simulation with bounded Schmidt rank), the complexity can often be reduced to $2^{O(k)}$.

== 2. Implications for Solver V1
-   **Marketing:** We must be precise. "Exponentially faster than Treewidth" refers to the *parameter* $k$ being smaller than $tw$. However, the *function* $f(k)$ is steeper ($2^{k^2}$ vs $2^k$).
-   **Sweet Spot:** Our solver wins when $rw \ll \sqrt{tw}$.
    -   Example: Dense graphs, grids, algebraic graphs.
-   **Quantum Advantage:** For quantum circuits, the state space size is explicitly $2^{rw}$. Here, the complexity is $2^{O(rw)}$, not $2^{rw^2}$. This makes quantum simulation the **killer app** for our solver.

= Conclusion
The theoretical analysis confirms that while generic combinatorial optimization is expensive ($2^{k^2}$), **Quantum Circuit Simulation** remains highly efficient ($2^k$). This strongly supports our pivot towards the quantum market (Task T-032).

= References
-   Bergougnoux, B., Korhonen, T., & Nederlof, J. (2023). "Tight Lower Bounds for Problems Parameterized by Rank-Width". STACS 2023.
