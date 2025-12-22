# Analysis: SAT and MAX-SAT on Bounded Rank-Width (Ganian et al. 2010)

**Paper:** "Better Algorithms for Satisfiability Problems for Formulas of Bounded Rank-Width"
**Authors:** Robert Ganian, Petr Hliněný, Jan Obdržálek
**Year:** 2010 (arXiv/CSL)
**Task:** T-057
**Agent:** PhD-Theory

## 1. The Core Result
This paper proves that **#SAT** (Model Counting) and **MAX-SAT** are Fixed-Parameter Tractable (FPT) with respect to the **Rank-Width of the Incidence Graph** of the formula.
-   **Complexity:** $O(n^3 + 2^{k^2} \cdot n)$. (Note: This is single-exponential in $n$, but the parameter dependency is $2^{k^2}$, which is better than the $2^{2^k}$ often associated with Clique-Width).
-   **Comparison:** Previous results using Clique-Width had a double-exponential dependency. Rank-Width offers a tighter bound.

## 2. Incidence Graph Representation
For a CNF formula $F$:
-   Construct a bipartite graph $I(F)$ with partition $(V_{var}, V_{clause})$.
-   Edge $(v, c)$ exists if variable $v$ appears in clause $c$.
-   **Rank-Width of Formula:** Defined as $rw(I(F))$.

## 3. Algorithm Details
The algorithm uses **Dynamic Programming** on the rank-decomposition tree.
-   **State:** For a cut $(A, B)$, we need to track the partial truth assignments.
-   ** Equivalence:** Two assignments on $A \cap V_{var}$ are equivalent if they satisfy the same set of clauses in $B \cap V_{clause}$ and "behave the same" regarding future satisfiability.
-   **Matrix View:** The adjacency matrix over GF(2) captures the "interaction".
    -   Rows: Variables in A.
    -   Columns: Clauses in B.
    -   Rank $k$: There are only $2^k$ distinct "interaction patterns".
-   **DP Table Size:** $2^k$ (roughly).

## 4. Implications for Our Solver
1.  **Scope Expansion:** Our solver can solve **SAT** and **#SAT** instances that have low rank-width incidence graphs.
    -   This is significant because industrial SAT instances often have structure.
2.  **Implementation:**
    -   Input: CNF file (`.cnf`).
    -   Conversion: `CNF -> IncidenceGraph`.
    -   Solver: Existing `DPSolver.jl` can be adapted. The "Parse Tree" logic we implemented for MaxCut is very similar (sum-product over GF(2) cuts).
    -   **Constraint:** The current `DPSolver` handles vertex-states (Ising). SAT mixes vertex-states (variables) and edge-constraints (clauses). It requires a bipartite adaptation.

## 5. Verification
The paper confirms that $rw \le cw \le 2^{rw+1}$.
Since SAT is FPT on Clique-Width, it is FPT on Rank-Width.
The "Single Exponential" claim is the key selling point.

## 6. Conclusion
Ganian et al. (2010) provide the theoretical foundation for adding a "SAT Solver" mode to our tool. This would compete with solvers like `sharpSAT` on specific structured instances.
