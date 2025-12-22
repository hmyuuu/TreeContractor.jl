# Analysis: Almost-linear time parameterized algorithm for rankwidth via dynamic rankwidth

**Paper ID:** [Korhonen 2024]
**Authors:** Tuukka Korhonen and Marek Sokołowski
**Year:** 2024
**Venue:** STOC 2024

## Mathematical Definitions

### Dynamic Rank-Width
The core contribution is a data structure that maintains a rank-decomposition of width at most $4k$ (if one exists with width $k$) under:
- **Edge Insertions/Deletions:** $O_k(2^{\sqrt{\log n} \log \log n})$ amortized time.
- **Dense Updates:** Updating edges inside a set $X$ defined by CMSO1 formulas.

## Algorithmic Content

### The Algorithm
- **Input:** Graph $G$, integer $k$.
- **Output:** Rank-decomposition of width $\le k$ (or certification that width $> k$).
- **Time Complexity:** $O_k(n^{1+o(1)}) + O(m)$.
- **Approach:**
    - Leaf-to-root dynamic programming on a "nice" decomposition? No, that's for solving problems.
    - The construction algorithm uses the dynamic data structure to incrementally build the decomposition.
    - It generalizes the "Dynamic Treewidth" algorithm (FOCS 2023).

### Comparison with Oum-Seymour
- **Oum-Seymour (2006):** $O(n^3)$ time (improved from $O(n^4)$). Constant factor is relatively small (matrix operations).
- **Korhonen (2024):** $O(n^{1+o(1)})$ time. Constant factor depends on $k$ (potentially exponential in $k$).
- **Crossover Point:**
    - For small $N$ (e.g., $N < 500$), the overhead of the dynamic data structure likely outweighs the asymptotic benefit.
    - For Tensor Networks in the NISQ era ($N \approx 50-100$), $O(n^3)$ is practically instantaneous ($\approx 10^5$ ops).

## Tensor Network Applications

### Real-Time Contraction Heuristic
- **Hypothesis H2** suggested using this for a "Lookahead Contractor".
- **Verdict:** Implementing the full dynamic algorithm is likely too complex for the performance gain on small graphs.
- **Alternative:** A simplified "local search" or "greedy" dynamic rank-width (updating rank-width locally after a contraction) might be feasible.

## Critical Evaluation

### Impact
- Solves a major open problem (fast FPT for rank-width).
- Makes rank-width theoretically competitive with treewidth (which has linear time FPT algorithms).

### Relevance to Project
- **Theory:** Validates that rank-width is tractable.
- **Implementation:** **Too complex for immediate implementation.** We should stick to Queyranne ($O(n^3)$) for our solver, which is robust and simple to implement.
