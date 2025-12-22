## Active Queue (Deep Research Focus)

| ID | Priority | Task Description | Assigned To | Status | Tool Calls | Budget | Links |
|----|----------|------------------|-------------|--------|------------|--------|-------|
| T-050 | High | Deep Dive: Jiang et al. 2024 (Positive Bias Contraction) | PhD-Physics | **[Completed]** | 3 | 5 | [Jiang 2024] |
| T-049 | High | Deep Dive: Beni et al. 2025 (Quantum Decoder) | PhD-Physics | **[Completed]** | 3 | 5 | [Beni 2025] |
| T-048 | Medium | Deep Dive: Bergougnoux 2023 (Tight Lower Bounds) | PhD-Theory | **[Completed]** | 3 | 5 | [Bergougnoux 2023] |
| T-047 | High | Deep Dive: Bonnet et al. 2021 (Twin-Width) | PhD-Theory | **[Completed]** | 3 | 5 | [Bonnet 2021] |
| T-044 | Low | Implement SVD-based Cut Heuristic | PhD-Algo | **[Suspended]** | 0 | 5 | [Anand 2025] |
| T-037 | Medium | Documentation and Final Report | PhD-Theory | **[Completed]** | 3 | 10 | [Final] |

## Task Log
| Date | Task ID | Action | Actor | Notes |
|------|---------|--------|-------|-------|
| 2025-12-22 | T-047 | Completed | PhD-Theory | Analyzed Bonnet 2021. Concluded Twin-Width is less relevant for contraction cost than Rank-Width. |
| 2025-12-22 | T-046 | Completed | PhD-Algo | Researched "Prefix Rebuilding" in Korhonen 2024. Confirmed it's an advanced dynamic technique; simpler "Local Refinement" is sufficient for current O(n^2) goals. |
| 2025-12-22 | T-045 | Completed | PhD-Theory | Researched Adler 2017. Identified Canonical Split Decomposition as key for exact DH graph solver. |

