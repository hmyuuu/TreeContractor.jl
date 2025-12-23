# Analysis: A Unifying Framework for Width Measures (Eiben et al. 2022)

**Paper:** "A Unifying Framework for Characterizing and Computing Width Measures"
**Authors:** Eduard Eiben, Robert Ganian, Thekla Hamm, Lars Jaffke, O-joung Kwon
**Year:** 2022 (ITCS 2022, LIPIcs Vol. 63)
**Task:** T-078
**Agent:** PhD-Theory

## 1. Overview

This paper introduces **F-branchwidth** as a unifying framework that captures:
- Treewidth
- Clique-width (via rank-width)
- Mim-width
- Module-width
- H-join decompositions

Key contribution: Only **six** fundamental graph classes are needed to characterize ALL F-branchwidth parameters!

## 2. F-Branchwidth Definition

### 2.1 Partner-Hereditary Classes
A class $\mathcal{F}$ of bipartite graphs with bipartition $(A, B)$ where $|A| = |B| = n$ is **partner-hereditary (ph)** if:
- Vertices are paired: $(a_i, b_i)$ for $i \in [n]$
- For any subset $L \subseteq [n]$, the induced graph on $\{a_i, b_i \mid i \in L\}$ is in $\mathcal{F}$

### 2.2 F-Branchwidth
For ph family $\mathcal{F}$, the **$\mathcal{F}$-branchwidth** is branchwidth where:
- Cut function $f(X)$ = largest $n$ such that a $2n$-vertex graph in $\mathcal{F}$ is induced subgraph of $G[X, V \setminus X]$

## 3. The Six Size-Identifiable Classes

### 3.1 Definition
$\mathcal{F}$ is **size-identifiable (si)** if there's unique $2n$-vertex graph in $\mathcal{F}$ for each $n$.

### 3.2 Theorem (Lemma 4.2)
> There are **precisely six** si and ph families:

| Family | Graph Structure | Description |
|--------|-----------------|-------------|
| $\mathcal{F}_\emptyset$ | $H^n_\emptyset$ - no edges | All edgeless bipartite |
| $\mathcal{F}_=$ | $H^n_=$ - $a_ib_i$ edges only | All matchings |
| $\mathcal{F}_\leq$ | $H^n_\leq$ - $a_ib_j$ if $i \leq j$ | Chain graphs (no twins) |
| $\mathcal{F}_<$ | $H^n_<$ - $a_ib_j$ if $i < j$ | Chain minus matching |
| $\mathcal{F}_\neq$ | $H^n_\neq$ - $a_ib_j$ if $i \neq j$ | Anti-matchings |
| $\mathcal{F}_*$ | $H^n_*$ - all edges | Complete bipartite $K_{n,n}$ |

### 3.3 Key Result (Lemma 4.3)
> For any ph class $\mathcal{F}$, $\mathcal{F}$-branchwidth is asymptotically equivalent to $\mathcal{F}'$-branchwidth where $\mathcal{F}'$ is union of si families contained in $\mathcal{F}$.

## 4. Connections to Known Parameters

### 4.1 Mim-Width
**Observation 4.4:**
$$\text{mim-width}(G) = \mathcal{F}_=\text{-branchwidth}(G)$$

### 4.2 Treewidth
**Lemma 4.5:** Maximum-matching width $\approx$ treewidth, and:
$$\mathcal{F}^*\text{-bw}(G) \leq \text{tw}(G) + 1$$
where $\mathcal{F}^* = \mathcal{F}_= \cup \mathcal{F}_\leq \cup \mathcal{F}_\neq$

### 4.3 Clique-Width / Module-Width
**Lemma 4.7:** Module-width $\approx$ $(\mathcal{F}_= \cup \mathcal{F}_< \cup \mathcal{F}_\neq)$-branchwidth

### 4.4 H-Join Decompositions
**Lemma 4.8:** $\mathcal{F}_= \cup \mathcal{F}_< \cup \mathcal{F}_\neq$-branchwidth ≤ |V(H)| for H-join decomposable graphs

## 5. Primal Families

### 5.1 Definition
The **primal** families are: $\mathcal{F}_=$, $\mathcal{F}_\leq$, $\mathcal{F}_\neq$

