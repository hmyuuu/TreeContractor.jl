# Analysis: Short Survey of Obstruction to Rank-width and Linear Rank Width (Fujita 2023)

**Paper:** "Short Survey of Obstruction to Rank-width and Linear Rank Width"
**Author:** Takaaki Fujita
**Year:** 2023 (Int. J. Adv. Multidisc. Res. Stud., Vol. 4(4), pp. 592-596)
**Task:** T-075
**Agent:** PhD-Theory

## 1. Overview

A concise survey organizing the **obstruction theory** for rank-width and linear rank-width:
- Tangles and ultrafilters for rank-width
- Obstacles and linear tangles for linear rank-width
- Duality theorems connecting obstructions to width

## 2. Background: Cut-Rank Function

**Definition 2:**
For graph $G$ and $A \subseteq V(G)$:
$$\rho(A) = \text{rank}(X_A) \text{ over GF(2)}$$
where $X_A$ is the $|A| \times |V(G) \setminus A|$ biadjacency matrix.

**Key Properties:**
1. **Symmetry:** $\rho(A) = \rho(V(G) \setminus A)$
2. **Submodularity:** $\rho(A) + \rho(B) \geq \rho(A \cup B) + \rho(A \cap B)$

## 3. Obstructions to Rank-Width

### 3.1 ρ-Tangle (Definition 3)
A **$\rho$-tangle of order $k+1$** is a set $\mathcal{T}$ of subsets of $V(G)$ satisfying:

**(T1)** If $\rho(A) \leq k$, then $A \in \mathcal{T}$ or $V(G) \setminus A \in \mathcal{T}$

**(T2)** If $A, B, C \in \mathcal{T}$, then $A \cup B \cup C \neq V(G)$

**(T3)** For all $v \in V(G)$: $V(G) \setminus \{v\} \notin \mathcal{T}$

### 3.2 ρ-Ultrafilter (Definition 4)
A **$\rho$-ultrafilter of order $k+1$** is a set $\mathcal{S}$ satisfying:

**(F1)** $A, B \in \mathcal{S}$ and $\rho(A \cap B) \leq k$ $\Rightarrow$ $A \cap B \in \mathcal{S}$

**(F2)** $A \in \mathcal{S}$, $A \subseteq B$, $\rho(B) \leq k$ $\Rightarrow$ $B \in \mathcal{S}$

**(F3)** $\emptyset \notin \mathcal{S}$

**(F4)** If $\rho(A) \leq k$, then $A \in \mathcal{S}$ or $V(G) \setminus A \in \mathcal{S}$

### 3.3 Duality Theorem
**Theorem 5 (Robertson-Seymour):**
> A graph $G$ has a $\rho$-tangle (or $\rho$-ultrafilter) of order $k$ if and only if $\text{rw}(G) \geq k$.

## 4. Obstructions to Linear Rank-Width

### 4.1 ρ-Obstacle (Definition 6)
A **$\rho$-obstacle of order $k+1$** is a set $\mathcal{O}$ satisfying:

**(O1)** For all $A \in \mathcal{O}$: $\rho(A) \leq k$

**(O2)** If $A \subseteq B$, $B \in \mathcal{O}$, $\rho(A) \leq k$, then $A \in \mathcal{O}$

**(O3)** If $A \cup B \cup C = V(G)$, $A \cap B = \emptyset$, $\rho(A) \leq k$, $\rho(B) \leq k$, $|C| \leq 1$,
then exactly one of $A, B$ is in $\mathcal{O}$

### 4.2 ρ-Single-Ultrafilter (Definition 7)
A **$\rho$-single-ultrafilter of order $k+1$** is a set $\mathcal{S}$ satisfying:

**(S1)** For $A \in \mathcal{S}$, $v \in V(G)$: if $\rho(\{v\}) \leq k$ and $\rho(A \cap (V(G) \setminus \{v\})) \leq k$,
then $A \cap (V(G) \setminus \{v\}) \in \mathcal{S}$

**(S2)** $A \in \mathcal{S}$, $A \subseteq B$, $\rho(B) \leq k$ $\Rightarrow$ $B \in \mathcal{S}$

**(S3)** $\emptyset \notin \mathcal{S}$

**(S4)** If $\rho(A) \leq k$, then $A \in \mathcal{S}$ or $V(G) \setminus A \in \mathcal{S}$

### 4.3 ρ-Linear-Tangle (Definition 8)
A **$\rho$-linear-tangle of order $k+1$** is a set $\mathcal{L}$ satisfying:

