# Research Note: Tight Lower Bounds for Rank-Width (Bergougnoux 2023)

**Citation:**
Bergougnoux, B., Korhonen, T., & Nederlof, J. (2023). Tight Lower Bounds for Problems Parameterized by Rank-Width. *STACS 2023*.

## 1. Group Meeting Summary
**Date:** 2025-12-22
**Participants:** Principal Investigator (PI), Theoretical Physicist (TP), Algorithm Engineer (AE)

**Discussion Log:**
*   **PI:** We have a lower bound of $2^{o(k^2)}$ for Independent Set. Does this invalidate our goal of efficient solvers?
*   **AE:** No, it sets the speed limit. We previously assumed $2^{O(k)}$ might be possible because Clique-Width algorithms are $2^{O(cw)}$ and sometimes $cw \sim k$. But this paper proves that for Rank-Width $k$, the worst case is indeed $2^{\Theta(k^2)}$.
*   **TP:** Wait, for Tensor Networks, the contraction cost is $O(\chi^3)$ where $\chi = 2^k$. That's $2^{3k}$, which is $2^{O(k)}$. Why the discrepancy?
*   **AE:** Excellent point. The $2^{k^2}$ bound applies to *combinatorial* problems (Independent Set, Dominating Set) where the dynamic programming state must encode a *subset* of the solution space. The number of subspaces in $GF(2)^k$ is roughly $2^{k^2/4}$.
*   **TP:** Ah, so for Quantum Simulation, we are just propagating a *linear* map (a vector), not a set of potential subsets. The "state" is simpler.
*   **PI:** So we have a dichotomy:
    1.  **Algebraic Problems** (Quantum Sim, XOR-SAT, Linear Algebra): $2^{O(k)}$.
    2.  **Combinatorial Problems** (Independent Set, Dominating Set): $2^{O(k^2)}$.
*   **PI:** We must document this clearly. Also, can we use their hardness reduction to generate test cases?
*   **AE:** Yes, they likely use a "Grid Tiling" or "L-Reduction". We should extract that construction to create "Hard Benchmark Graphs" that force the solver into worst-case behavior.

**Decisions:**
1.  **Adopt $2^{O(k^2)}$ as the standard complexity warning** for our general-purpose solver.
2.  **Highlight the "Algebraic Advantage"**: Emphasize that our Quantum Solver (T-032) beats the combinatorial lower bound because of the problem structure.

---

## 2. Deep Analysis of the Paper

### 2.1 The Lower Bound Construction
The authors use the **Exponential Time Hypothesis (ETH)**.
*   They reduce from **3-Coloring** or **3-SAT** on graphs with $n$ vertices.
*   They construct a graph $G'$ with rank-width $k \approx \sqrt{n}$.
*   If we could solve Independent Set on $G'$ in $2^{o(k^2)} = 2^{o(n)}$, we would break ETH (which says 3-SAT requires $2^{\Omega(n)}$).

### 2.2 Why $k^2$?
The key insight is the number of **Canonical Equivalence Classes**.
*   For a cut $(A, B)$ with rank $k$ over $GF(2)$:
    *   Two partial solutions $S_A, S'_A \subseteq A$ are equivalent if they restrict the valid extensions in $B$ in the same way.
    *   The "restriction" is defined by the adjacency matrix cut $M_{AB}$.
    *   The number of distinct restrictions corresponds to the number of subspaces or specific linear algebraic structures.
    *   Counting the number of linear mappings or subspaces leads to $q^{k^2}$ terms (Gaussian Binomial Coefficients).

### 2.3 Optimal Algorithms
The paper confirms that existing algorithms (like those by Bui-Xuan, Telle, Vatshelle 2010) running in $2^{O(k^2)}$ are **optimal**.
*   This validates our decision *not* to hunt for a $2^{O(k)}$ algorithm for Independent Set. It doesn't exist.

## 3. Unresearched Sections / Opportunities
*   **Specific Hard Graphs**: The paper details the construction of the hard instances. We have not yet implemented a generator for these.
    *   *Action*: Create a generator `generate_eth_hard_graph(k)` that produces a graph with rank-width $k$ where the DP table size is maximized.
*   **Kernelization**: The paper discusses parameterized complexity. Is there a polynomial kernel? (Likely not for width parameters, but worth checking if they mention pre-processing).

## 4. Integration Plan
*   **Documentation**: Update `research/README.md` with the "Complexity Landscape" table.
*   **Code**: No immediate code change to the solver logic, but we should add a comment in `DPSolver.jl` explaining the table size $2^{k^2}$.

