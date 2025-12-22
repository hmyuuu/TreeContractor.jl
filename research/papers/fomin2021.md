# Fast FPT-Approximation of Branchwidth (Fomin & Korhonen, 2021)

**Citation**: Fomin, F. V., & Korhonen, T. (2021). *Fast FPT-Approximation of Branchwidth*. arXiv preprint arXiv:2111.03492.
**Status**: [Analysis in Progress]
**Tags**: #rank-width #algorithm #approximation #branchwidth

## 1. Paper Overview
**Core Result**: A framework for designing FPT 2-approximation algorithms for branchwidth (and rank-width).
**Specific Result**: An algorithm that computes a rank-decomposition of width at most $2k$ (or certifies $>k$) in time $2^{2^{O(k)}} n^2$.
**Significance**: Breaks the "cubic barrier" ($O(n^3)$) for rank-width approximation.

## 2. Group Meeting Protocol (Simulation)

### Participants
*   **PI**: Principal Investigator
*   **PhD-Theory**: Graph Structural Theorist
*   **PhD-Algo**: Algorithm Engineer
*   **PhD-Physics**: Tensor Network Specialist

### Meeting Minutes

#### Round 1: Analysis

**PhD-Theory**:
"This paper is simpler than Korhonen 2024. It focuses on a **Refinement Framework**.
The core idea is: Start with a decomposition. Apply 'Refinement Operations' to decrease width.
If no refinement is possible, they prove a structural theorem: the width is already within factor 2 of optimum.
This 'Local Improvement' philosophy is very similar to our current `LocalSearch.jl` (3-way split optimization), but they have a rigorous proof that it works for *global* approximation."

**PhD-Algo**:
"The complexity is $O(n^2)$. This is much more implementable than the dynamic $O(n^{1+o(1)})$ from 2024.
The algorithm is:
1.  Start with *any* decomposition (maybe random?).
2.  Iteratively improve it using 'Refinement'.
3.  The refinement step uses Dynamic Programming on the current decomposition.
Wait, if they use DP *on the decomposition*, isn't that circular?
Ah, they use the *current* branch decomposition to guide the search for a better cut.
This is exactly what we need for a robust solver. Our current `LocalSearch.jl` is heuristic. This paper gives us the recipe to make it a **2-Approximation**."

**PhD-Physics**:
"A 2-approximation is excellent for Tensor Network contraction ordering.
If we can guarantee width $2k$, the contraction cost is roughly $(2^{2k})^{const}$, which is manageable if $k$ is small.
Also, this paper handles **Branchwidth** of connectivity functions generally. This means we could potentially plug in *other* cost functions (like actual FLOPS cost) instead of just GF(2) rank, although the 2-approximation proof relies on submodularity."

#### Round 2: Synthesis & Decisions (PI)

**PI**:
"This paper offers a pragmatic middle ground.
Korhonen 2024 (Dynamic) is the 'Future', but Fomin 2021 ($O(n^2)$ Refinement) is the 'Now'.
We already have `LocalSearch.jl`. This paper essentially tells us *which* local moves to make to guarantee convergence to $2k$.

**Strategic Decision**: We will upgrade our `LocalSearch.jl` to implement the **Refinement Operations** defined in this paper.
This will convert our heuristic solver into an $O(n^2)$ 2-approximation solver.

**Action Items**:
1.  **PhD-Theory**: Extract the exact definition of the 'Refinement Operation'. Is it just 3-way splitting (ternary split)? Or something more complex?
2.  **PhD-Algo**: Check if our `LocalSearch.jl` architecture supports this specific refinement.
3.  **PhD-Physics**: Validate if 'Symmetric Submodular Function' properties hold for our weighted rank-width (if we define one)."

### 3. Key Concepts Extracted
*   **Refinement Operation**: The specific move that reduces width or certifies optimality.
*   **2-Approximation**: The guarantee.
*   **Submodularity**: The property required for the proof.

### 4. Implementation Plan (Draft)
1.  Read Section 4 & 5 carefully to find the "Refinement" algorithm.
2.  Implement `refine_decomposition!(pt::ParseTree)` function.
3.  Wrap it in a loop: `while improve(pt); end`.

## 5. References
*   Fomin, F. V., & Korhonen, T. (2021).
