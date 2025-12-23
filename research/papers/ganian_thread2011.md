# Analysis: Thread Graphs, Linear Rank-Width and Algorithmic Applications (Ganian 2011)

**Paper:** "Thread Graphs, Linear Rank-Width and Their Algorithmic Applications"
**Author:** Robert Ganian
**Year:** 2011 (IWOCA 2010, LNCS 6460)
**Task:** T-073
**Agent:** PhD-Theory

## 1. Overview

This paper provides:
1. **Characterization:** Linear rank-width 1 graphs = Thread graphs
2. **Algorithms:** Polynomial-time solutions for problems NP-hard on trees
3. **Structure:** Constructive definition via vertex creation sequence

## 2. Linear Rank-Width Definition

### 2.1 Standard Rank-Width
Rank-decomposition $(T, \mu)$: subcubic tree $T$ + bijection $\mu: V \to \text{leaves}(T)$

### 2.2 Linear Rank-Width
**Definition 2.3:** A rank-decomposition $(T, \mu)$ is **linear** if $T$ is a **caterpillar** (path with pendant vertices).

$$\text{lrw}(G) = \min \{\text{width of linear rank-decompositions}\}$$

### 2.3 Key Properties
**Theorem 2.4:**
- Linear rank-width of **paths** = 1
- Linear rank-width of **cliques** = 1
- Linear rank-width of **trees** = **unbounded**

This shows linear rank-width is between path-width and rank-width.

## 3. Thread Graphs

### 3.1 Constructive Definition
**Definition 3.1:** A **thread graph** is constructed by creating vertices with attributes:

1. **Active (𝒜) or Passive (𝒫):**
   - 𝒜: Can receive edges from future vertices
   - 𝒫: Cannot receive new edges

2. **Join (𝒥) or Disconnect (𝒟):**
   - 𝒥: Connect to ALL currently active vertices
   - 𝒟: No edges created

3. **Reset (ℛ) or Normal:**
   - ℛ: Change all 𝒜 to 𝒫
   - Normal: Keep activity status

### 3.2 Creation Rules
- **𝒟 vertex:** No new edges
- **𝒥 vertex:** Edge to every currently 𝒜 vertex
- **ℛ vertex:** All previous 𝒜 → 𝒫

### 3.3 Main Characterization
**Theorem 3.2:**
> A graph $G$ has **linear rank-width 1** if and only if $G$ is a **thread graph**.

**Proof Sketch:**
- ($\Rightarrow$) From linear decomposition, extract creation sequence
  - Bipartite matrix rank 1 → identical rows for 𝒜 vertices
- ($\Leftarrow$) From thread graph, construct linear decomposition
  - 𝒫 rows = zeros, 𝒜 rows = identical

## 4. Thread Graph Structure

### 4.1 Clusters
A **cluster** $C_i$ contains:
- Two consecutive ℛ vertices (ℛ$_i$ and ℛ$_{i+1}$)
- All vertices created between them

### 4.2 Cluster Isolation
**Proposition 3.3:**
1. ℛ$_i$ only adjacent to vertices in $C_i$ and $C_{i-1}$
2. ℛ$_{i+1}$ only adjacent to vertices in $C_i$ and $C_{i+1}$
3. Non-ℛ vertices only adjacent within their cluster

### 4.3 Intra-Cluster Structure
**Proposition 3.4:** Within a cluster:
1. 𝒜𝒥 vertices form a **clique**
2. 𝒫𝒥 adjacent to all earlier 𝒜𝒥 and 𝒜𝒟
3. 𝒜𝒟 adjacent to all later 𝒜𝒥
4. No other edges

### 4.4 Computation
**Theorem 3.5:** Creating sequence computable in **polynomial time**:
1. Identify ℛ vertices (cut vertices)
2. ℛ vertices form a path
3. For each cluster, determine 𝒫𝒥/𝒜𝒥/𝒜𝒟 from adjacencies

## 5. Algorithmic Applications

### 5.1 Bandwidth 2-Approximation

**Definition 4.1:** Bandwidth = min over all orderings $f: V \to \{1, \ldots, |V|\}$ of:
$$\max_{\{u,v\} \in E} |f(u) - f(v)|$$

**Theorem 4.4:** 2-approximation for bandwidth on thread graphs in polynomial time.

**Algorithm:**
- Order clusters sequentially
- Within cluster: 𝒫𝒥 → ℛ$_i$ → (𝒜𝒟 ∪ 𝒜𝒥) → ℛ$_{i+1}$
- Use Lemma 4.3 on bipartite structure

**Context:** Bandwidth is NP-hard to 2-approximate even on **trees**!

