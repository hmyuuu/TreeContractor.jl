# Analysis: Tight Lower Bounds for Rank-Width (Bergougnoux et al. 2023)

**Paper:** "Tight Lower Bounds for Problems Parameterized by Rank-Width"
**Authors:** Bergougnoux, Korhonen, Nederlof (2023)
**Task:** T-033
**Agent:** PhD-Theory

## 1. The Core Result
The paper proves that for problems like **Independent Set**, **Dominating Set**, and **Feedback Vertex Set**, there is no algorithm running in time $2^{o(k^2)} n^{O(1)}$ parameterized by rank-width $k$, unless the **Exponential Time Hypothesis (ETH)** fails.

## 2. Why $2^{k^2}$?
-   **Clique-Width ($cw$):** Can be up to $2^{k}$. Algorithms for $cw$ run in $2^{O(cw)}$.
-   **Rank-Width ($k$):** Substituting $cw \approx 2^k$ into $2^{cw}$ gives $2^{2^k}$.
-   **The Optimization:** Dynamic programming directly on rank-decomposition allows running in $2^{k^2}$.
    -   The state space size is determined by the number of equivalence classes of partial solutions across a cut.
    -   For rank-width $k$, the number of classes is typically $2^{k^2}$ (related to subspaces of $GF(2)^k$).
-   **The Lower Bound:** This paper confirms that this $2^{k^2}$ is not just an artifact of current techniques but a fundamental limit. You cannot reduce it to $2^{O(k)}$ or even $2^{o(k^2)}$.

## 3. Implications for Solver
-   **Performance Limit:** We should not promise "single exponential in $k$" (like $2^k$) for generic NP-hard problems. The correct scaling is **single exponential in $k^2$** (or $2^{O(k^2)}$).
-   **Marketing:** We can claim our solver is "Optimal under ETH" for this class of problems.
-   **Quantum Simulation Exception:** For quantum simulation, the cost is often $2^{O(k)}$ because the "state" is a vector of size $2^k$ (Schmidt rank). The $2^{k^2}$ bound applies to *counting/combinatorial* problems where we need to track subsets or complicated properties.
    -   *Correction:* Actually, for quantum, if Schmidt rank is $\chi \le 2^k$, cost is $\chi^3 \approx 2^{3k}$. So quantum sim is indeed $2^{O(k)}$.
    -   The $2^{k^2}$ applies to problems where the "information" passing through the cut is complex (like independent sets).

## 4. Conclusion
We have bounded the theoretical performance.
-   **Best Case (Quantum/XOR-SAT):** $2^{O(k)}$
-   **Worst Case (Independent Set/MaxCut):** $2^{O(k^2)}$
-   **Comparison:** Still vastly better than $2^{O(n)}$ for low rank-width graphs.

= References
-   Bergougnoux, B., Korhonen, T., & Nederlof, J. (2023). "Tight Lower Bounds for Problems Parameterized by Rank-Width". STACS 2023.
