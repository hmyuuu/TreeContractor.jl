## Active Queue (Theory Focus)

| ID | Priority | Task Description | Assigned To | Status | Tool Calls | Budget | Links |
|----|----------|------------------|-------------|--------|------------|--------|-------|
| T-032 | High | Research "Breaking the Treewidth Barrier" (Cheng 2025) & Tensor Networks | PhD-Physics | **[Completed]** | 4 | 10 | [Quantum] |
| T-033 | Medium | Research "Tight Lower Bounds" (Bergougnoux 2023) | PhD-Theory | **[Pending]** | 0 | 10 | [Limits] |
| T-031 | Medium | Implement Parse Tree Construction | PhD-Algo | **[Pending]** | 0 | 10 | [Next Step] |
| T-016 | High | Implement Queyranne's Algorithm for Min-Rank Cut | PhD-Algo | **[Completed]** | 12 | 15 | [T-024 Verified] |
| T-024 | High | Validate Implementation Plan for Queyranne Solver | PhD-Algo | **[Completed]** | 5 | 10 | [Pre-Implementation] |

## Task Log
| Date | Task ID | Action | Actor | Notes |
|------|---------|--------|-------|-------|
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