### 5.2 Dominating Bandwidth

**Definition 4.5:** Given minimum dominating set $X$:
- Each $v \in X$ gets unique label
- Each $u \notin X$ gets label of adjacent dominator
- Minimize bandwidth

**Theorem 4.7:** Dominating bandwidth is **NP-hard on trees**.

**Theorem 4.8:** Dominating bandwidth of thread graphs is **always 1**.

**Proof:** ℛ vertices dominate efficiently; careful label assignment achieves bandwidth 1.

### 5.3 Path-Width Computation

**Lemma 4.10:** Path-width of single-cluster thread graph computable in poly-time.

**Theorem 4.11:** Path-width of thread graphs computable in **polynomial time**.

**Algorithm:**
1. Compute path-width of each cluster separately
2. Path-width of $G$ = max over clusters
3. Key insight: 𝒜𝒥 vertices form clique → all in some bag

**Context:** Path-width is NP-hard on distance-hereditary graphs (rw ≤ 1)!

## 6. Comparison Table

| Problem | Trees | Rank-Width 1 | Linear RW 1 |
|---------|-------|--------------|-------------|
| Bandwidth | NP-hard (2-approx) | NP-hard | **P** (2-approx) |
| Dominating BW | NP-hard | ? | **P** (always 1) |
| Path-width | P | NP-hard | **P** |

## 7. Width Parameter Hierarchy

```
               Paths
                 ↓  pw ≤ 1
               Trees
                 ↓  tw ≤ 1
         Distance-Hereditary
                 ↓  rw ≤ 1
           Thread Graphs ←── lrw ≤ 1 (NEW)
                 ↓
              Cliques
```

**Theorem 2.1:**
- $\text{rw}(G) \leq \text{cw}(G) \leq 2^{\text{rw}(G)+1} - 1$
- $\text{rw}(G) \leq \text{tw}(G) + 1 \leq \text{pw}(G) + 1$

## 8. Examples

### 8.1 Thread Graph Construction
Sequence: 𝒜𝒥 𝒜𝒟 𝒫𝒥 𝒜𝒥 𝒜𝒥 𝒜𝒥ℛ 𝒜𝒥 𝒜𝒟 𝒫𝒥 𝒜𝒥

Creates graph with:
- First cluster: 𝒜𝒥 clique + 𝒫𝒥 + 𝒜𝒟 attachments
- Second cluster: Similar structure
- ℛ vertex connects clusters

### 8.2 Linear Decomposition
For $C_5$: Order vertices around cycle
- Bipartite matrices at each edge have rank ≤ 1

## 9. Technical Details

### 9.1 Why Rank 1 → Thread Structure
When bipartite adjacency matrix has rank 1:
- All non-zero rows are identical
- This = all active vertices have same future neighborhood
- Passive vertices have zero rows

### 9.2 Connected Thread Graphs
For connected graphs, only need:
- 𝒜𝒥: Active + Join (main vertices)
- 𝒜𝒟: Active + Disconnect (isolated active)
- 𝒫𝒥: Passive + Join (connects to active)
- 𝒜𝒥ℛ: Reset vertex

## 10. Implications for Our Implementation

### 10.1 LinearRankWidth.jl
- Thread graph characterization validates caterpillar decomposition
- Provides structural understanding of lrw = 1 case
- Algorithm for computing creating sequence

### 10.2 Benchmark Generation
Thread graphs provide:
- Controlled linear rank-width
- Rich structure despite low width
- Test cases for linear decomposition algorithms

### 10.3 Application Classes
Linear rank-width useful for:
- Problems NP-hard on trees but P on thread graphs
- Quantum simulation (caterpillar = MPS)
- Communication networks

## 11. Open Questions (from Paper)

> "Further research in this area should focus on possible parameterized algorithms on linear rank-width – it is not clear whether or how our polynomial algorithms might be extended to graphs of bounded linear rank-width."

## 12. Key Quotes

> "We first provide a characterization of graphs of linear rank-width 1 and then show that on such graphs it is possible to obtain better algorithmic results than on distance hereditary graphs and even trees."

> "The linear rank-width of paths and cliques is 1, and the linear rank-width of trees is not bounded by any constant."

> "A graph $G$ has linear rank-width 1 if and only if $G$ is a thread graph."

## 13. Summary

1. **Characterization:** lrw = 1 ↔ Thread graphs
2. **Structure:** Clusters connected by ℛ vertices
3. **Algorithms:** P for bandwidth (2-approx), dominating BW, path-width
4. **Significance:** Problems NP-hard on trees become tractable
5. **Position:** Between path-width and rank-width in hierarchy

**Status:** Completed
