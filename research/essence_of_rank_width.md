# The Theoretical Essence of Rank-Width

## 1. Definition Beyond Graph Theory
Rank-width is not just a graph parameter; it is a measure of the **algebraic complexity of a relation** over a field (typically GF(2)).
- **Treewidth** measures how close a graph is to a tree (Topological Sparsity).
- **Rank-width** measures how close a matrix is to a tree of low-rank cuts (Algebraic Sparsity).

## 2. The Vertex-Minor Connection
The fundamental operation of Rank-Width is not "Edge Contraction" (as in Minors/Treewidth) but **Local Complementation** (Vertex-Minors).
- **Local Complementation ($G*v$):** Inverts the adjacency matrix of the neighborhood of $v$ over GF(2).
- **Quantum Interpretation:** This is exactly the action of a **Local Clifford Gate** on a Graph State.
- **Conclusion:** Two graphs have the same rank-width if they are related by local Cliffords. **Rank-width is a Clifford-invariant entanglement measure.**

## 3. The "Field Gap" is a Feature
The discrepancy between GF(2) Rank and Complex Rank (Schmidt Rank) is the key to efficient simulation.
- **Stabilizer States:** Have GF(2) Rank-Width $k$, Schmidt Rank $2^k$.
- **Near-Stabilizer States:** Have low GF(2) Rank-Width + small non-Clifford corrections.
- **Optimization Strategy:** instead of minimizing bond dimension $\chi$ directly (hard), minimize GF(2) rank-width (easy via Korhonen 2024) to find a basis where the state is "most stabilizer-like", then compress the residuals.

## 4. Algorithmic Implementation Strategy (The Solver Core)
Our theoretical research has crystallized into a concrete three-step strategy for the solver:

### Step 1: Topology Discovery (Queyranne's Algorithm)
To find the optimal tree structure, we use **Queyranne's Algorithm** (1998) to minimize the symmetric submodular function:
$$ f(S) = \text{rank}_{GF(2)}(G[S, V \setminus S]) $$
- **Why:** This finds the *exact* minimum rank cut in $O(n^3)$ time, avoiding the pitfalls of random heuristics.
- **Recursive Application:** Applying this recursively yields a decomposition that minimizes the *maximum* rank width (Min-Max Optimization).

### Step 2: Cost Refinement (Local Search)
There is a theoretical discrepancy between **Min-Max Rank** (Rank-Width) and **Min-Sum Cost** (Contraction Cost).
- **Discrepancy:** A "Spike" decomposition (one rank 10 cut, many rank 1) is preferred by RW over a uniform decomposition (all rank 5), even if the latter has lower total cost.
- **Solution:** Use the Queyranne tree as a starting point, then apply **Local Search** (edge rotations) to greedily reduce the total contraction cost $\sum 2^{\text{rank}(e)}$.

### Step 3: Evaluation (Hliněný's Parse Tree)
Once the decomposition is found, we evaluate it using **Hliněný's Parse Tree** framework.
- **Parse Tree:** A rooted tree where leaves are tensors and nodes are algebraic composition operations (Amalgamation/Contraction).
- **Execution:** This corresponds exactly to the **Tensor Contraction** phase. The "Type" in Hliněný's logic corresponds to the **Compressed Quantum State** passed between nodes.

## 5. Unification of Methods
| Method | Graph Parameter | Optimizes For |
|--------|-----------------|---------------|
| Tensor Networks | Treewidth | Topology / Connectivity |
| Decision Diagrams | Linear Rank-Width | Variable Ordering / Path-like Separability |
| **Rank-Width Solver** | **Rank-Width** | **Branching Algebraic Separability** |

## 6. The "Holy Grail"
A **Rank-Width Decision Diagram (RWDD)** (or "Rank-Width Tensor Network") would combine:
1.  **Branching structure** of Tensor Networks (better than linear DDs).
2.  **Algebraic compression** of Decision Diagrams (better than dense TNs).
3.  **Clifford invariance** of Rank-Width (exploits quantum structure).