**(L1)** If $\rho(A) \leq k$, then $A \in \mathcal{L}$ or $V(G) \setminus A \in \mathcal{L}$

**(L2)** If $A, B \in \mathcal{L}$ and $\rho(\{v\}) \leq k$, then $A \cup B \cup \{v\} \neq V(G)$

**(L3)** For all $v \in V(G)$: $V(G) \setminus \{v\} \notin \mathcal{L}$

### 4.4 Duality Theorem
**Theorem 9 (Fomin-Thilikos):**
> A graph $G$ has a $\rho$-obstacle (or $\rho$-linear-tangle, or $\rho$-single-ultrafilter) of order $k$ if and only if $\text{lrw}(G) \geq k$.

## 5. Comparison: Tangle vs Linear-Tangle

| Axiom | Tangle (T2) | Linear-Tangle (L2) |
|-------|-------------|---------------------|
| Union | $A \cup B \cup C \neq V$ | $A \cup B \cup \{v\} \neq V$ |
| Constraint | Any three sets | Two sets + single vertex |

The key difference: Linear tangle has a **weaker** union axiom, allowing only single-vertex "third set."

## 6. Relationship to Filters

### 6.1 Boolean Algebra Filters
In Boolean algebra $(X, \cup, \cap)$, a **filter** $\mathcal{F}$ satisfies:
- (FB1) $A, B \in \mathcal{F}$ $\Rightarrow$ $A \cap B \in \mathcal{F}$
- (FB2) $A \in \mathcal{F}$, $A \subseteq B$ $\Rightarrow$ $B \in \mathcal{F}$
- (FB3) $\emptyset \notin \mathcal{F}$

A **maximal filter** is an **ultrafilter**, satisfying:
- (FB4) For all $A \subseteq X$: either $A \in \mathcal{F}$ or $X \setminus A \in \mathcal{F}$

### 6.2 Connection
The $\rho$-ultrafilter generalizes Boolean algebra ultrafilters by:
- Adding rank condition $\rho(A) \leq k$ to axioms
- Restricting to subsets of bounded cut-rank

## 7. Summary Table

| Obstruction | Width Measure | Key Axiom |
|-------------|---------------|-----------|
| $\rho$-tangle | Rank-width | $A \cup B \cup C \neq V$ |
| $\rho$-ultrafilter | Rank-width | Closed under $\cap$ |
| $\rho$-obstacle | Linear rw | Exactly one of $A, B \in \mathcal{O}$ |
| $\rho$-linear-tangle | Linear rw | $A \cup B \cup \{v\} \neq V$ |
| $\rho$-single-ultrafilter | Linear rw | Single-vertex restriction |

## 8. Implications for Our Implementation

### 8.1 Verification
- Can verify decomposition width via obstruction detection
- If tangle of order $k$ found → width $\geq k$

### 8.2 Lower Bounds
- Tangles provide certificates for lower bounds
- Useful for algorithm correctness verification

### 8.3 Future Implementation
```julia
# Check if partition induces tangle
function has_tangle(G, k)
    # Search for set T satisfying (T1), (T2), (T3)
    # Return true if rw(G) ≥ k
end
```

## 9. Future Directions (from Paper)

### 9.1 Hypertree-Width
> "We plan to continue our investigation" into hypertangle/hyperultrafilter for hypertree-width.

### 9.2 Proximity Spaces
Exploring connections between:
- Proximity relations and rank-width
- Clusters and graph decompositions

## 10. Key References

- **Robertson-Seymour 1991:** Original tangle theory for branch-width
- **Fomin-Thilikos 2003:** Linear obstacle theory
- **Diestel-Oum 2021:** Tangle-tree duality in abstract separation systems

## 11. Key Quotes

> "Rank-width, as outlined in [15], stands as a prominent graph width parameter in the realm of graph theory."

> "For an integer k, a graph G has a ρ-tangle (ρ-ultrafilter) of order k if and only if its rank-width is at least k."

> "While it may not present groundbreaking novelty, this concise paper serves the purpose of organizing information."

## 12. Summary

1. **Tangles:** Large "side" selection for low-rank cuts
2. **Ultrafilters:** Closure under intersection for bounded rank
3. **Linear variants:** Weaker union axioms for linear width
4. **Duality:** Obstructions ↔ Width bounds (both directions)
5. **Application:** Certification of lower bounds

**Status:** Completed
