# Analysis: Linear Time Optimization (Courcelle, Makowsky, Rotics 2000)

**Paper:** "Linear Time Solvable Optimization Problems on Graphs of Bounded Clique-Width"
**Authors:** Courcelle, Makowsky, Rotics (2000)
**Task:** T-029
**Agent:** PhD-Theory

## 1. The Meta-Theorem
The paper establishes a fundamental result for Clique-Width (and thus Rank-Width):
> Every graph optimization problem expressible in **Monadic Second-Order Logic without edge set quantification (MSO1)** can be solved in **linear time** $O(f(k) \cdot n)$ on graphs of clique-width $k$, provided a $k$-expression is given.

## 2. Logic Definitions
-   **MSO1:** Allows variables for vertices ($x \in V$) and sets of vertices ($X \subseteq V$). Predicates include $adj(x,y)$ and $x \in X$.
    -   *Examples:* 3-Coloring, Dominating Set, Maximum Cut, Vertex Cover.
-   **MSO2:** Adds variables for edges ($e \in E$) and sets of edges ($F \subseteq E$).
    -   *Examples:* Hamiltonian Cycle.
    -   *Note:* MSO2 is tractable on **Tree-Width** but **NOT** on Clique-Width/Rank-Width (e.g., Hamiltonian Cycle is NP-hard on cliques, which have rw=1).

## 3. Connection to Rank-Width
-   **Boundedness:** A class of graphs has bounded rank-width iff it has bounded clique-width.
-   **Conversion:** A rank-decomposition of width $k$ can be transformed into a clique-width $2^{k+1}$-expression.
-   **Complexity:**
    -   Finding the decomposition: $O(n^3)$ (using Oum's approximation or our Queyranne heuristic).
    -   Solving the problem: $O(n)$ (DP on the decomposition tree).
    -   **Total:** $O(n^3)$.

## 4. Implications for Solver
-   **Scope:** Our solver can theoretically handle any vertex-partitioning or vertex-subset problem (MSO1).
-   **Limitations:** It cannot efficiently solve edge-subset problems (like Hamiltonian Path) unless they can be reformulated into vertex problems (which is often impossible for dense graphs).
-   **Validation:** This justifies our focus on "MaxCut" (Ising Model) and "Vertex Coloring" as primary demos, while avoiding "TSP" (Hamiltonian).

## 5. Conclusion
Courcelle's theorem provides the **theoretical upper bound** of our solver's capabilities. It confirms that for $N=1000$ vertices, if the rank-width is low, the problem is solvable in seconds. The bottleneck is the constant factor $f(k)$ in the DP, which we optimize using tensor contraction techniques (as opposed to logical parsing).

= References
-   Courcelle, B., Makowsky, J. A., & Rotics, U. (2000). "Linear time solvable optimization problems on graphs of bounded clique-width". Theory of Computing Systems.
