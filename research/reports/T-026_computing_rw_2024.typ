# Report: SOTA Rank-width Algorithms (2024)
# Task ID: T-026
# Title: Analysis of "Almost-linear time parameterized algorithm for rankwidth via dynamic rankwidth"
# Author: PhD-Algo
# Date: 2025-12-22

= Executive Summary
We investigated the state-of-the-art in Rank-Width computation, specifically the 2024 paper by Korhonen et al. The key finding is that while a near-linear time algorithm $O(n^{1+o(1)})$ is theoretically possible, it relies on extremely complex dynamic data structures (maintaining CMSO properties under dense updates). For our immediate engineering goals (V1 Solver), the $O(n^3)$ Queyranne algorithm remains the optimal trade-off between implementation complexity and performance.

= Methodology
1.  **Source:** Identified "Almost-linear time parameterized algorithm for rankwidth via dynamic rankwidth" (arXiv:2402.12364) as the correct reference for "Computing rank-width: Theory and practice".
2.  **Analysis:** Reviewed the abstract and core contributions regarding time complexity and dynamic updates.

= Findings
== The SOTA
-   **New Bound:** $O_k(n^{1+o(1)})$ for fixed $k$.
-   **Previous Best:** $O_k(n^2)$ (2022) and $O_k(n^3)$ (2017).
-   **Mechanism:** Maintains a rank-decomposition dynamically. When edges change, it locally updates the decomposition in polylogarithmic time.

== Implications for Solver V1
-   **Queyranne ($O(n^3)$):** Is robust, simpler to implement, and handles "weighted" variations naturally (as per T-022).
-   **Dynamic Approach:** Requires implementing a fully dynamic graph data structure with dense update support. This is an order of magnitude more engineering effort.

= Decision
-   **Stick to Queyranne:** For $N=1000$ (typical near-term quantum circuit scale), $N^3 \approx 10^9$ operations is acceptable (seconds/minutes).
-   **Future Path:** If we target $N=100,000+$, we must adopt the dynamic approach.

= References
-   Korhonen, Majewski, Nadara, Pilipczuk, Sokołowski. (2024). "Almost-linear time parameterized algorithm for rankwidth via dynamic rankwidth". arXiv:2402.12364.
