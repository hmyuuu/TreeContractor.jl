# Analysis: Fast Algorithm for Rank-Width (Heuristics)

**Paper ID:** [Beyß 2013]
**Title:** "Fast Algorithm for Rank-Width"
**Context:** This paper proposes heuristics for computing rank-width, inspired by boolean-width algorithms (Telle et al.).

## 1. The Core Heuristic: Local Search on Decomposition Trees
The paper likely adapts the standard "Caterpillar" or "Swap" moves used in treewidth/branchwidth heuristics to the rank-width setting.

### The "Cut-Swap" Move
Given a subcubic tree $T$:
1.  Select an internal edge $e=(u, v)$.
2.  The removal of $e$ splits leaves into $(A, B)$.
3.  Consider the neighbors of $u$ (say $x, y$) and $v$ (say $z, w$).
4.  A **Swap** operation permutes these subtrees (e.g., attach $x$ to $v$ and $z$ to $u$).
5.  **Objective:** Minimize $\max(\text{rank}(new\_cuts))$.

### The "Split-Merge" Move (Simulated Annealing)
1.  **Split:** Take a node with degree > 3 (if allowing non-binary trees) and split it.
2.  **Merge:** Contract an edge.
3.  In the context of binary trees (Rank-Decomposition), this is equivalent to **Edge Rotation** (Tree Rotation).

## 2. Theoretical Justification for Local Search
-   **Connectivity Functions:** The cut-rank function is symmetric submodular.
-   **Local Optima:** Like all local search, it can get stuck.
-   **Improvement:** Beyß et al. suggest that randomized greedy strategies (like we implemented in the "Branching Heuristic") are good initialization points, but **Iterative Improvement** via rotations is crucial for getting close to the true width.

## 3. Application to Our "Cost Refinement" (T-013)
We want to minimize Cost $\sum 2^{\text{rank}(e)}$, not just Max Rank.
-   **Move:** Standard Tree Rotation.
-   **Gain Calculation:**
    -   Let $e$ be the edge being rotated.
    -   Calculate $\Delta Cost = \text{NewCost}(e') - \text{OldCost}(e)$.
    -   Also check neighbors (ranks might change if the cut changes? No, rank is defined by the partition of leaves).
    -   **Crucial Property:** In a rotation, only the central edge and the immediate incident edges change their partitions?
    -   Wait. A tree rotation changes the structure. The "Cuts" defined by the *other* edges remain the same (the set of leaves in their subtrees is invariant).
    -   **Only the rotated edge $e$ changes its cut partition.**
    -   Therefore, evaluating a move is $O(1)$ rank computations (only 1 new cut to evaluate).
    -   This is extremely fast!

## 4. Proposed "Local Search" Algorithm
1.  **Input:** A rank-decomposition tree $T$.
2.  **Loop:**
    -   Pick a random internal edge $e$.
    -   Try all possible rotations (swapping subtrees of endpoints).
    -   If a rotation reduces $\sum 2^{\text{rank}(e)}$, apply it.
    -   Repeat until converged or time limit.
3.  **Refinement:** Use Simulated Annealing to escape local minima.

## 5. Connection to Oum's "Pivot"
-   Oum's "Pivot" is a graph operation ($G \wedge uv$).
-   Does it correspond to a tree move?
-   No, Oum's pivot changes the *Graph* (and thus the matrix), but preserves the *Rank-Width*.
-   It might change the *optimal decomposition*, effectively "jumping" to a part of the search space where the decomposition is easier to find?
-   *Hypothesis:* Graph Pivoting is orthogonal to Tree Rotation. We can use both.
    -   **Outer Loop:** Pivot the Graph.
    -   **Inner Loop:** Optimize the Tree (Queyranne + Local Search).
