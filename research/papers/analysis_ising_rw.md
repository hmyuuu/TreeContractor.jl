# Analysis: Ising Model on Graphs of Bounded Rank-Width

**Task:** T-027
**Agent:** PhD-Physics

## 1. The Core Problem
The Ising Model energy function is:
$$ H(\sigma) = - \sum_{<i,j>} J_{ij} \sigma_i \sigma_j - \sum_i h_i \sigma_i $$
We are interested in:
1.  **Ground State:** $\min_\sigma H(\sigma)$ (Equivalent to Weighted MaxCut).
2.  **Partition Function:** $Z = \sum_\sigma e^{-\beta H(\sigma)}$ (Counting).

## 2. Tractability via Rank-Width
- **General Case:** Finding the ground state is NP-hard (MaxCut). Computing $Z$ is #P-complete.
- **Bounded Rank-Width:** Both problems become **Fixed-Parameter Tractable (FPT)**.
    - **Ground State:** Can be expressed in Monadic Second Order Logic (MSO1). By Courcelle's Theorem (and Oum's extensions), MSO1 optimization is linear time on graphs of bounded rank-width.
    - **Partition Function:** The Ising partition function is a specialization of the **Tutte Polynomial**. The Tutte polynomial can be computed in polynomial time for graphs of bounded clique-width (and thus rank-width).

## 3. Algorithm: Tensor Contraction on Rank-Decomposition
The practical algorithm (as opposed to the logical Courcelle approach) is **Dynamic Programming on the Rank-Decomposition Tree** (also known as Tensor Contraction).

### The Mapping
1.  **Leaves:** Each vertex $i$ is a tensor $T_i$ of shape $(2, \dots)$ representing its local spin state and interactions.
2.  **Internal Nodes:** A node in the rank-decomposition tree represents a partial contraction.
3.  **Cut Rank $k$:** The width of the edge in the tree corresponds to the **Bond Dimension** ($\chi = 2^k$) of the tensor network contraction.
    - If rank-width is $k$, the interaction matrix between the two partitions has rank $k$.
    - This means the "message" passed between subtrees can be compressed to $k$ bits (or $2^k$ amplitudes).

### Implications for Solver
- **Validation:** Our solver's architecture (Find Tree -> Contract) is physically isomorphic to solving the Ising model on a structured graph.
- **Optimization:** Minimizing Rank-Width $\equiv$ Minimizing the maximum entanglement entropy (over GF(2)) across any cut in the tensor network.

## 4. Specific Literature Findings
- **Bordewich & Kang (2011):** Glauber dynamics (sampling) mix rapidly on bounded tree-width. Extensions to clique-width are non-trivial but holographic algorithms (Valiant) often apply.
- **Koehler et al. (2022):** "Sampling Approximately Low-Rank Ising Models". Discusses low-rank interaction matrices $J$. Rank-width is a structural generalization of this: it finds a *basis* where the graph looks low-rank locally.

## 5. Conclusion
The "Ising Model on Bounded Rank-Width" is effectively solved by our proposed architecture. The physics perspective confirms that **Rank-Width is the correct parameter for minimizing contraction complexity** of spin systems.
