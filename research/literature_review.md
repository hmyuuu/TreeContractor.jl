# Rank-Width Literature Review and Research Direction

## 1. Executive Summary

The collected bibliography (`ref.bib`) reveals a comprehensive landscape of research centered on **Rank-Width** and its linear variant. The literature spans three main pillars:
1.  **Algorithmic Tractability**: Moving beyond theoretical existence to practical FPT algorithms (from cubic time to almost-linear time).
2.  **Structural Characterizations**: Defining classes via vertex-minors, obstructions, and logic (MSO).
3.  **Cross-Domain Applications**: Emerging connections to Quantum Computing (Tensor Networks) and Matroid Theory.

This review serves as a strategic roadmap to transition from the current basic MaxCut solver to a state-of-the-art Rank-Width engine.

## 2. Categorization of Papers

### A. Algorithms & Complexity (The "How")
Focus: Efficiently computing rank-width and solving problems on graphs of bounded rank-width.
*   **Key Papers**:
    *   `korhonenAlmostlinearTimeParameterized2024`: *Game-changer*. Offers an almost-linear time FPT algorithm, improving on the cubic barrier.
    *   `fominFastFPTApproximationBranchwidth2021`: Fast approximation, breaking the "cubic barrier".
    *   `adlerLinearRankWidthDistanceHereditary2017`: Polynomial algorithms for linear rank-width on specific graph classes.
    *   `oumComputingRankwidthExactly2009`: The baseline for exact computation.
    *   `beyssFastAlgorithmRankWidth2013`: Heuristic approaches (practical for our solver).

### B. Structural Theory (The "What")
Focus: Defining what makes a graph have low rank-width using minors and forbidden structures.
*   **Key Papers**:
    *   `oumRankwidthVertexminors2005`: Fundamental link between rank-width and vertex-minors.
    *   `kanteLinearRankwidthDistancehereditary2017` & `kanteObstructionsMatroidsPathwidth2023`: Identifying obstructions (forbidden minors) for linear rank-width.
    *   `courcelleGraphOperationsCharacterizing2009a`: Algebraic operations (important for parsing/generation).

### C. Logic & Model Checking (The "Why")
Focus: Using rank-width to decide logical properties (MSO).
*   **Key Papers**:
    *   `courcelleSeveralNotionsRankwidth2017`: Theoretical foundations.
    *   `ganianBetterAlgorithmsSatisfiability2010`: Solving SAT/MaxSAT using rank-width.
    *   `bonnetTwinwidthTractableFO2021`: Connecting to the newer "Twin-Width" parameter.

### D. Applications: Quantum & Tensor Networks (The "Future")
Focus: Using rank-width to optimize tensor contractions and quantum circuit simulations.
*   **Key Papers**:
    *   `chengBreakingTreewidthBarrier2025a`: Explicitly argues for Linear Rank-Width over Treewidth for quantum circuits.
    *   `yeTensorNetworkRanks2019`: Generalized rank definitions for tensor networks.
    *   `beniTesseractSearchBasedDecoder2025`: Quantum error correction decoding.

## 3. Strategic Research Direction

Based on this review, we propose the following phased research direction:

### Phase 1: The Algorithmic Core (Immediate Priority)
**Goal**: Upgrade the current heuristic/cubic solver to a state-of-the-art efficient implementation.
*   **Action**: Deep dive into `korhonenAlmostlinearTimeParameterized2024` and `fominFastFPTApproximationBranchwidth2021`.
*   **Outcome**: Implement the "Almost-Linear Time" approximation algorithm. This is critical for scaling beyond small demos.

### Phase 2: Structural Verification (Validation)
**Goal**: Ensure correctness and generate hard test cases.
*   **Action**: Study `oumRankwidthVertexminors2005` and obstruction papers.
*   **Outcome**: Implement a "Vertex-Minor Checker" or obstruction detector to validate rank-width computations.

### Phase 3: Quantum Applications (Expansion)
**Goal**: Apply the solver to a real-world domain.
*   **Action**: Research `chengBreakingTreewidthBarrier2025a`.
*   **Outcome**: Adapt the solver to optimize Quantum Circuit simulation (Tensor Network Contraction ordering).

## 4. Proposed Task List (One-by-One)

We will proceed by researching these papers systematically:

1.  **[High Priority]** `korhonenAlmostlinearTimeParameterized2024`: Understand the dynamic rank-width data structure.
2.  **[High Priority]** `fominFastFPTApproximationBranchwidth2021`: Understand the approximation framework.
3.  **[Medium Priority]** `chengBreakingTreewidthBarrier2025a`: Analyze the link to Quantum Circuits.
4.  **[Medium Priority]** `oumRankwidthVertexminors2005`: Understand vertex-minor operations.
5.  **[Low Priority]** `adlerLinearRankWidthDistanceHereditary2017`: Specific case for distance-hereditary graphs.
