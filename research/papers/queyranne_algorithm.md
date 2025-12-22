# Queyranne's Algorithm for Rank-Decomposition

## 1. Introduction
Queyranne's algorithm (1998) minimizes a **symmetric submodular function** $f(S)$ over all non-trivial subsets $S \subset V$ in $O(n^3)$ time.
Since the **cut-rank function** $\rho_G(S) = \text{rank}(G[S, V \setminus S])$ is symmetric and submodular (over GF(2)), we can use Queyranne's algorithm to find the cut with the *minimum* rank-width contribution.

## 2. The Algorithm
1.  Start with an arbitrary vertex $x$.
2.  Maintain a set of "merged" vertices.
3.  In each phase, order vertices $v_1, \dots, v_k$ such that each $v_i$ maximizes $f(\{v_1, \dots, v_{i-1}\} \cup \{v_i\}) - f(\{v_i\})$. (Pendant pair identification).
4.  The last two vertices $(v_{k-1}, v_k)$ form a "pendant pair".
5.  The cut separating $v_k$ from the rest is a candidate for the minimum cut.
6.  Merge $v_{k-1}$ and $v_k$ and repeat.

## 3. Application to Rank-Decomposition
To construct a Rank-Decomposition:
1.  We need to split the vertex set $V$ into $(A, B)$.
2.  Ideally, we want to minimize $\max(rw(A), rw(B), \rho(A))$.
3.  Queyranne's algorithm finds $A$ that minimizes $\rho(A)$.
4.  **Challenge:** The minimum cut might be trivial (e.g., separating 1 vertex).
    -   Rank-width of a single vertex cut is usually low (degree-bounded? no).
    -   If we just peel off vertices one by one, we get a linear decomposition (caterpillar).
    -   But rank-width allows branching.
    -   *Solution:* We should use Queyranne's to find a cut, but we might need a *balanced* cut or a cut that doesn't just isolate a leaf.
    -   However, if the min-cut is small, it's a good place to split!
    -   If the min-cut is a single vertex, that's fine. We separate it and recurse on the rest.
    -   Wait, if we always separate 1 vertex, we get a path.
    -   Does this effectively find the optimal decomposition?
    -   For a generic graph, the min-rank cut might be a balanced split (like in a tree).
    -   For a path graph, the min-rank cut is 1 (separating any prefix).
    -   For a cycle, rank is 2.
    -   For a tree, rank is 1 (separating any subtree). Queyranne's will find *some* edge of the tree.
    -   **Hypothesis:** Using Queyranne's algorithm recursively *is* a valid strategy for finding a low-width decomposition. It might not be optimal (balanced), but it finds low-rank cuts.

## 4. Complexity
-   Submodular minimization: $O(n^3)$.
-   Recursive calls: $O(n)$ splits.
-   Total: $O(n^4)$.
-   This fits our performance budget for $N \le 100$.

## 5. Implementation Plan
1.  Implement `minimize_submodular(V, f)` using Queyranne's.
2.  Define `f(S) = cut_rank(G, S)`.
3.  Use it in `build_tree_recursive`.
