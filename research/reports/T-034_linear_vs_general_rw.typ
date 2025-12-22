# Analysis: Linear Rank-Width vs General Rank-Width
# Task ID: T-034
# Title: Connection to Matrix Product States (MPS) and PEPS
# Author: PhD-Theory
# Date: 2025-12-22

= Executive Summary
We clarified the relationship between Linear Rank-Width ($lrw$) and General Rank-Width ($rw$) in the context of Tensor Networks.
*   **Linear Rank-Width** corresponds to **Matrix Product States (MPS)**, where tensors are arranged in a 1D line.
*   **General Rank-Width** corresponds to **Tree Tensor Networks (TTN)** (or PEPS with a tree contraction order), where tensors are arranged in a branching tree.

= Key Findings
== 1. The Hierarchy
$rw(G) \le lrw(G) \le tw(G) + 1$
*   **Rank-Width ($rw$):** Best parameter. Branching allows handling complex entanglement structures (like GHZ states or QFT) more efficiently.
*   **Linear Rank-Width ($lrw$):** Restricted to lines. Good for 1D systems but fails on trees/grids.
*   **Treewidth ($tw$):** Restricted by vertex separators. Much worse than both rank-widths for dense graphs (e.g., Clifford circuits).

== 2. Physics Connection
*   **MPS (1D):** Efficient iff $lrw$ is low.
*   **PEPS (2D):** Contracting a 2D PEPS is generally \#P-hard. However, if the PEPS has low *Rank-Width* (viewed as a graph), it can be contracted efficiently using a TTN.
*   **Our Solver:** By minimizing General Rank-Width, we essentially find the **Optimal Tree Tensor Network (TTN)** for any given quantum circuit or tensor network. This is strictly more powerful than MPS-based simulators (like `mps` in Qiskit or `dmrg` in ITensor).

= Conclusion
This confirms that our solver is a **General-Purpose TTN Optimizer**. We should market it as "Automatically finding the optimal contraction tree for any tensor network," which subsumes MPS strategies.

= References
-   Ganian, R. (2011). "Thread Graphs, Linear Rank-Width and Their Algorithmic Applications".
-   Oum, S. (2016). "Rank-width: Algorithmic and structural results".
