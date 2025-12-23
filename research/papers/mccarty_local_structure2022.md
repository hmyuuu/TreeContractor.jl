# Analysis: Local Structure for Vertex-Minors (McCarty 2022)

**Presentation:** "Local Structure for Vertex-Minors"
**Author:** Rose McCarty (Joint work with Jim Geelen and Paul Wollan)
**Year:** 2022 (October 19th presentation)
**Task:** T-080
**Agent:** PhD-Theory

## 1. Overview

This research aims to develop a **vertex-minor analog** of the Robertson-Seymour Graph Minors Structure Theorem. The key goals:
1. Prove Geelen's Conjecture on structure of vertex-minor-closed classes
2. Potentially resolve Oum's Conjecture on finite forbidden vertex-minors
3. Establish theoretical foundation for vertex-minor theory

## 2. Background: Graph Minors Theory

### 2.1 Kuratowski's Theorem
> A graph is planar iff it has no $K_5$ or $K_{3,3}$ minor.

### 2.2 Graph Minors Theorem (Robertson & Seymour 2004)
> Every minor-closed class has finitely many forbidden minors.

### 2.3 Minor Structure Theorem (Robertson & Seymour 2003)
> Graphs in any proper minor-closed class "decompose" into parts that "almost embed" in a surface of bounded genus.

This is the **sparse** theory (Nešetřil & Ossona de Mendez).

## 3. The Dense Analog: Vertex-Minors

### 3.1 Key Correspondence
| Sparse World | Dense World |
|--------------|-------------|
| Minors | Vertex-minors |
| Planar graphs | Circle graphs |
| Grid minor | Comparability grid vertex-minor |
| Surfaces | Tour graphs |
| Tree-width | Rank-width |

### 3.2 Vertex-Minor Operations
**Definition:** The vertex-minors of $G$ are graphs obtainable by:
1. **Vertex deletion:** $G - u$
2. **Local complementation:** $G * v$ = replace $G[N(v)]$ with its complement

**Key fact:** Vertex-minors = induced subgraphs of locally equivalent graphs.

### 3.3 Local Equivalence
Graphs are **locally equivalent** if one can be obtained from the other by a sequence of local complementations.

**Properties:**
- $G * v * v = G$ (involution)
- Locally equivalent graphs have **same cut-rank function**
- Important for **quantum computing** (graph states)

## 4. Circle Graphs

### 4.1 Bouchet's Theorem
> A graph is a circle graph iff it has no $W_5$, $\hat{W}_6$, or $W_7$ vertex-minor.

### 4.2 Geelen-Oum's Theorem (Pivot-Minors)
> A graph is a circle graph iff it has no $W_5, W_6, \ldots$ pivot-minor.

### 4.3 Tour Graph Representation
For circle graph $G$:
1. Take chord diagram as 3-regular graph
2. Contract each chord → **tour graph**
3. Tour graph has specified Eulerian circuit

**Theorem (Kotzig, Bouchet):**
> For prime circle graphs $H$ and $G$, $H$ is a vertex-minor of $G$ iff tour$(H)$ can be obtained from tour$(G)$ by splitting off vertices.

## 5. Main Conjectures

### 5.1 Oum's Conjecture (2017)
> Every vertex-minor-closed class has finitely many forbidden vertex-minors.

### 5.2 Geelen's Conjecture (Structure)
> The graphs in any proper vertex-minor-closed class "decompose" into parts that are "almost" circle graphs.

### 5.3 Oum's Pivot-Minor Conjecture (2009)
> A class of graphs has bounded rank-width iff it does not contain all bipartite circle graphs as pivot-minors.

## 6. Key Results

### 6.1 Grid Theorem Analog (Geelen, Kwon, McCarty, & Wollan 2020)
> A class of graphs has bounded rank-width iff it does not contain all circle graphs as vertex-minors.

**Equivalent characterization:**
- Excludes comparability grid as vertex-minor ⟺ Bounded rank-width

### 6.2 Local Structure Theorem (Geelen, McCarty, & Wollan)
> For any proper vertex-minor-closed class $\mathcal{F}$ and any $G \in \mathcal{F}$ with a prime circle graph containing a comparability grid, the rest of $G$ "almost attaches" in a way that is "mostly compatible".

This is the **vertex-minor analog of the Flat Wall Theorem**.

## 7. Proof Approach

