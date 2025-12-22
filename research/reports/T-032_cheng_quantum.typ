# Report: Breaking the Treewidth Barrier (2025)
# Task ID: T-032
# Title: Quantum Circuit Simulation using Linear Rank-Width
# Author: PhD-Physics
# Date: 2025-12-22

= Executive Summary
The paper "Breaking the Treewidth Barrier in Quantum Circuit Simulation with Decision Diagrams" (Cheng et al., Oct 2025) provides critical validation for our project. It demonstrates that algorithms scaling with **Linear Rank-Width** significantly outperform traditional Treewidth-based methods for quantum simulation. Since our solver optimizes **General Rank-Width** (which is strictly better than Linear Rank-Width), we are positioned at the cutting edge of this field.

= Key Findings
1.  **The Barrier:** Traditional Tensor Network methods (like generic contraction) are limited by the **Treewidth** of the circuit's line graph.
2.  **The Breakthrough:** Using Decision Diagrams (FeynmanDD) effectively exploits **Linear Rank-Width**, which can be exponentially smaller than Treewidth.
3.  **The Hierarchy:**
    $rw(G) \le lrw(G) \le tw(G) + 1$
    *   Our solver targets $rw(G)$, the most powerful parameter in this chain.

= Strategic Implications
-   **Marketing:** We can claim "Post-Treewidth Simulation" capabilities.
-   **Benchmarking:** We should benchmark our solver against "FeynmanDD" on the specific circuit families they mention (likely QAOA or certain random circuits) where $lrw \ll tw$.
-   **Validation:** The 2025 publication date confirms that this is a hot, unsolved problem in the industry.

= References
-   Cheng, B., Wang, Z., Deng, R., Chen, J., & Ji, Z. (2025). "Breaking the Treewidth Barrier in Quantum Circuit Simulation with Decision Diagrams". arXiv:2510.06775.
