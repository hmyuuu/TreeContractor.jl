# Report: Boolean-width vs Rank-width
# Task ID: T-030
# Title: Alternative Width Parameters for Solver Optimization
# Author: PhD-Theory
# Date: 2025-12-22

= Executive Summary
We investigated **Boolean-width** as a potential alternative to Rank-width. While Boolean-width offers superior theoretical compression (logarithmic vs linear for some grid-like graphs), it lacks a practical approximation algorithm for finding the decomposition. Rank-width remains the optimal choice for our General Purpose Solver because the **Queyranne Algorithm ($O(n^3)$)** efficiently finds a good decomposition, which is the prerequisite for any optimization.

= Methodology
1.  **Source:** Analyzed "Boolean-width of graphs" (Bui-Xuan et al., 2011).
2.  **Comparison:** Evaluated computational tractability of *finding* vs *using* the decomposition.

= Findings
| Feature | Rank-Width | Boolean-Width |
| :--- | :--- | :--- |
| **Compression** | Good ($k$) | Excellent ($O(\log k)$ possible) |
| **Cut Function** | Submodular (GF(2) rank) | Not Submodular |
| **Finding Decomp** | **$O(n^3)$ (Queyranne)** | Hard / Heuristic only |
| **Solving Problem** | $O(2^{k^2} n)$ | $O(2^k n)$ |

= Conclusion
We will proceed with **Rank-Width** as the core architectural parameter. The ability to *find* the structure efficiently outweighs the theoretical gains of a "tighter" width that we cannot compute.

= References
-   Bui-Xuan, B.-M., Telle, J. A., & Vatshelle, M. (2011). "Boolean-width of graphs". Theoretical Computer Science.
