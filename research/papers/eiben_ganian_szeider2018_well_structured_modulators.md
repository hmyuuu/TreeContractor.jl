# Analysis: Solving Problems on Graphs of High Rank-Width (Eiben-Ganian-Szeider 2018)

**Paper:** "Solving Problems on Graphs of High Rank-Width"
**Authors:** Eduard Eiben, Robert Ganian, Stefan Szeider
**Journal:** Algorithmica, Volume 80, Issue 2, Pages 742-771 (2018)
**DOI:** 10.1007/s00453-017-0290-8
**Task:** Deep Research on Algorithmic Benefits
**Agent:** PhD-Theory

## 1. Overview

This paper introduces **well-structured modulators** - a hybrid parameter combining modulators with rank-width to solve problems on graphs that have **high rank-width overall but contain structured subgraphs**.

**Key Innovation:** Instead of requiring the entire graph to have bounded rank-width, we only need a "modulator" (vertex set whose deletion puts the graph in a nice class) that itself has bounded rank-width.

## 2. Core Concept: Well-Structured Modulators

### 2.1 Definition

**Definition 6 (Well-Structured Modulator):**
Let $\mathcal{H}$ be a hereditary graph class. A set $X$ of pairwise-disjoint split-modules of $G$ is a **k-well-structured modulator to $\mathcal{H}$** if:
1. $|X| \leq k$
2. $\bigcup_{X_i \in X} X_i$ is a modulator to $\mathcal{H}$
3. $\text{rw}(G[X_i]) \leq k$ for each $X_i \in X$

### 2.2 The Well-Structure Number

$$\text{wsn}_\mathcal{H}(G) = \min\{k : G \text{ has a } k\text{-well-structured modulator to } \mathcal{H}\}$$

### 2.3 Split-Module Requirement

