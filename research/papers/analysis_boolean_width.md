# Analysis: Boolean-width (Bui-Xuan 2011)

**Paper:** "Boolean-width of graphs" (Bui-Xuan, Telle, Vatshelle 2011)
**Task:** T-030
**Agent:** PhD-Theory

## 1. Definition
Boolean-width measures the complexity of a cut by the number of distinct **unions of neighborhoods** across the cut.
-   **Rank-width:** Uses GF(2) sums (XOR).
-   **Boolean-width:** Uses Boolean sums (OR).

## 2. Comparison to Rank-Width
-   **Relation:** $\log_2 rw(G) \le boolw(G) \le rw(G)^2$ (roughly).
-   **Separation:** There exist graphs (Hsu-grids) where $boolw(G) \approx \log n$ but $rw(G) \approx n$.
-   **Implication:** Boolean-width can theoretically compress certain dense structures much better than Rank-width.

## 3. Algorithmic Trade-off
-   **Solving Problems:** If a decomposition of boolean-width $k$ is given, many problems (Independent Set, Dominating Set) can be solved in $O(n \cdot 2^{O(k)})$. This is often faster than rank-width based algorithms which might be $O(n \cdot 2^{k^2})$.
-   **Finding Decomposition:** This is the dealbreaker. There is no known cubic-time approximation algorithm for boolean-width comparable to Oum's/Queyranne's algorithm for rank-width. The cut function is not submodular in the same way.

## 4. Decision
-   **For V1:** Stick to **Rank-Width**. The existence of the $O(n^3)$ Queyranne algorithm is the critical enabler for a practical solver.
-   **For V2:** We could potentially use Rank-Decomposition as a heuristic for Boolean-Decomposition (since $boolw$ is bounded by $rw^2$), but optimize the DP dynamic programming state to use boolean sets instead of GF(2) subspaces if applicable.

= References
-   Bui-Xuan, B.-M., Telle, J. A., & Vatshelle, M. (2011). "Boolean-width of graphs". Theoretical Computer Science.
