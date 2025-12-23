# Analysis: Monoidal Width - Capturing Rank Width (Di Lavore & Sobociński 2023)

**Paper:** "Monoidal Width: Capturing Rank Width"
**Authors:** Elena Di Lavore, Paweł Sobociński
**Year:** 2023 (EPTCS, Vol. 380, pp. 268-283, ACT 2022)
**Task:** T-069
**Agent:** PhD-Theory

## 1. Overview

This paper establishes a **category-theoretic foundation** for rank-width by showing that:
- Monoidal width in a suitable prop of graphs captures rank-width
- The relationship is: $\frac{1}{2} \cdot \text{rwd}(G) \leq \text{mwd}(g) \leq 2 \cdot \text{rwd}(G)$

**Key Insight:** Graph width measures are instances of a single abstract concept - monoidal width in monoidal categories.

## 2. Motivation: Compositional Semantics

### The Cost of Composition
In monoidal categories as "algebras of processes":
- **Sequential composition** ($f ; g$): Often requires resource sharing → computational cost
- **Parallel composition** ($f \otimes g$): No resource sharing → typically "free"

**Question:** What is the most efficient way to decompose a morphism?

### Unifying Framework
Previous work [Di Lavore & Sobociński 2022] captured:
- **Tree-width** via cospans of graphs
- **Path-width** via linear variant
- **Branch-width** via symmetric variant

This paper adds **rank-width** using matrix algebra.

## 3. Monoidal Width Definition

### 3.1 Monoidal Decomposition
For monoidal category $\mathcal{C}$ with atoms $\mathcal{A}$:

$$D_f ::= (f) \mid (d_1, \otimes, d_2) \mid (d_1, ;_X, d_2)$$

where:
- $(f)$: Leaf labeled with atom $f \in \mathcal{A}$
- $(d_1, \otimes, d_2)$: Parallel composition
- $(d_1, ;_X, d_2)$: Sequential composition along object $X$

### 3.2 Weight Function
$w: \mathcal{A} \cup \{\otimes\} \cup \text{Obj}(\mathcal{C}) \to \mathbb{N}$ such that:
- $w(X \otimes Y) = w(X) + w(Y)$
- $w(\otimes) = 0$ (parallel is free)

### 3.3 Width of Decomposition
$$\text{wd}(d) = \max_{v \in \text{vertices}(S)} w(\mu(v))$$

where $(S, \mu)$ is the labeled tree representation.

### 3.4 Monoidal Width
$$\text{mwd}(f) := \min_{d \in D_f} \text{wd}(d)$$

## 4. Matrices and Bialgebra

### 4.1 Category of Matrices
$\text{Mat}_\mathbb{N}$:
- Objects: Natural numbers
- Morphisms $n \to m$: $m \times n$ matrices over $\mathbb{N}$
- Composition: Matrix multiplication
- Monoidal product: Block diagonal $A \oplus B = \begin{pmatrix} A & 0 \\ 0 & B \end{pmatrix}$

### 4.2 Bialgebra Prop
**Proposition 3.2:** $\text{Mat}_\mathbb{N} \cong \text{Bialg}$

Generators:
- $\Delta: 1 \to 2$ (copy/diagonal)
- $\epsilon: 1 \to 0$ (discard)
- $\nabla: 2 \to 1$ (merge/codiagonal)
- $\eta: 0 \to 1$ (create)

Subject to bialgebra axioms (copy + merge compatibility).

### 4.3 Key Lemma (Rank as Composition)
**Lemma 3.1:**
$$\min\{k \in \mathbb{N} : A = B ;_k C\} = \text{rank}(A)$$

Sequential composition minimized = matrix rank!

### 4.4 Monoidal Width of Matrices

**Theorem 3.12:**
For $f = f_1 \otimes \cdots \otimes f_k$ (unique $\otimes$-decomposition):
$$\max_i \text{rank}(\text{Mat}(f_i)) \leq \text{mwd}(f) \leq \max_i \text{rank}(\text{Mat}(f_i)) + 1$$

## 5. The Prop of Graphs (Grph)

### 5.1 Graphs with Boundaries
A graph with boundaries $g: n \to m$ consists of:
- $[G]$: Adjacency matrix (up to symmetry)
- $L \in \text{Mat}_\mathbb{N}(k, n)$: Left boundary connections
- $R \in \text{Mat}_\mathbb{N}(k, m)$: Right boundary connections
- $P \in \text{Mat}_\mathbb{N}(m, n)$: Passing wires
- $[F]$: Self-loops on right boundary

### 5.2 Definition of Grph
**Definition 5.2:** Add to Bialg:
- $\cup: 0 \to 2$ (cup)
- $\text{v}: 1 \to 0$ (vertex)

With equations making cup = transpose and handling adjacency symmetry.

### 5.3 Normal Form
Every morphism in Grph has normal form as a string diagram with vertex block $G$, boundary matrices $L, R$, passing wires $P$, and feedback $F$.

## 6. Recursive Rank Decomposition

### 6.1 Definition
Intermediate step between rank decomposition and monoidal decomposition.

