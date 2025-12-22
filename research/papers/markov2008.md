# Analysis: Simulating quantum computation by contracting tensor networks

**Paper ID:** [Markov 2008]
**Authors:** Igor L. Markov and Yaoyun Shi
**Year:** 2008 (Preprint 2005)
**Journal:** SIAM Journal on Computing

## Mathematical Definitions

### Line Graph and Treewidth
The paper establishes a rigorous link between tensor network contraction and graph theory via the **line graph**.
- Let $G$ be the graph representing the tensor network, where vertices are tensors and edges are indices.
- The **line graph** $L(G)$ is constructed where:
  - Vertices of $L(G)$ correspond to edges of $G$ (indices of the TN).
  - Edges of $L(G)$ connect two vertices if the corresponding edges in $G$ share a common tensor endpoint.
- **Treewidth Connection:** The complexity of contracting the tensor network is governed by the **treewidth of its line graph** $tw(L(G))$.

### Contraction Sequence
A contraction sequence corresponds to an elimination ordering of the vertices of $L(G)$ (which are the indices of the TN).
- Contracting an index (summing over it) corresponds to removing a vertex from $L(G)$.

## Algorithmic Content

### Tree Decomposition to Contraction
**Theorem:** Finding an optimal contraction sequence is equivalent to finding a tree decomposition of the line graph $L(G)$ with minimum width.
- **Input:** A tensor network graph $G$.
- **Step 1:** Construct $L(G)$.
- **Step 2:** Compute a tree decomposition of $L(G)$ (an NP-complete problem, but good heuristics like QuickBB exist).
- **Step 3:** Convert the decomposition into a contraction order.

### Complexity Bounds
If the line graph $L(G)$ has treewidth $d$, the tensor network can be contracted in time:
$$ T^{O(1)} \exp[O(d)] $$
where $T$ is the number of tensors (gates).
For quantum circuits with logarithmic treewidth ($d = O(\log T)$), simulation is polynomial in $T$.

## Tensor Network Applications

### Quantum Circuit Simulation
- This work was pivotal in showing that "weakly entangled" quantum circuits (those with low treewidth line graphs) can be classically simulated efficiently.
- It provides a universal method for optimizing contraction orders, replacing ad-hoc heuristics with structural graph theory.

### Relation to Rank-Width
- **Contrast:** Markov & Shi focus on **treewidth of the line graph**. Oum & Seymour focus on **rank-width of the original graph**.
- **Theoretical Comparison:** Rank-width is bounded by clique-width, and clique-width is closely related to the treewidth of the line graph (though not identical). Rank-width is generally a "smaller" parameter (bounded by treewidth but not vice versa in dense cases), potentially offering better contraction paths for dense tensors if rank-decomposition is used directly.

## Critical Evaluation

### Novelty
- First rigorous proof mapping tensor contraction complexity to treewidth.
- Bridged the gap between Quantum Information and Structural Graph Theory.

### Impact
- Highly influential; the "line graph treewidth" approach is now standard in TN software (e.g., Cotengra, ITensor).
- Cited by virtually all subsequent work on TN contraction ordering (Gray 2018, Dumitrescu 2018).

### Open Questions
- The approach assumes tensors are "dense" (full rank). It does not exploit the internal low-rank structure of tensors (e.g., if a tensor is itself an MPS). This is where **rank-width** (which measures cut-rank directly) could be superior.
