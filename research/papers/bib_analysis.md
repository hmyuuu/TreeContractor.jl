# Bibliography Analysis & Classification

**Status:** In Progress
**Date:** 2025-12-22
**Source:** `research/papers/ref.bib`

## 1. Already Covered
- **Oum (Various):** Rank-width foundations (T-025).
- **Ganian (2010):** #SAT/MAX-SAT (T-028).
- **Courcelle (2000/2007):** Logic & Meta-theorems (T-029).
- **Bui-Xuan (2011):** Boolean-width (T-030).
- **Korhonen (2024):** SOTA Algorithms (T-026).

## 2. High Priority: Quantum & Tensor Networks
*These papers directly support the "Quantum Solver" use case.*

*   **[CRITICAL] Cheng et al. (2025):** "Breaking the Treewidth Barrier in Quantum Circuit Simulation with Decision Diagrams".
    *   *Relevance:* Explicitly argues for Linear Rank-Width over Treewidth for quantum sim.
    *   *Action:* Detailed analysis.
*   **Jiang et al. (2024):** "Positive Bias Makes Tensor-Network Contraction Tractable".
    *   *Relevance:* Sign structure vs Rank-width.
*   **Ye & Lim (2019):** "Tensor Network Ranks".
    *   *Relevance:* Theoretical bridge between graph ranks and tensor ranks.

## 3. Medium Priority: Complexity Limits
*These papers define the theoretical speed limits.*

*   **Bergougnoux et al. (2023):** "Tight Lower Bounds for Problems Parameterized by Rank-Width".
    *   *Relevance:* Establishes ETH lower bounds (likely $2^{k^2}$ is optimal?).
*   **Levet et al. (2024):** "Canonizing Graphs of Bounded Rank-Width".
    *   *Relevance:* Isomorphism testing and parallel algorithms.

## 4. Low Priority: Linear Rank-Width & Matroids
*Specific structural variations, less critical for the general solver V1.*

*   **Adler, Kanté, Kwon (2017):** Linear Rank-Width on Distance-Hereditary graphs.
*   **Hliněný (2018):** Matroid Path-width.
*   **Kashyap (2007):** Matroid Path-width & Coding Trellis.

## 5. Proposed Research Tasks
1.  **T-032 (Quantum):** Research Cheng (2025) & Jiang (2024) to solidify the "Quantum Advantage" claim.
2.  **T-033 (Limits):** Research Bergougnoux (2023) to confirm we can't do better than single-exponential.
3.  **T-034 (Linear):** Brief overview of Linear Rank-Width (MPS vs PEPS connection).