$T \in T_\Gamma$ where:
- Base: $(Γ)$ if $Γ$ has at most one vertex
- Recursive: $(T_1, Γ, T_2)$ where $T_i$ are decompositions of subgraphs

### 6.2 Width
$$\text{wd}(T) = \max_{T' \text{ subtree}} \text{rank}(\text{boundary}(\lambda(T')))$$

### 6.3 Equivalence to Rank Width

**Theorem 4.13:**
$$\text{rwd}(G) \leq \text{rrwd}(Γ) \leq \text{rwd}(G) + \text{rank}(B)$$

## 7. Main Result

**Theorem 5.12:**
For graph $G$ with corresponding morphism $g = ([G], !, !, (), [()]) \in \text{Grph}$:

$$\frac{1}{2} \cdot \text{rwd}(G) \leq \text{mwd}(g) \leq 2 \cdot \text{rwd}(G)$$

### 7.1 Upper Bound (Prop 5.8)
Given recursive rank decomposition $T$ of $Γ$, construct monoidal decomposition $\mathcal{R}^\dagger(T)$ with:
$$\text{wd}(\mathcal{R}^\dagger(T)) \leq 2 \cdot \text{wd}(T)$$

### 7.2 Lower Bound (Prop 5.11)
Given monoidal decomposition $d$ of $g$, construct recursive rank decomposition $\mathcal{R}(d)$ with:
$$\text{wd}(\mathcal{R}(d)) \leq 2 \cdot \max\{\text{wd}(d), \text{rank}(L), \text{rank}(R)\}$$

## 8. Key Technical Tools

### 8.1 Coherent Copying (Lemma 2.9)
Copying $n$ wires costs at most $n + 1$:
$$\text{mwd}(\Delta_n) \leq n + 1$$

### 8.2 Discarding Preserves Width (Lemma 3.8)
Discarding outputs or zero-ing inputs doesn't increase monoidal width.

### 8.3 Unique $\otimes$-Decomposition (Prop 3.11)
In categories with initial-terminal unit and UFM objects, every morphism has unique $\otimes$-decomposition.

## 9. Comparison to Traditional Approach

| Aspect | Traditional | Monoidal Width |
|--------|-------------|----------------|
| Framework | Ad hoc trees | Monoidal categories |
| Decomposition | Binary tree of cuts | String diagram factorization |
| Width measure | Max cut-rank | Max boundary size |
| Applicability | Graphs only | Any monoidal category |

## 10. Implications for Our Implementation

### 10.1 ParseTrees.jl
- Bilinear products in parse trees = sequential composition in Grph
- The $2\times$ factor explains why our algebraic approach is near-optimal

### 10.2 DPSolver.jl
- DP on parse trees = compositional semantics computation
- Width bounds translate directly to runtime bounds

### 10.3 Future: Categorical Optimization
- Could formulate decomposition search as optimization in Grph
- Generic "Monoidal DP" framework possible

### 10.4 Refactoring Potential (V2)
Could refactor to generic `AbstractMonoidalCategory` interface:
- `compose(A, B)`
- `tensor(A, B)`
- `width(Object)`

This would allow switching between Rank-Width and other widths.

## 11. Related Width Measures

The monoidal width framework also captures:
- **Tree-width**: Cospans of graphs, symmetric monoidal
- **Path-width**: Linear variant of cospans
- **Branch-width**: Symmetric cospans

**Open problems:**
- Clique-width via monoidal width?
- Twin-width via monoidal width?
- Hypergraph widths?
- Matroid branch-width?

## 12. Category Theory Background

### 12.1 Props
- Symmetric strict monoidal categories
- Objects = natural numbers
- $\otimes$ on objects = addition

### 12.2 String Diagrams
Visual calculus for morphisms:
- Vertical = sequential composition
- Horizontal = parallel composition
- Wires = identity morphisms

### 12.3 Bialgebra
Algebraic structure combining:
- Monoid: $(\nabla, \eta)$ - merge + unit
- Comonoid: $(\Delta, \epsilon)$ - copy + discard
- Compatibility axioms

## 13. Why Rank-Width is "Natural"

The paper proves that Rank-Width is the canonical width for **linear algebra**:
- Tree-Width ↔ Topology (Cospans)
- **Rank-Width ↔ Linear Algebra (Matrices)**
- Path-Width ↔ Linear Topology

This explains why GF(2) matrices are central to rank-width theory.

## 14. Key Quotes

> "Monoidal width was recently introduced by the authors as a measure of the complexity of decomposing morphisms in monoidal categories."

> "We show that here monoidal width captures rank width: a measure of graph complexity that has received much attention in recent years."

> "One of our contributions is to exhibit monoidal width as a unifying framework for graph measures based on a notion of decomposition."

## 15. Significance for Rank-Width Theory

1. **Algebraic Foundation:** Provides rigorous categorical semantics
2. **Generalization:** Suggests rank-width is natural in broader contexts
3. **Algorithmic Insight:** Decomposition = string diagram factorization
4. **Compositionality:** Width behaves well under graph operations
5. **Verification:** Parse trees are "monoidal decompositions"

**Status:** Completed
