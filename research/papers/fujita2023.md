# Analysis: Short Survey of Obstruction to Rank-width and Linear Rank Width (Fujita 2023)

**Paper:** "Short Survey of Obstruction to Rank-width and Linear Rank Width"
**Author:** Takaaki Fujita
**Year:** 2023
**Task:** T-072
**Agent:** PhD-Theory

## 1. Overview
This is a survey paper summarizing known results about forbidden minors and vertex-minors for Rank-Width and Linear Rank-Width.
-   **Goal:** To organize the scattered results (from Oum, Adler, Kanté, Kwon, etc.) into a single reference.

## 2. Key Lists of Obstructions
1.  **Rank-Width $\le 1$ (Distance-Hereditary):**
    -   Forbidden Vertex-Minors: House, Domino, Gem (Wait, that's for DH graphs themselves).
    -   Actually, RW $\le 1$ $\iff$ Distance Hereditary.
2.  **Linear Rank-Width $\le 1$:**
    -   Forbidden Vertex-Minors: Several known small graphs (Necklace graphs, etc.).
3.  **Rank-Width $\le k$:**
    -   The list is finite for any $k$ (Oum 2005), but explicit lists are unknown for $k \ge 2$.
    -   Grid graphs are the canonical "large rank-width" obstructions.

## 3. Utility
This paper doesn't add new results but serves as a **"Lookup Table"** for our test suite.
-   When we build `test_solver.jl`, we should check if our solver correctly identifies the listed obstruction graphs as having width $> k$.

## 4. Conclusion
A useful reference document. Confirms that "Grid Graphs" are the gold standard for testing high rank-width.
