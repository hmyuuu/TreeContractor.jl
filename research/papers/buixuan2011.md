# Analysis: Boolean-Width of Graphs (Bui-Xuan et al. 2011)

**Paper:** "Boolean-Width of Graphs"
**Authors:** Binh-Minh Bui-Xuan, Jan Arne Telle, Martin Vatshelle
**Year:** 2011 (Theoretical Computer Science)
**Task:** T-077
**Agent:** PhD-Theory

## 1. Definition
**Boolean-Width** is a variation of Rank-Width.
-   **Rank-Width:** Rank over GF(2) (linear dependence).
-   **Boolean-Width:** Uses the size of the set of "Unions of Neighborhoods".
-   Essentially, it measures the "Boolean Rank" rather than the "Linear Rank".

## 2. Comparison
-   $rank\text{-}width(G) \le boolean\text{-}width(G)$.
-   Boolean-width can be exponentially smaller than Rank-Width? No, actually $rw \le bw \le 2^{rw}$.
-   **Advantage:** For some problems (like Dominating Set), the runtime depends on $2^{bw}$ which can be better than $2^{rw^2}$ if $bw$ is small.

## 3. Algorithmics
-   Computing Boolean-Width is harder than Rank-Width.
-   However, if we *have* a decomposition, solving problems might be faster.
-   **Our Stance:** Stick to Rank-Width. It has a cleaner linear algebra definition (SVD, Matrix Rank) which allows for better heuristics (Spectral methods). Boolean-width is purely combinatorial and harder to optimize continuously.

## 4. Conclusion
We acknowledge Boolean-Width as a sibling parameter. Our `ParseTrees.jl` could technically support it by changing the algebra from `GF(2)` to `Boolean Lattice`, but we will focus on Rank-Width for V1 due to its superior "Calculus" (Linear Algebra).
