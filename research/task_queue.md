## Active Queue (Deep Research Focus)

| ID | Priority | Task Description | Assigned To | Status | Tool Calls | Budget | Links |
|----|----------|------------------|-------------|--------|------------|--------|-------|
| T-076 | High | Deep Dive: Oum-Seymour (2006) - Approximating Clique-Width & Branch-Width | PhD-Algo | **[Completed]** | 3 | 5 | [Oum-Seymour 2006] |
| T-077 | Medium | Deep Dive: Adler et al. (2017) - Linear RW of Distance-Hereditary I | PhD-Algo | **[Completed]** | 3 | 5 | [Adler 2017] |
| T-078 | Medium | Deep Dive: Eiben et al. (2022) - Unifying Framework for Width Measures | PhD-Theory | **[Completed]** | 3 | 5 | [Eiben 2022] |
| T-079 | Medium | Deep Dive: Fomin-Korhonen (2021) - Fast FPT-Approximation Branchwidth | PhD-Algo | **[Completed]** | 3 | 5 | [Fomin 2021] |
| T-080 | Low | Deep Dive: McCarty - Local Structure for Vertex-Minors | PhD-Theory | **[Pending]** | 0 | 5 | [McCarty] |

## Completed Research Tasks (Recent)

| ID | Priority | Task Description | Assigned To | Status | Tool Calls | Budget | Links |
|----|----------|------------------|-------------|--------|------------|--------|-------|
| T-071 | High | Deep Dive: Oum (2017) - Survey: Algorithmic & Structural Results | PhD-Theory | **[Completed]** | 3 | 5 | [Oum Survey 2017] |
| T-072 | High | Deep Dive: Oum (2009) - Computing Rank-Width Exactly | PhD-Algo | **[Completed]** | 3 | 5 | [Oum Exact 2009] |
| T-073 | Medium | Deep Dive: Ganian (2011) - Thread Graphs & Linear Rank-Width | PhD-Theory | **[Completed]** | 3 | 5 | [Ganian Thread 2011] |
| T-074 | Medium | Deep Dive: Oum - Approximating Rank-Width Quickly | PhD-Algo | **[Completed]** | 3 | 5 | [Oum Approx] |
| T-075 | Low | Deep Dive: Fujita (2023) - Obstruction Survey | PhD-Theory | **[Completed]** | 3 | 5 | [Fujita 2023] |

## Completed Research Tasks (Earlier)

| ID | Priority | Task Description | Assigned To | Status | Tool Calls | Budget | Links |
|----|----------|------------------|-------------|--------|------------|--------|-------|
| T-067 | High | Deep Dive: Courcelle & Kanté (2007) - Bilinear Graph Operations | PhD-Theory | **[Completed]** | 3 | 5 | [Courcelle 2007] |
| T-068 | High | Deep Dive: Oum (2005) - Vertex-Minors & Pivoting (Enhanced) | PhD-Theory | **[Completed]** | 3 | 5 | [Oum 2005] |
| T-069 | Medium | Deep Dive: Di Lavore & Sobociński (2023) - Monoidal Width (Category Theory) | PhD-Theory | **[Completed]** | 3 | 5 | [DiLavore 2023] |
| T-070 | Medium | Deep Dive: Oum - Well-Quasi-Ordering for Rank-Width | PhD-Theory | **[Completed]** | 3 | 5 | [Oum WQO] |
| T-064 | Medium | Deep Dive: Nešetřil et al. (2021) - Rankwidth Meets Stability | PhD-Theory | **[Completed]** | 3 | 5 | [Nešetřil 2021] |
| T-065 | Medium | Deep Dive: Bouchet (1987) - Isotropic Systems | PhD-Theory | **[Completed]** | 3 | 5 | [Bouchet 1987] |
| T-066 | Medium | Deep Dive: Ganian & Hliněný (2010) - Parse Trees & Myhill-Nerode | PhD-Theory | **[Completed]** | 3 | 5 | [Ganian 2010] |

## Deferred / Future Implementation