## Task Log
| Date | Task ID | Action | Actor | Notes |
|------|---------|--------|-------|-------|
| 2025-12-22 | T-044 | Pending | All Agents | Group Meeting: Anand 2025. Identified "Rank-Expansion" and SVD heuristic. Added to queue. |
| 2025-12-22 | T-037 | Completed | PhD-Theory | Generated `final_report.typ` and `README.md`. Consolidated all findings. |
| 2025-12-22 | T-043 | Completed | PhD-Algo | Implemented `DynamicRankWidth.jl` with `add_edge!` and `DynamicGraph`. Verified incremental P4 and C5 construction. |
| 2025-12-22 | T-042 | Completed | PhD-Algo | Implemented Enhanced Refinement in `LocalSearch.jl`. Now minimizes `Max(LocalEdges)` and breaks ties with `CentralEdge`. Verified on P4 (2->1). |
| 2025-12-22 | T-041 | Completed | PhD-Algo | Implemented `LinearRankWidth.jl`. Solves Caterpillar decomposition (Linear Ordering). Verified on P4, C5, K5. Essential for Quantum Sim. |
| 2025-12-22 | T-040 | Completed | All Agents | Group Meeting: Cheng 2025. Strategy: Add "Linear Rank-Width" mode (Caterpillar) for Quantum Sim. |
| 2025-12-22 | T-039 | Completed | All Agents | Group Meeting: Fomin 2021. Identified "Refinement" as the key to upgrading LocalSearch to O(n^2) 2-Approx. |
| 2025-12-22 | T-038 | Completed | All Agents | Group Meeting: Korhonen 2024. Decided on "Incremental" strategy. Action items for simplified dynamic interface. |
| 2025-12-22 | T-036 | Completed | PhD-Algo | Created `research/demo/run_solver.jl`. Demonstrated end-to-end pipeline on random graph (n=15). Fixed DP cache collision bug in `ParseTrees.jl`. |
| 2025-12-22 | T-035 | Completed | PhD-Algo | Implemented `DPSolver.jl` for MaxCut using GF(2) rank-decomposition. Verified on Bipartite graph (C4). Identified limitations for non-GF(2) structures (K3). |
| 2025-12-22 | T-034 | Completed | PhD-Theory | Analyzed Linear Rank-Width. Confirmed connection to MPS (1D) vs General RW (TTN). Validated solver's generality. |
| 2025-12-22 | T-031 | Completed | PhD-Algo | Implemented `ParseTrees.jl` to convert RankDecomposition to algebraic ParseTree for DP. Verified on P4. |
| 2025-12-22 | T-033 | Completed | PhD-Theory | Analyzed Bergougnoux (2023). Established ETH lower bound $2^{O(k^2)}$ for general graph problems. Quantum Sim remains $2^{O(k)}$. |
| 2025-12-22 | T-032 | Completed | PhD-Physics | Analyzed Cheng et al. (2025). Confirmed "Linear Rank-Width" beats Treewidth for Quantum Sim. Our General Rank-Width is theoretically superior. |
| 2025-12-22 | T-013 | Completed | PhD-Algo | Implemented `LocalSearch.jl` with 3-way split optimization. Verified width reduction on P4 test case (2->1). Integrated into `rank_width()`. |
| 2025-12-22 | T-030 | Completed | PhD-Theory | Analyzed Boolean-width. Confirmed Rank-Width is better for V1 (computability). |
| 2025-12-22 | T-029 | Completed | PhD-Theory | Analyzed Courcelle 2000. Established MSO1 tractability ($O(n)$) for bounded rank-width. |
| 2025-12-22 | T-028 | Completed | PhD-Theory | Confirmed #SAT/MAX-SAT are FPT on Rank-Width. Validated single-exponential dependency. |
| 2025-12-22 | T-027 | Completed | PhD-Physics | Analyzed Ising Model applications. Confirmed rank-decomposition $\equiv$ tensor network contraction. |
| 2025-12-22 | T-026 | Completed | PhD-Algo | Analyzed SOTA (Korhonen et al. 2024). $O(n^{1+o(1)})$ possible but too complex for V1. Queyranne $O(n^3)$ confirmed as good baseline. |
| 2025-12-22 | T-025 | Completed | PhD-Theory | Analyzed Oum 2017. Confirmed NP-hardness and validity of heuristic approach. |
| 2025-12-22 | T-016 | Completed | PhD-Algo | Implemented `Queyranne.jl` with `AbstractSymmetricSubmodularFunction`. Verified with C4, P3 tests. |
| 2025-12-22 | T-024 | Completed | PhD-Algo | Designed Solver API (`solver_api_design.md`). Verified ordering rule. |
| 2025-12-22 | T-022 | Completed | The Writer | Generated report and committed changes. |
| 2025-12-22 | T-023 | Completed | The Writer | Initialized reports directory and Typst templates. |
| 2025-12-22 | T-021 | Completed | PhD-Theory | Formalized "Tree Rotation" as the Local Search move. Analyzed Beyß 2013. |
| 2025-12-22 | T-019 | Completed | PhD-Theory | Updated Essence with Queyranne, Cost Analysis, and Parse Trees. |
| 2025-12-22 | T-020 | Completed | PhD-Theory | Analyzed Hliněný's Parse Tree. Created `hlineny2006.md`. |
| 2025-12-22 | T-018 | Completed | PhD-Theory | Theoretical analysis of RW vs Cost. Created `rank_width_vs_cost.md`. |
| T-017 | High | Deep Dive: Fast FPT Algorithm (Korhonen 2024) | PhD-Algo | **[Completed]** | 00:30 | 01:00 | [Analyzed: Too complex for now] |
| T-015 | High | Deep Dive: Hypergraph Partitioning & Rank-Width (Gray 2018) | PhD-Algo | **[Completed]** | 00:45 | 01:00 | [Context for T-013] |
| T-014 | High | Deep Dive: Oum-Seymour Approximation Algorithm (Theory) | PhD-Theory | **[Completed]** | 00:30 | 01:00 | [Found Queyranne connection] |
| T-012 | High | Validate Hypothesis H1 via Simulation (Linear vs Branching) | PhD-Physics | **[Completed]** | 00:30 | 02:00 | [Prev: T-011] |
| T-011 | High | Formulate Research Questions and Hypothesis | PhD-Theory | **[Completed]** | 01:00 | 01:00 | [Prev: T-010] |
| T-010 | High | Search Zotero for `rank-width` papers and synthesize theoretical essence | PhD-Theory | **[Completed]** | 00:45 | 01:00 | |
| T-009 | Low | Implement Approximate Rank-Decomposition Algorithm | PhD-Algo | **[Completed]** | 00:45 | - | [Initial Heuristic] |
| 2025-12-22 | T-008 | Completed | PhD-Physics | Benchmarked GF(2) vs SVD. Confirmed match for Graph States. |
| 2025-12-22 | T-001 | Completed | PhD-Theory | Analysis of Oum 2006 |
| 2025-12-22 | T-002 | Completed | PhD-Physics | Analysis of Markov 2008 |
| 2025-12-22 | T-003 | Completed | PhD-Algo | Analysis of Gray 2018 |

