# Analysis: Monoidal Width (Di Lavore & Sobociński 2023)

**Paper:** "Monoidal Width: Capturing Rank Width"
**Authors:** Elena Di Lavore, Paweł Sobociński
**Year:** 2023 (LMCS / EPTCS)
**Task:** T-070
**Agent:** PhD-Theory

## 1. The Big Idea: Category Theory
Standard graph parameters (Tree-Width, Rank-Width) are usually defined via combinatorial decompositions or algebraic terms.
This paper unifies them using **Monoidal Categories** (categories with a tensor product).
-   **Morphism:** A graph is viewed as a morphism $X \to Y$ (processes with inputs/outputs).
-   **Decomposition:** A term in the language of the monoidal category (Composition + Tensor).
-   **Width:** Measures the "complexity" of the interfaces (objects) used in the decomposition.

## 2. Capturing Rank-Width
The authors show that by choosing the right category:
-   **Category of Matrices (Mat):** Monoidal Width $\cong$ Rank-Width.
-   **Category of Cospans (Cospan):** Monoidal Width $\cong$ Tree-Width / Branch-Width.

## 3. Why This Matters
It provides a **Compositional Framework**.
-   **Algorithm Design:** Instead of designing separate DPs for Tree-Width and Rank-Width, one can design a generic "Monoidal DP" that works for any width measure defined this way.
-   **Parsing:** The "Parse Tree" we use (Ganian & Hlineny) is essentially a "Monoidal Decomposition".
-   **Verification:** It proves that Rank-Width is "natural" — it's just the width measure associated with Linear Algebra (Matrices), just as Tree-Width is associated with Topology (Cospans).

## 4. Application
-   **Refactoring:** We could refactor `ParseTrees.jl` to be more generic. Instead of hardcoding GF(2) logic, we could have a `AbstractMonoidalCategory` interface.
    -   `compose(A, B)`
    -   `tensor(A, B)`
    -   `width(Object)`
-   This would allow us to switch between Rank-Width and other widths (e.g., boolean-width) just by changing the underlying algebra.

## 5. Conclusion
Di Lavore & Sobociński (2023) offers a powerful abstraction. For V1, it's overkill, but for V2 (Generic Tensor Network Solver), adopting a Monoidal Category architecture would be the "Correct" software engineering approach.
