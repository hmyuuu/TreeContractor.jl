# Analysis: Isomorphism Testing for Graphs of Bounded Rank Width (Grohe & Schweitzer 2015)

**Paper:** "Isomorphism Testing for Graphs of Bounded Rank Width"
**Authors:** Martin Grohe, Pascal Schweitzer
**Year:** 2015 (FOCS)
**Task:** T-068
**Agent:** PhD-Theory

## 1. The Result
This paper presents the first **Polynomial Time Algorithm** for Graph Isomorphism (GI) on graphs of bounded rank-width.
-   **Complexity:** $n^{O(1)}$ (where the exponent depends on $k$).
-   **Context:** GI for bounded Tree-Width was known (Bodlaender 1990). Rank-Width generalizes Tree-Width, so this is a significant generalization.

## 2. The Method: Canonization via Coset Intersection
Unlike Levet et al. (2024) which uses Weisfeiler-Leman (WL) and targets parallel complexity ($TC^2$), this paper uses group-theoretic techniques.
-   **Decomposition:** It uses the rank-decomposition tree.
-   **Automorphisms:** It computes the automorphism group of the graph by processing the tree bottom-up.
-   **Cosets:** The "interaction" between parts of the decomposition is handled by computing intersections of cosets of the symmetric group.

## 3. Comparison to Levet 2024
-   **Grohe 2015:** "Sequential" polynomial time. Uses heavy group theory machinery (Luks' algorithm styles).
-   **Levet 2024:** "Parallel" efficient ($TC^2$). Uses combinatorial refinement (WL).
-   **Winner:** Levet 2024 is the "modern" and "better" result because it implies the polynomial time result and places it in a much lower complexity class.

## 4. Relevance
For our project, we don't need to implement Grohe's complex group-theoretic algorithm. If we want isomorphism testing, we should follow Levet 2024 (WL Refinement) or simply rely on the fact that `Canonization` is possible.
-   **Takeaway:** We can treat Isomorphism as a "solved problem" for our target class.

## 5. Conclusion
A landmark paper that settled the polynomiality of GI for Rank-Width, now superseded by more efficient/parallelizable approaches. Useful for historical context.