| ID | Priority | Task Description | Assigned To | Status | Notes |
|----|----------|------------------|-------------|--------|-------|
| T-054 | High | Implement Simulated Annealing in LocalSearch.jl | PhD-Algo | **[Pending]** | Confirmed by Nouwt 2022. High impact. |
| T-062 | High | Implement SVD-based Cut Heuristic | PhD-Algo | **[Pending]** | Confirmed by Anand 2025. |
| T-063 | Medium | Create "Lettericity" Benchmark Generator | PhD-DataScience | **[Pending]** | From Alecu 2025. |

## Task Log
| Date | Task ID | Action | Actor | Notes |
|------|---------|--------|-------|-------|
| 2025-12-23 | T-079 | Completed | PhD-Algo | Analyzed Fomin-Korhonen 2021. BREAKTHROUGH: First sub-cubic rw algorithm! 2^{2^{O(k)}} n² for 2-approx rw (breaks n³ barrier). Key: "Refinement" operations + W-improvement detection + potential function amortization. Also 2^{O(k)} n for graph branchwidth. Framework for general connectivity functions. |
| 2025-12-23 | T-078 | Completed | PhD-Theory | Analyzed Eiben et al. 2022. F-branchwidth unifies treewidth, clique-width, mim-width. KEY: Only 6 si ph classes exist (F∅, F=, F≤, F<, F≠, F*). Only 3 primal families (F=, F≤, F≠) needed for 3-approximation! FPT algorithms for mim-width under tw+Δ, treedepth. Linear kernel for FES. |
| 2025-12-23 | T-077 | Completed | PhD-Algo | Analyzed Adler et al. 2017. Linear RW of distance-hereditary graphs in O(n² log² n). Key innovation: "limbs" for canonical split decompositions. Characterization: ≤2 components with f(B,T)=k, others ≤k-1. Corollary: matroid path-width for bw≤2. Path-width on DH graphs is NP-hard! |
| 2025-12-23 | T-076 | Completed | PhD-Algo | Analyzed Oum-Seymour 2006 FOUNDATIONAL paper. Introduces rank-width = bw(cutrk). Well-linked sets technique. rwd ≤ cwd ≤ 2^(rwd+1)-1. O(n^9 log n) for (3k+1)-approx. Uses submodular function minimization. |
| 2025-12-23 | T-075 | Completed | PhD-Theory | Analyzed Fujita 2023 Obstruction Survey. ρ-tangles (T1-T3), ρ-ultrafilters (F1-F4) for rank-width. ρ-obstacles (O1-O3), ρ-linear-tangles (L1-L3), ρ-single-ultrafilters for linear rank-width. Duality theorems: obstruction of order k ↔ width ≥ k. |
| 2025-12-23 | T-074 | Completed | PhD-Algo | Analyzed Oum 2008 Approximation. Three algorithms: O(n^4) 3k+1 (blocking sequences), O(n^3) 24k (matroids), O(n^3) 3k-1 (MSO logic). Foundation for Queyranne.jl. Pivoting preserves cut-rank. |
| 2025-12-23 | T-073 | Completed | PhD-Theory | Analyzed Ganian 2011. Linear rank-width 1 = Thread graphs. Constructive characterization via 𝒜/𝒫, 𝒥/𝒟, ℛ attributes. P-time algorithms for bandwidth (2-approx), dominating bandwidth, path-width (NP-hard on trees!). |
| 2025-12-23 | T-072 | Completed | PhD-Algo | Analyzed Oum 2009. Exact exponential algorithm: O(2^n n³ log² n log log n). Uses fast subset convolution (Björklund). Improves trivial O(3^n). Applies to rank-width, carving-width, branch-width, matching-width. |
| 2025-12-23 | T-071 | Completed | PhD-Theory | Analyzed Oum 2017 Survey. Comprehensive reference: rw ≈ cw (exp), FPT algorithms, 3k+1 approx in O(8^k n^4), WQO by pivot-minors, finite obstructions, tangles, open questions (c<3 runtime, circle graphs, pivot-minor WQO). |
| 2025-12-23 | T-070 | Completed | PhD-Theory | Analyzed Oum WQO paper. Graphs of bounded rank-width are WQO by vertex-minors. Finite obstruction sets exist. Uses isotropic systems (Bouchet). Implies binary matroid WQO. |
| 2025-12-23 | T-069 | Completed | PhD-Theory | Analyzed Di Lavore & Sobociński 2023. Monoidal width captures rank-width with factor of 2. Category-theoretic unification of graph width measures. Rank-Width ↔ Linear Algebra (Matrices). |
| 2025-12-23 | T-068 | Completed | PhD-Theory | Analyzed Oum 2005. Vertex-minors = "right" containment for rank-width. Excluded vertex-minor characterization with bounded obstructions. Distance-hereditary ↔ rw ≤ 1. Binary matroid connection via fundamental graphs. |
| 2025-12-23 | T-067 | Completed | PhD-Theory | Analyzed Courcelle & Kanté 2007. Bilinear products $\otimes_{M,N,P}$ characterize rank-width. Foundation for parse trees. Balancing with 2× width. |
| 2025-12-23 | T-066 | Completed | PhD-Theory | Analyzed Ganian & Hliněný 2010. Parse Trees = algebraic view of rank-decompositions. Myhill-Nerode theorem validates our DP approach. Single-exponential $2^{O(t^2)}$ algorithms. |
| 2025-12-23 | T-065 | Completed | PhD-Theory | Analyzed Bouchet 1987. Isotropic Systems = algebraic foundation of rank-width. Local complementation, circle graphs, distance-hereditary = linear RW ≤ 1. |
| 2025-12-23 | T-064 | Completed | PhD-Theory | Analyzed Nešetřil et al. 2021. "Grand Unification" of sparse/dense theory. FO transductions + stability ↔ bounded rank-width. |
| 2025-12-22 | T-061 | Completed | PhD-Theory | Analyzed Langer et al. 2011. Game Theory $\equiv$ Top-Down DP. |
| 2025-12-22 | T-060 | Completed | PhD-Theory | Analyzed Kwon et al. 2020. Low Rank-Width Colorings. |
| 2025-12-22 | T-059 | Completed | PhD-Theory | Analyzed Alecu et al. 2025. "Lettericity" $\implies$ Linear Rank-Width. Benchmark source. |
| 2025-12-22 | T-058 | Completed | PhD-Theory | Analyzed Anand 2025. "Rank-Expansion" justifies SVD heuristic. |
| 2025-12-22 | T-057 | Completed | PhD-Theory | Analyzed Ganian et al. 2010. #SAT/MAX-SAT are FPT on Rank-Width ($2^{k^2}$). |
| 2025-12-22 | T-056 | Completed | PhD-Theory | Analyzed Beshkov et al. 2024. Connection to NN Topology (Expressivity metric). |
| 2025-12-22 | T-055 | Completed | PhD-Algo | Analyzed Eiben et al. 2018. Hybrid Solver Strategy: Modulator X + RW(G-X). |
| 2025-12-22 | T-053 | Completed | PhD-Algo | Analyzed Nouwt & Bodlaender. Confirmed Simulated Annealing on Decomposition Trees is the way to go. Added T-054. |
| 2025-12-22 | T-052 | Completed | PhD-DataScience | Analyzed Dabrowski et al. (2024). Confirmed Rank-Width's utility for exact learning of decision trees. Identified "Incidence Graph" as the bridge. |
| 2025-12-22 | T-051 | Completed | PhD-Theory | Analyzed Levet et al. 2024. Canonization in TC^2. Future: Isomorphism testing feature. |
| 2025-12-22 | T-047 | Completed | PhD-Theory | Analyzed Bonnet 2021. Concluded Twin-Width is less relevant for contraction cost than Rank-Width. |
| 2025-12-22 | T-046 | Completed | PhD-Algo | Researched "Prefix Rebuilding" in Korhonen 2024. Confirmed it's an advanced dynamic technique; simpler "Local Refinement" is sufficient for current O(n^2) goals. |
| 2025-12-22 | T-045 | Completed | PhD-Theory | Researched Adler 2017. Identified Canonical Split Decomposition as key for exact DH graph solver. |
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
