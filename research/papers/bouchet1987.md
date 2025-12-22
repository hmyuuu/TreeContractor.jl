# Analysis: Isotropic Systems (Bouchet 1987)

**Paper:** "Isotropic Systems"
**Author:** André Bouchet
**Year:** 1987 (European Journal of Combinatorics)
**Task:** T-065
**Agent:** PhD-Theory

## 1. What is an Isotropic System?
An **Isotropic System** is a mathematical structure that generalizes both **Binary Matroids** and **4-Regular Graphs** (via their Transition Polynomials).
-   Defined on a vector space over GF(2).
-   It captures the essence of "connectivity" in a way that is invariant under **Local Complementation** (Vertex-Minors).

## 2. Connection to Rank-Width
Oum and Seymour (2005) explicitly used Isotropic Systems to define Rank-Width initially (before simplifying it to the matrix definition).
-   **Key Insight:** Rank-Width is the "Branch-Width" of the associated Isotropic System.
-   **Vertex-Minor Invariance:** Rank-width is invariant under local complementation (vertex pivoting). This property comes directly from the theory of Isotropic Systems.

## 3. Why It Matters
While the matrix definition ($rank(A[X, Y])$) is easier to compute, the Isotropic System definition is better for proofs involving **Vertex-Minors**.
-   **Circle Graphs:** Circle graphs are the fundamental objects in this theory (associated with "graphic" isotropic systems).
-   **Pivot-Minors:** The operations we use in `LocalSearch.jl` (pivoting) are natural operations in Isotropic Systems.

## 4. Algorithmic Relevance
For V1 of our solver, we rely on the matrix definition.
However, if we implement **Vertex-Minor Recognition** (e.g., "Is G a vertex-minor of H?"), we will need to implement the Isotropic System data structures (Transition Matroids).

## 5. Conclusion
Bouchet (1987) is the "Source Code" of the theory. It's essential for advanced features (Vertex-Minors) but not strictly necessary for the core Rank-Width Solver. We can treat it as "Foundational Reading".
