# Theoretical Note: The Discrepancy Between Rank-Width and Contraction Cost

## 1. Problem Statement
We often assume that minimizing **Rank-Width (RW)** is equivalent to minimizing the **Tensor Network Contraction Cost (CC)**. This note investigates the theoretical validity of this assumption.

## 2. Definitions

### Rank-Width (RW)
The rank-width of a graph $G$, denoted $rw(G)$, is the minimum $k$ such that there exists a rank-decomposition $(T, L)$ where for every edge $e \in E(T)$, the cut-rank $\rho(e) \le k$.
$$ rw(G) = \min_{(T,L)} \max_{e \in E(T)} \rho(e) $$
This is a **Min-Max** objective.

### Contraction Cost (CC)
For a given contraction tree $T$, the contraction cost is the sum of the costs of each contraction step (node in $T$).
$$ CC(T) = \sum_{v \in V(T)} \text{cost}(v) $$
where $\text{cost}(v)$ is typically the product of the dimensions of the tensors involved.
If we work with $GF(2)$ rank $r$, the bond dimension is $2^r$.
$$ CC(T) \approx \sum_{v \in V(T)} 2^{\rho(e_1) + \rho(e_2) + \rho(e_3)} $$
This is a **Min-Sum** objective of exponentials.

## 3. The Discrepancy
Is a decomposition that minimizes the *maximum* rank also one that minimizes the *sum* of costs?

### Example 1: The "Spike"
Consider a decomposition $T_1$ where one edge has rank 10, and all others have rank 1.
- Max Rank: 10.
- Cost: $\approx 2^{10} + N \cdot 2^1$.

Consider a decomposition $T_2$ where all edges have rank 5.
- Max Rank: 5.
- Cost: $\approx N \cdot 2^5$.

**Analysis:**
- $rw(T_1) = 10$, $rw(T_2) = 5$. Rank-Width prefers $T_2$.
- Cost($T_1$) $\approx 1024$.
- Cost($T_2$) $\approx 32N$.
- If $N$ is large ($N > 32$), $T_1$ might actually be cheaper!
- **Conclusion:** Rank-Width essentially assumes "worst-case" optimization, whereas Contraction Cost is "average-case" (dominated by the max, but sensitive to $N$).

## 4. Why Rank-Width is Still the Right Metric
Despite the discrepancy, minimizing Rank-Width is the correct proxy for two reasons:
1.  **Dominance of the Max:** In most hard instances (like random circuits), the ranks are concentrated. The cost is dominated by the largest tensor. $2^{k}$ grows so fast that minimizing $k$ is almost always necessary to make the sum convergent.
2.  **Tractability:** Minimizing a sum of exponentials is extremely hard (Sum-Product optimization). Minimizing the max is a standard bottleneck capacity problem (Min-Max), which admits polynomial time approximations (like Oum-Seymour).

## 5. Proposed Hybrid Approach
For the actual solver, we should:
1.  Use **Rank-Width** (Queyranne's Algorithm) to find the *topology* of the tree (minimizing the bottleneck).
2.  Use **Local Search** (as originally planned in T-013) to refine the tree to minimize the specific *sum cost*, potentially allowing the max rank to increase slightly if it reduces the total sum.

## 6. Open Theoretical Question
Can we bound the ratio?
$$ \frac{CC(T_{opt-cost})}{CC(T_{opt-rw})} \le ? $$
Conjecture: The ratio is bounded by polynomial in $N$.
