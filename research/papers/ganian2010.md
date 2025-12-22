# Analysis: Better algorithms for satisfiability problems for formulas of bounded rank-width

**Paper ID:** [Ganian 2010]
**Authors:** Robert Ganian, Petr Hliněný, Jan Obdržálek
**Year:** 2010
**Conference:** FSTTCS

## Algorithmic Content

### Dynamic Programming on Rank-Decompositions
The core contribution is a Fixed Parameter Tractable (FPT) algorithm for `#SAT` (counting satisfiability solutions) parameterized by the **rank-width** of the formula's signed graph.

- **Input:** A formula $F$ and its rank-decomposition of width $k$.
- **Process:** Bottom-up dynamic programming (DP) on the decomposition tree.
- **State Definition:** At each node of the tree (representing a cut $(A, B)$), the algorithm maintains a table of "partial solutions".
- **Equivalence Classes:** Since the cut has rank $k$ over $GF(2)$, there are at most $2^k$ distinct "interaction patterns" across the cut. Two partial truth assignments on $A$ are equivalent if they induce the same linear combination of neighbors in $B$.
- **Table Size:** The DP table stores the count of partial assignments for each of the $2^k$ equivalence classes.
- **Complexity:** $O(n^3 \cdot 2^{k^2})$ or similar, single-exponential in $k$.

## Relevance to Tensor Networks

### The "Field Gap" Confirmed
This analysis confirms a critical distinction (the "Field Gap") between Ganian's approach and Tensor Network contraction:

1.  **Ganian (GF(2)):**
    *   The equivalence classes are defined by linear dependency over $GF(2)$.
    *   Total classes = $2^{\text{rank}_{GF(2)}}$.
    *   This is exact for problems like `#SAT` or `XOR-SAT` where the "interaction" is inherently boolean/modulo-2.

2.  **Tensor Networks (Complex/Real):**
    *   In a tensor network, the "state" passing through a cut is a vector in a vector space.
    *   The dimension of this space is the **Schmidt Rank** (or bond dimension $\chi$).
    *   If we tried to apply Ganian's logic directly, we would need to discretize the continuous coefficients.
    *   However, the **structure** is identical: Ganian's "$2^k$ classes" corresponds exactly to a bond dimension of $\chi = 2^k$.

### Equivalence
*   **Rank-Width $k$** in Ganian's sense implies that the "information" passing through the cut can be compressed to $k$ bits.
*   **Bond Dimension $\chi$** in TNs implies the information is compressed to $\chi$ complex numbers.
*   **Mapping:** If a tensor network is *constructed* from a boolean formula (e.g., a counting TN), its "true" bond dimension might be huge, but its "structural" bond dimension (if we only care about the $0/1$ structure) is small.

## Critical Evaluation

### Can we "lift" the algorithm?
- **Directly? No.** We cannot use $GF(2)$ rank to compress arbitrary complex vectors. A low $GF(2)$ rank does not imply low Schmidt rank for arbitrary data.
- **Structurally? Yes.** For specific classes of Tensor Networks (e.g., **Stabilizer Circuits**, **Graph States**, **Clifford TNs**), the tensors are effectively "boolean functions in disguise."
    *   For these systems, the Schmidt rank is exactly $2^{\text{rank}_{GF(2)}}$.
    *   Therefore, a rank-width optimizer (minimizing $k$) effectively minimizes the bond dimension ($\chi = 2^k$) for these specific quantum states.

## Conclusion for Research
Ganian's algorithm is essentially a "Contractor for Stabilizer Circuits." It proves that for $GF(2)$-structured problems, **Rank-Width** is the correct parameter. For general TNs, it is only a heuristic for the *topology*, but cannot guarantee the *bond dimension* without checking the actual coefficients.
