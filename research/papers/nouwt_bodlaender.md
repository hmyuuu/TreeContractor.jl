# Analysis: Simulated Annealing for Rank-Width (Nouwt & Bodlaender)

**Paper:** "A Simulated Annealing Method for Computing Rank-Width" (Master's Thesis, Utrecht University, 2022)
**Authors:** Florian Nouwt, Hans L. Bodlaender
**Task:** T-053
**Agent:** PhD-Algo

## 1. Core Contribution
This work provides a practical, heuristic approach to computing Rank-Width (and related parameters like Maximum Matching-Width) using **Simulated Annealing (SA)**. It demonstrates that SA is a viable alternative to exact exponential algorithms ($O(2^n)$) and constructive approximations ($O(n^3)$), often finding better decompositions for medium-sized graphs where exact methods time out.

## 2. The Algorithm

### 2.1 State Space
-   **State:** A **Cubic Tree** (or subcubic) where leaves correspond to graph vertices.
-   **Representation:** Standard pointer-based tree or adjacency list.

### 2.2 Moves (Neighborhood)
The core move is the **Tree Rotation** (also known as Edge Flip or Edge Rotation).
1.  Select an internal edge $e=(u,v)$.
2.  Let $N(u) = \{v, a, b\}$ and $N(v) = \{u, c, d\}$.
3.  **Swap:** Exchange a neighbor of $u$ (say $b$) with a neighbor of $v$ (say $c$).
4.  New topology preserves the leaves but changes the cut defined by $e$ (and potentially others).

### 2.3 Energy Function (Cost)
The goal is to minimize the **Rank-Width** $k = \max_{e \in E(T)} \text{rank}(cut_e)$.
However, the landscape of "Max Rank" is effectively a series of plateaus. To guide the search, a **Smoothed Cost Function** is essential.
-   *Likely Candidate:* $\sum_{e \in E(T)} 2^{\text{rank}(e)}$ (or similar exponential sum).
-   **Thresholding:** The thesis mentions a "Thresholding Heuristic", which likely rejects any move that results in a single cut exceeding a target bound $K_{target}$, even if the total energy decreases (or vice versa).

### 2.4 Cooling Schedule
-   **Adaptive Cooling:** The temperature $T$ is not lowered by a fixed factor $\alpha$, but adjusted dynamically based on the **Acceptance Rate**.
    -   If acceptance is high, cool faster.
    -   If acceptance is low (stuck), cool slower or reheat.
-   **Metropolis Criterion:** Accept worse moves with probability $P = \exp(-\Delta E / T)$.

## 3. Implementation Details (Inferred from `RankWidthApproximate` repo)
-   **Language:** C++ (for speed).
-   **Optimizations:**
    -   **Bitsets:** For fast GF(2) rank computation (Gaussian elimination).
    -   **Local Updates:** When an edge is rotated, only the ranks of the affected edges need re-computation (usually $O(1)$ updates relative to the full tree).
    -   **SIMD:** AVX2 used for bitset operations.

## 4. Relevance to Our Project
We currently have a `LocalSearch.jl` module that performs **Greedy Descent** (Hill Climbing). It gets stuck in local minima.
Adopting Nouwt's SA approach is the logical next step to upgrade our solver from "Heuristic" to "Meta-Heuristic".

### Action Items
1.  **Upgrade `LocalSearch.jl`:**
    -   Add `temperature` parameter.
    -   Implement `metropolis_accept(delta, temp)`.
    -   Add a `cooling_schedule` loop.
2.  **Verify Cost Function:** Ensure we are using the exponential sum $\sum 2^{rank}$ as the energy, not just the max. (We already do this in `refine_decomposition!`).

## 5. Conclusion
Nouwt & Bodlaender confirm that local search on the decomposition tree is a winning strategy. By adding "Temperature" (noise), we can match the performance of their C++ solver within our Julia framework.