The split-module requirement is crucial:
- A **split** of connected graph $G$ is a vertex bipartition $\{A, B\}$ where every vertex of $A' = N(B)$ has the same neighborhood in $B' = N(A)$
- A **split-module** is a set $A$ such that $\{A, V' \setminus A\}$ forms a split

This restricts how the modulator connects to the rest of the graph.

## 3. Power of Well-Structured Modulators

### 3.1 Comparison with Other Parameters

**Proposition 1:**
1. $\text{rw}(G) \geq \text{wsn}_\mathcal{H}(G)$ for every graph $G$
   - Furthermore, for every $i$ there exists $G_i$ with $\text{rw}(G_i) \geq \text{wsn}_\mathcal{H}(G_i) + i$
2. $\text{mod}_\mathcal{H}(G) \geq \text{wsn}_\mathcal{H}(G)$ for every graph $G$
   - Furthermore, for every $i$ there exists $G_i$ with $\text{mod}_\mathcal{H}(G_i) \geq \text{wsn}_\mathcal{H}(G_i) + i$

**Interpretation:** Well-structure number is never larger than rank-width or modulator size, and can be exponentially smaller than both!

### 3.2 Visual Example

```
        [Graph G with wsn_H = 2]

    Modulator X = {X_1, X_2} where:
    - X_1, X_2 are split-modules
    - rw(G[X_1]) ≤ 2, rw(G[X_2]) ≤ 2
    - G - (X_1 ∪ X_2) ∈ H

    Even though rw(G) could be unbounded!
```

## 4. Computing Well-Structured Modulators

### 4.1 Main Algorithm (Theorem 6)

**Theorem 6:** For any graph class $\mathcal{H}$ characterized by a finite obstruction set $F$, there exists an FPT algorithm that either:
- Finds a $k$-well-structured modulator to $\mathcal{H}$, or
- Detects that no such modulator exists

### 4.2 The Equivalence Relation $\sim_k$

**Definition 7:** $v \sim_k^G w$ iff there exists a split-module $M$ with $v, w \in M$ and $\text{rw}(G[M]) \leq k$

**Proposition 2:** For every graph $G$ of rank-width $\geq k+2$:
- $\sim_k$ is an equivalence relation
- Each equivalence class is a split-module with rank-width $\leq k$

### 4.3 Algorithm Structure (Algorithm 1: FindWSM_F)

```
Input: k ∈ ℕ₀, n-vertex graph G, equivalence ∼
Output: k-cardinality set X of subsets of V(G), or False

1. if G does not contain any D ∈ F as induced subgraph then
2.     return ∅
3. else
4.     D' := an induced subgraph of G isomorphic to some D ∈ F
5. end
6. if k = 0 then return False
7. foreach [a]∼ of G which intersects with V(D') do
8.     X = FindWSM_F(k-1, G-[a]∼, ∼)
9.     if X ≠ False then
10.        return X ∪ {[a]∼}
11.    end
12. end
13. return False
```

**Time Complexity:** $O(c_F^k \cdot n^{c_F})$ where $c_F$ = max vertices in any obstruction

## 5. Algorithmic Applications

### 5.1 Minimum Vertex Cover (Theorem 8)

**Theorem 8:** MinVC is FPT parameterized by $\text{wsn}_\mathcal{H}$ iff MinVC is polynomial-time tractable on $\mathcal{H}$.

**Algorithm Sketch (Lemma 9):**
1. Compute $k$-well-structured modulator $X = \{X_1, \ldots, X_k\}$
2. For each $X_i$, let $A_i$ = frontier, $B_i = N(A_i)$
3. Branch over all $2^k$ signatures (which of $A_i$ or $B_i$ to include)
4. For remaining components, use H-specific algorithm or bounded-rw algorithm
5. Return minimum solution found

### 5.2 Maximum Clique (Theorem 8)

Similar structure to MinVC:
1. Branch over which split-modules contribute to clique ($2^{k+1}$ choices)
2. Check adjacency constraints between selected modules
3. Find max clique in each selected module
4. Union gives overall clique

### 5.3 Concrete Graph Classes

**MinVC tractable on:**
- Split graphs ($(2K_2, C_4, C_5)$-free)
- $P_5$-free graphs
- Fork-free graphs
- (banner, $T_{2,2,2}$)-free graphs

**MaxClq tractable on:**
- Complements of the above
- Bounded degree graphs

## 6. MSO Meta-Theorem

### 6.1 Main Result (Theorem 9)

**Theorem 9:** Let $\phi$ be an MSO sentence and $\mathcal{H}$ be characterized by finite obstructions. If MSO-MC$_\phi$ is FPT parameterized by $\text{mod}_\mathcal{H}(G)$, then MSO-MC$_\phi$ is FPT parameterized by $\text{wsn}_\mathcal{H}(G)$.

### 6.2 Proof Technique: Replacement

**Key Concept - q-Similarity (Definition 8):**
$(G, X)$ and $(G', X')$ are q-similar if:
1. Isomorphism between $G - X$ and $G' - X'$
2. Frontier adjacencies preserved
3. MSO q-types of split-modules match

**Lemma 14:** If $(G, X)$ and $(G', X')$ are q-similar, then $\text{type}_q(G, \emptyset) = \text{type}_q(G', \emptyset)$

### 6.3 Small Representatives (Lemma 15)

For graph $G$ of rank-width $\leq k$ and $S \subseteq V(G)$:
- Can compute $G'$ with $|V(G')| \leq g(q)$ (constant!)
- Such that $\text{type}_q(G, S) = \text{type}_q(G', S')$

This enables **compression** of well-structured modulators to constant size!

## 7. Tightness: LinEMSO Hardness

### 7.1 Negative Result (Theorem 10)

**Theorem 10:** There exists MSO formula $\phi$ and class $\mathcal{H}$ such that:
- MSO-Opt$^\leq_\phi$ is FPT parameterized by $\text{mod}_\mathcal{H}$
- But **paraNP-hard** parameterized by $\text{wsn}_\mathcal{H}$

### 7.2 Counterexample Construction

- $\phi$ = "exists proper 5-coloring"
- $\mathcal{H}$ = graphs of degree $\leq 4$
- MSO-MC$_\phi$ is polynomial on $\mathcal{H}$ (greedy 5-coloring)
- But 5-colorability implies 3-colorability of $G[\mathcal{H}]$, which is NP-hard on degree-4 graphs

**Implication:** The weaker condition "polynomial on $\mathcal{H}$" is insufficient for MSO optimization.

## 8. Key Technical Insights

### 8.1 Split Decompositions

**Theorem 1 (Cunningham):** Every split of connected $G$ corresponds to removing a tree-edge from split-tree $ST(G)$.

**Theorem 2:** Split-tree computable in $O((n+m)\alpha(n+m))$ time (inverse Ackermann).

### 8.2 Rank-Width and Splits

**Lemma 6:** If $G$ has rank-width $\geq k+2$ and $M_1, M_2$ are overlapping split-modules with $\text{rw}(G[M_i]) \leq k$:
- Then $M_1 \cup M_2$ is a split-module
- And $\text{rw}(G[M_1 \cup M_2]) \leq k$

This is the key to transitivity of $\sim_k$.

### 8.3 Graph-Labeled Trees

Modern approach to split-decompositions using:
- Internal nodes labeled by graphs
- Accessibility relation for edges
- Efficient computation and manipulation

## 9. Extensions Beyond Finite Obstructions

### 9.1 Forests (Lemma 11)

Computing $k$-well-structured modulator to forests in $f(k) \cdot n^5$ time:
1. Use $\sim_k$ to partition vertices
2. Check acyclicity in 3-tuples of classes
3. Branch on cycle-forming classes
4. Find feedback vertex set in quotient graph

### 9.2 Chordal Graphs (Lemma 12)

Similar approach:
1. Check chordality in 3-tuples
2. Branch on classes containing chordless cycles
3. Find chordal vertex deletion in quotient

## 10. Implications for Implementation

### 10.1 Hybrid Solver Strategy

For graph $G$:
1. Compute $\text{wsn}_\mathcal{H}(G)$ for suitable $\mathcal{H}$
2. If small: use well-structured modulator approach
3. If large: fall back to other methods

### 10.2 Choice of Base Class $\mathcal{H}$

Good choices for MinVC/MaxClq:
- Split graphs
- $P_5$-free graphs
- Bounded degree graphs

Trade-off: Larger $\mathcal{H}$ → smaller modulator but more complex algorithm

### 10.3 Practical Considerations

- Split-tree computation is near-linear
- Equivalence relation $\sim_k$ requires $O(n^2)$ comparisons
- Main bottleneck: branching over obstructions

## 11. Connections to Other Work

| Paper | Relationship |
|-------|--------------|
| Oum-Seymour 2006 | Rank-width approximation used |
| Ganian-Hliněný 2010 | Parse tree framework extended |
| Courcelle-Oum 2007 | MSO model checking foundation |
| Cunningham 1982 | Split decomposition theory |

## 12. Key Quotes

> "We investigate what happens when a graph contains a modulator which is large but 'well-structured' (in the sense of having bounded rank-width)."

> "The parameters derived from such well-structured modulators are more powerful for fixed-parameter algorithms than the cardinality of modulators and rank-width itself."

> "We prove that this result is tight in the sense that it cannot be generalized to LinEMSO problems."

## 13. Summary

1. **Novel Parameter:** Well-structure number combines modulators with rank-width
2. **Strictly More Powerful:** $\text{wsn}_\mathcal{H}$ can be exponentially smaller than both $\text{rw}$ and $\text{mod}_\mathcal{H}$
3. **Computable:** FPT algorithm for finding well-structured modulators
4. **Applications:** MinVC, MaxClq, MSO model checking all FPT
5. **Tight Characterization:** LinEMSO optimization remains hard
6. **Practical Impact:** Extends tractability to graphs with local structure

**Status:** Completed