### 5.2 Main Approximation Result (Lemma 4.13)
> Let $\mathcal{F}$ be union of si ph classes other than $\mathcal{F}_\emptyset$. Let $\mathcal{F}^*$ be union of all primal families in $\mathcal{F}$.
> Then optimal $\mathcal{F}^*$-branch decomposition is **3-approximate** $\mathcal{F}$-branch decomposition.

This means: To compute ANY F-branchwidth approximately, we only need algorithms for combinations of **three** primal families!

## 6. Algorithmic Results

### 6.1 Theorem 5.1 (Treewidth + Degree)
> $\mathcal{F}^*$-Branchwidth is FPT parameterized by treewidth + maximum degree.

**Corollary 5.2:** Mim-Width is FPT parameterized by tw + Δ(G).

### 6.2 Theorem 6.2 (Treedepth)
> $\mathcal{F}^*$-Branchwidth is FPT parameterized by treedepth.

**Corollary 6.3:** Mim-Width is FPT parameterized by treedepth.

### 6.3 Theorem 7.5 (Feedback Edge Set)
> $\mathcal{F}^*$-Branchwidth admits **linear kernel** parameterized by feedback edge set number.

**Corollary 7.6:** Mim-Width has linear kernel parameterized by feedback edge set.

## 7. Technical Tools

### 7.1 Ramsey Theory
Used to prove only six si ph classes exist:
- **Lemma 4.1:** Any bipartite graph with $q \geq R(2n, 2n, 2n, 2n)$ partners contains one of six si structures on $n$ partners

### 7.2 Typical Sequences
Used in FPT algorithm (Section 5):
- Length of typical sequence with entries in $\{0\} \cup [k]$: at most $2k+1$
- Number of such sequences: at most $\frac{8}{3} 2^{2k}$

### 7.3 Branch Decomposition Records
Algorithm maintains records $(D, \flat, \Lambda, \sigma, \alpha_=, \alpha_\leq, \alpha_\neq)$:
- $D$: Binary tree on $\leq 2|N^3[\chi(t)]|$ vertices
- $\flat$: Partition of distant neighborhood
- $\Lambda$: Interaction with local neighborhood
- $\sigma$: Typical sequences for $\mathcal{F}_=$-bw
- $\alpha$'s: Width values for three primal families

## 8. Parameter Hierarchy

```
                    F-branchwidth (General)
                          ↓
           Six si ph classes (Lemma 4.2)
                          ↓
    ┌─────────────────────┼─────────────────────┐
    ↓                     ↓                     ↓
  F∅ (trivial)    F* (complete - trivial)   Primal: F=, F≤, F≠
                                                    ↓
                                            ┌───────┼───────┐
                                            ↓       ↓       ↓
                                         Mim-width  TW    CW/RW
```

## 9. Implications for Our Implementation

### 9.1 Rank-Width Position
Rank-width corresponds to $\mathcal{F}_= \cup \mathcal{F}_< \cup \mathcal{F}_\neq$:
- Same primal families as clique-width
- Optimal rank-decomposition gives 3-approximate clique-width expression

### 9.2 Algorithm Design
- For computing rank-width: focus on primal families
- Connection to mim-width through $\mathcal{F}_=$
- Unified DP framework possible for multiple parameters

### 9.3 Structural Insights
- Six fundamental obstruction types
- All width measures reduce to combinations of these
- Potential for unified solver architecture

## 10. Open Questions (from Paper)

1. Can Theorem 5.1 be generalized to treewidth parameterization alone?
2. Can approximately-optimal decompositions be computed in polynomial time for constant width?
3. What are the algorithmic properties of newly identified combinations ($\mathcal{F}_<$-branchwidth, $\mathcal{F}_\neq$-branchwidth)?

## 11. Key Quotes

> "We identify F-branchwidth as a class of generic decompositional parameters that can capture mim-width, treewidth, clique-width as well as other measures."

> "There exist precisely six si ph classes."

> "Every optimal $\mathcal{F}^*$-branch decomposition is also an approximately-optimal $\mathcal{F}$-branch decomposition."

> "Mim-Width is FPT parameterized by the treewidth and the maximum degree of the input graph."

## 12. Summary

1. **Unification:** F-branchwidth captures all major decomposition parameters
2. **Classification:** Only 6 fundamental bipartite structures matter
3. **Simplification:** Only 3 primal families needed for approximation
4. **Algorithms:** FPT results for tw+Δ, treedepth; linear kernel for FES
5. **Impact:** First efficient algorithms for mim-width under structural parameters

**Status:** Completed
