# Analysis: Rank-width (Oum 2017 Survey)

**Paper:** "Rank-width: Algorithmic and structural results" (Oum 2017)
**Task:** T-025

## 1. Key Definitions
- **Rank-width (rw(G)):** Min-width over all rank-decompositions.
- **Cut-rank function $\rho_G(X)$:** Rank of adjacency matrix cut $M[X, V \setminus X]$ over GF(2).
- **Submodularity:** $\rho_G(X) + \rho_G(Y) \ge \rho_G(X \cup Y) + \rho_G(X \cap Y)$. This is the *critical property* that enables efficient algorithms.

## 2. Hardness Results
- Computing exact rank-width is **NP-hard**.
- Computing linear rank-width is **NP-hard**.
- **Implication:** Our solver must rely on approximations or heuristics (like Local Search) for large graphs, or accept exponential time for exactness.

## 3. Algorithms
- **Exact (Fixed k):** $O(n^3)$ decision algorithm exists (Courcelle & Oum 2007, Hlineny & Oum 2008), but uses forbidden vertex-minors (too complex for V1).
- **Approximation (Oum & Seymour 2006):**
    - Finds decomposition of width $\le 3k+1$ in $O(8^k n^4)$.
    - Improved by Oum (2008) to $O(8^k n^4)$ and $O(n^3)$.
- **Generic XP Algorithm (Oum & Seymour 2006):**
    - $O(n^{8k+12})$ for exact width $k$. Too slow.
- **Heuristic (Our approach):**
    - Queyranne's Algorithm (Step 1) is $O(n^3)$ and finds the *exact min-cut* for a specific split.
    - Recursively applying Queyranne is a greedy strategy. It doesn't guarantee global optimality but works well in practice (and is the basis for Oum's approximation logic).

## 4. Connection to Clique-width
- $rw(G) \le cw(G) \le 2^{rw(G)+1} - 1$.
- **Why it matters:** Rank-width is "better behaved" (submodular) than clique-width, making it easier to compute. We compute RW, then simulate CW if needed.

## 5. Other Widths
- **Boolean-width:** $log rw(G) \le boolw(G) \le rw(G)^2$.
- **Linear Rank-width:** NP-hard.

## 6. Takeaways for Solver
1.  **Submodularity is King:** The entire algorithmic efficiency rests on $\rho_G$ being submodular. Our implementation of Queyranne is therefore theoretically sound.
2.  **Approximation is Standard:** Since exact RW is NP-hard, our "Queyranne + Local Search" strategy is a valid heuristic approach.
3.  **Validation:** We should test against known results (e.g., grids have RW $n-1$).
