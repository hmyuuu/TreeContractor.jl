# Open Questions

## 1. Implementation
- **Q1:** Can we implement the $O(n)$ algorithm from [Korhonen 2024] practically, or is the constant factor too large?
- **Q2:** How do we efficiently convert a Rank-Decomposition (Cut-Tree) into a Tensor Contraction Tree for general tensors? (The "Translation Gap" remains).

## 2. Theory
- **Q3:** Does **Linear Rank-Width** approximate **Rank-Width** well enough? (Cheng 2025 uses Linear).
    *   *Hypothesis:* For deep circuits, Branching (Rank-Width) is exponentially better than Linear (Linear RW), just like Trees vs Paths.
- **Q4:** Can we define a "Weighted Rank-Width" that accounts for non-Clifford gates (T-gates) explicitly?

## 3. Application
- **Q5:** Can a Rank-Width Solver automatically detect and simulate "Hidden Inverses" (e.g., $U U^\dagger$) which are trivial in rank but hard in topology?
