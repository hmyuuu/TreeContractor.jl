# Report: Linear Time Optimization (Courcelle's Theorem)
# Task ID: T-029
# Title: The Meta-Theorem for Rank-Width and MSO Logic
# Author: PhD-Theory
# Date: 2025-12-22

= Executive Summary
We analyzed the foundational paper by Courcelle, Makowsky, and Rotics (2000), which establishes that any graph optimization problem expressible in **Monadic Second-Order Logic (MSO1)** can be solved in linear time on graphs of bounded clique-width (and thus rank-width). This result provides the theoretical guarantee for our solver: as long as the problem involves vertex sets (like Coloring, MaxCut) and the graph has low rank-width, an efficient solution exists.

= Methodology
1.  **Source:** Analyzed "Linear Time Solvable Optimization Problems on Graphs of Bounded Clique-Width" (2000).
2.  **Analysis:** Mapped the logic definitions (MSO1 vs MSO2) to practical problem classes.

= Findings
== 1. The Meta-Theorem
-   **Theorem:** If $rw(G) \le k$, then checking $\phi$ (where $\phi \in \text{MSO}_1$) takes $O(f(k) \cdot n)$.
-   **Scope:** Includes MaxCut, Independent Set, Dominating Set, 3-Coloring.
-   **Exclusion:** Does *not* include Hamiltonian Cycle or other edge-subset problems (MSO2), which require Tree-Width.

== 2. Practical Implications
-   **Preprocessing:** The $O(n^3)$ cost of finding the decomposition (Queyranne) dominates the $O(n)$ solving time for large $N$, but for hard problems (NP-hard), this is a massive win over $2^N$.
-   **Architecture:** The "Solver" should be viewed as a two-stage engine:
    1.  **Compress:** Find the Rank-Decomposition ($O(n^3)$).
    2.  **Execute:** Run Dynamic Programming on the decomposition tree ($O(n)$).

= Conclusion
We have verified the theoretical "Speed Limit" of our approach. We can claim "Polynomial Time for Bounded Rank-Width" for a vast class of NP-hard problems.

= References
-   Courcelle, B., Makowsky, J. A., & Rotics, U. (2000). "Linear time solvable optimization problems on graphs of bounded clique-width". Theory of Computing Systems.