### 7.1 Strategy
1. Assume favorite circle graph is an induced subgraph
2. Add more vertices as long as they still induce a circle graph
3. Analyze how remaining vertices attach

### 7.2 Neighborhood Encoding
- If vertex $x$ can be added as a chord → neighborhood encoded by **two arcs**
- Any neighborhood can be encoded by **even number of arcs**
- Can locally complement at vertices in the circle graph

### 7.3 Arc Representation
Vertices outside the circle graph have neighborhoods describable by:
- Even number of arcs on the circle
- Bounded number implies "almost circle graph" structure

## 8. Connections to Rank-Width

### 8.1 Rank-Width Definition
$$\text{rw}(G) = \min_T \max_{e \in E(T)} \text{cutrk}(X_e)$$
where $T$ is subcubic tree with leaves $V(G)$.

### 8.2 Cut-Rank Function
$$\text{cutrk}(X) = \text{rank}(\text{adj}[X, \overline{X}]) \text{ over GF(2)}$$

**Key property:** Symmetric: $\text{cutrk}(X) = \text{cutrk}(\overline{X})$.

### 8.3 Relationship
- Locally equivalent graphs have **same cut-rank function**
- Therefore rank-width is a vertex-minor invariant
- Bounded rank-width ⟺ Excludes all circle graphs as vertex-minors

## 9. Quantum Computing Connection

### 9.1 Graph States
Local equivalence classes have nice interpretation for **graph states** in quantum computing (Raussendorf-Briegel, Van den Nest-Dehaene-De Moor).

### 9.2 Geelen's Complexity Conjecture
> If the graph states that can be prepared come from a proper vertex-minor-closed class $\mathcal{F}$, then $\text{BQP}_\mathcal{F} = \text{BPP}$.

This suggests: **Bounded rank-width → classically simulable quantum computation**.

## 10. Implications for Our Implementation

### 10.1 Structural Understanding
- Graphs of bounded rank-width have "almost circle graph" structure
- This explains why certain decomposition strategies work

### 10.2 Obstruction Sets
- Finite obstructions exist (once conjecture proven)
- Can potentially use for recognition algorithms

### 10.3 Circle Graph Detection
- Prime circle graphs play key role
- Tour graph representation useful for vertex-minor operations

### 10.4 Future Algorithm Design
- Local structure theorem could guide heuristics
- "Compatible attachment" patterns may be exploitable

## 11. Open Problems

1. **Prove Geelen's Structure Conjecture** (ongoing)
2. **Prove Oum's Finite Obstruction Conjecture**
3. **Algorithmic implications** of local structure theorem
4. **Complexity of vertex-minor containment** testing

## 12. Key Technical Insights

### 12.1 Prime Circle Graphs
A circle graph is **prime** if it cannot be decomposed as join or union.
- Tour graph is 4-regular for prime circle graphs
- Vertex-minor operations correspond to vertex splitting in tour graphs

### 12.2 Comparability Grid
The **comparability grid** is the key obstruction:
- Contains all bipartite graphs as vertex-minors
- Bounded rank-width ⟺ excludes large comparability grids

### 12.3 Arc Representation
Neighborhoods of external vertices encoded by arcs:
- 2 arcs = can be added as chord (circle graph stays circle)
- 4+ arcs = "external" vertex
- Number of arcs bounded ⟹ structured attachment

## 13. Relationship to Other Papers

| Paper | Relationship |
|-------|--------------|
| Oum 2005 | Vertex-minor characterization of rank-width |
| Oum-Seymour 2006 | Rank-width approximation |
| Bouchet 1987 | Isotropic systems, circle graphs |
| Geelen-Kwon-McCarty-Wollan 2020 | Grid theorem for vertex-minors |

## 14. Key Quotes

> "What are the 'dense' analogs?" (of minor structure theory)

> "The graphs in any proper vertex-minor-closed class 'decompose' into parts that are 'almost' circle graphs."

> "Locally equivalent graphs have the same cut-rank function."

## 15. Summary

1. **Goal:** Prove vertex-minor structure theorem (dense analog of RS theory)
2. **Key concept:** Circle graphs replace planar graphs
3. **Main tool:** Local complementation and tour graphs
4. **Connection:** Rank-width ↔ vertex-minor theory
5. **Application:** Quantum computing complexity, algorithm design
6. **Status:** Ongoing project with significant progress (Local Structure Theorem)

**Status:** Completed
