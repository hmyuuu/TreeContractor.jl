# Analysis: Weighted Rank-Width for Mixed States

**Context:** Task T-022
**Goal:** Define a "Weighted Rank-Width" to optimize contraction cost in circuits with mixed gate complexity (Cliffords vs T-gates).

## 1. Theoretical Foundation

### Submodularity of Weighted Rank
The standard matroid rank function $r(S)$ is submodular.
Can we define a weighted version?
-   **Definition 1 (Element Weights):** If $w(x)$ is a weight for each element, and $f(S) = \sum_{x \in S} w(x)$, then $f$ is modular (and thus submodular).
-   **Definition 2 (Weighted Rank):** Let $f(S) = \text{rank}(S) + w(S)$. Since the sum of submodular functions is submodular, this function is **submodular**.

### Application to Rank-Width
For a cut $(A, B)$, the standard cost is $\text{rank}(M_{A,B})$.
We want to penalize cuts that separate "expensive" tensors (T-gates).
However, T-gates are *vertices* in the graph.
-   If we split a T-gate... wait, vertices are not split. Vertices are partitioned.
-   The cost comes from the **edge** created by the cut.
-   The dimension of the edge is $2^{\text{rank}}$.
-   If the graph state edges have "weights" (e.g., some edges represent physical qubits, some represent virtual history), does that matter?
-   **Key Insight:** In a graph state, all edges are $CZ$ gates (weight 1). The "weight" comes from the **local tensor** at the vertex (e.g., $T |+\rangle$).
-   But rank-width minimizes the *cut rank*.
-   If we have a "Weighted Graph" where edges have weights $w_{ij}$, the cut-rank generalizes to "weighted cut rank".
-   **Is Weighted Cut-Rank Submodular?**
    -   Yes, if defined as $f(S) = \sum_{u \in S, v \notin S} w_{uv}$. This is the standard "Cut Function", which is submodular.
    -   But we need **Matrix Rank** + **Weights**.

## 2. A Hybrid Objective Function
We propose minimizing:
$$ g(S) = \text{rank}_{GF(2)}(M_{A,B}) + \lambda \cdot \text{CutWeight}(A, B) $$
where $\text{CutWeight}$ measures the number of "non-Clifford connections" cut.
-   Since both terms are submodular (Matrix Rank is submodular, Graph Cut is submodular), their sum is **submodular**.
-   **Symmetry:** Both are symmetric ($g(S) = g(V \setminus S)$).
-   **Conclusion:** We can use **Queyranne's Algorithm** directly on this hybrid function!

## 3. Implications for Solver
-   **Input:** Graph $G$ (adjacency), Weights $W$ (on edges).
-   **Algorithm:** `minimize_symmetric_submodular(V, f)` where `f(S) = cut_rank(S) + lambda * cut_weight(S)`.
-   **Tuning:** $\lambda$ controls the trade-off between minimizing bond dimension (rank) and minimizing "interaction distance" (weight).

## 4. Documentation Plan
1.  Define `WeightedGraph` struct.
2.  Implement `weighted_cut_rank(G, S)`.
3.  Update `Queyranne.jl` to accept generic function $f$.
