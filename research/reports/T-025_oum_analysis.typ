# Report: Rank-width Analysis (Oum 2017)
# Task ID: T-025
# Title: Analysis of "Rank-width: Algorithmic and structural results"
# Author: PhD-Theory
# Date: 2025-12-22

= Executive Summary
We analyzed Sang-il Oum's key survey on Rank-Width. The primary findings confirm that exact computation of Rank-Width is NP-hard, justifying our choice of heuristic solvers (Queyranne + Local Search). The survey also highlights the critical role of the submodular cut-rank function, which underpins all efficient algorithms in this domain.

= Methodology
1.  **Source:** Retrieved and analyzed "Rank-width: Algorithmic and structural results" (Oum 2017) via Zotero.
2.  **Analysis:** Extracted key theorems regarding hardness, approximations, and relations to other width parameters.

= Findings
== Hardness
-   Computing Rank-Width exactly is **NP-hard**.
-   Computing Linear Rank-Width is **NP-hard**.

== Algorithms
-   **Exact:** Fixed-parameter tractable algorithms exist ($O(n^3)$ for fixed $k$) but are complex (forbidden minors).
-   **Approximation:** Efficient approximations exist, often based on recursive submodular minimization.
-   **Our Approach:** The proposed strategy of "Recursive Queyranne (Step 1) + Local Search (Step 2)" aligns well with the literature's successful heuristics. Queyranne provides a strong initial decomposition (minimizing local cuts), and Local Search refines it.

== Relations
-   $rw(G) \le cw(G) \le 2^{rw(G)+1} - 1$.
-   Rank-width is Clifford-invariant (Vertex-Minor invariant), making it ideal for quantum state compression.

= Next Steps
-   Proceed with researching the 2024 paper "Computing rank-width: Theory and practice" (T-026) to see if recent SOTA advancements supersede Oum's 2017 methods.

= References
-   Oum, Sang-il. (2017). "Rank-width: Algorithmic and structural results". Discrete Applied Mathematics.
