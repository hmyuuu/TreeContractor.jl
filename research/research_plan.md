# Comprehensive Research Plan: Rank-Width in Graph Theory and Tensor Networks

## 1. Structured Literature Review Methodology

### Systematic Search Strategy
We will conduct a systematic literature review using Zotero with MCP integration to ensure comprehensive coverage of the field.

#### Search Parameters
- **Keywords:** "rank-width", "graph decomposition", "branch-width", "clique-width", "tensor networks", "matrix rank"
- **Databases:**
  - IEEE Xplore
  - ACM Digital Library
  - arXiv
  - MathSciNet
  - ScienceDirect
- **Timeframe:** 1990 to present

#### Inclusion/Exclusion Criteria
- **Include:**
  - Peer-reviewed journal papers
  - Conference proceedings (e.g., SODA, STOC, FOCS, ICALP)
  - Seminal preprints (arXiv)
- **Exclude:**
  - Non-mathematical treatments
  - Applications unrelated to graph theory, complexity, or tensor networks

#### Organization Strategy
Papers will be organized in the `research/papers` directory and tracked in Zotero collections:
- **Chronological:** By publication date to trace the evolution of concepts.
- **Thematic Clusters:**
  - *Theory:* Structural properties, decompositions, logic.
  - *Algorithms:* Fixed-parameter tractable (FPT) algorithms, approximations, exact solvers.
  - *Applications:* Tensor networks, quantum computing, constraint satisfaction.
- **Impact:** Ranked by citation count and influence on subsequent work.

---

## 2. Paper Analysis Framework

### Bibliography Tracking (`research/bibliography.md`)
A centralized bibliography file will be maintained containing:
- Complete citations in BibTeX format.
- Direct DOI links.
- Classification tags: `[Theory]`, `[Algorithm]`, `[Application]`.

### Individual Paper Analysis (`research/papers/[paper_id].md`)
For each key paper, a detailed Markdown document will be created with the following structure:

#### A. Mathematical Definitions
- **Formal Definitions:** Precise statements of key concepts (e.g., cut-rank functions, rank-decomposition).
- **Theorems:** Complete statements of major theorems.
- **Proof Sketches:** High-level outlines of key proofs to understand the logic flow.

#### B. Algorithmic Content
- **Pseudocode:** High-level descriptions of algorithms.
- **Complexity Analysis:** Detailed time and space complexity notes.
- **Implementation Challenges:** Notes on potential difficulties in translating theory to code (e.g., large constants, complex data structures).

#### C. Tensor Network Applications
- **Connections:** Explicit links to tensor network states (MPS, PEPS) and contractions.
- **Use Cases:** Potential applications in quantum circuit simulation or statistical mechanics.
- **Limitations:** Boundaries of where rank-width based approaches apply in TNs.

#### D. Critical Evaluation
- **Novelty:** What was new at the time of publication?
- **Impact:** How did this influence the field?
- **Open Questions:** What problems were left unsolved?

---

## 3. Algorithm Implementation Requirements

### Julia Package: `RankWidthAlgorithms.jl`
We will develop a high-performance Julia package located in `research/code/RankWidthAlgorithms.jl`.

#### Core Components
- **Type System:** Custom structs for `Graph`, `RankDecomposition`, `ParseTree` matching mathematical definitions.
- **Multiple Dispatch:** Leveraging Julia's type system for efficient handling of different graph types and decomposition strategies.
- **Documentation:** Detailed docstrings with LaTeX math (`L"..."`) explaining the theory behind functions.

#### Testing Infrastructure
- **Unit Tests:** Covering edge cases (empty graphs, disconnected graphs, cliques).
- **Property-Based Testing:** Using `PropCheck.jl` or similar to verify invariants (e.g., rank-width $\le$ clique-width).
- **Comparison:** validating results against known values for standard graph classes.

#### Performance Analysis
- **Benchmarks:** Using `BenchmarkTools.jl` to track execution time.
- **Profiling:** Memory allocation tracking to ensure efficiency.
- **Scaling:** Analysis of runtime vs. graph size ($n$) and rank-width ($k$).

#### Tensor Network Adaptations
- **Interfaces:** Functions to convert rank-decompositions into tensor contraction orders.
- **TN Solvers:** Basic implementations of tensor contraction using the computed decomposition.

---

## 4. Research Deliverables

### Weekly Progress Reports (`research/progress/`)
- **Format:** `[YYYY-MM-DD].md`
- **Content:**
  - *Completed Work:* Summary of papers read and code written.
  - *Challenges:* Technical or theoretical blockers.
  - *Next Steps:* Plan for the upcoming week.

### Final Synthesis (`research/findings.md`)
A comprehensive document summarizing the research:
- **Timeline:** Historical development of rank-width.
- **Theoretical Connections:** Deep dive into the link between rank-width and tensor networks.
- **Algorithmic Landscape:** State-of-the-art algorithms and their practical viability.
- **Open Problems:** Unsolved questions identified during the research.

### Code Repository
- **Source:** Full Julia source code.
- **Docs:** `Documenter.jl` generated documentation site.
- **CI/CD:** GitHub Actions for testing and documentation.

### Visualization Suite (`research/visualization/`)
- **Plots:** Performance graphs.
- **Diagrams:** Visual representations of graph decompositions and tensor networks (using TikZ or Julia plotting libraries).

---

## 5. Quality Standards

### Documentation
- **Format:** Consistent Markdown with headers.
- **Math:** LaTeX for all mathematical notation.
- **Linking:** Extensive cross-referencing between analysis files and the bibliography.

### Recursive Research Process
- **Prompt Generation:** At the end of each paper analysis cycle (after updating `skill.md`), the agent must explicitly generate the prompt for the next logical step in the research.
- **Criteria for Next Step:** The next step should be chosen based on:
  1.  Open questions identified in the current analysis.
  2.  References found that bridge gaps (e.g., Theory $\to$ Application).
  3.  The next highest priority item in `bibliography.md`.

### Peer Review Feedback Loop
- **Reflection Sharing:** During the "Skill Development" phase, the agent must summarize key reflections and challenges.
- **Feedback Collection:** These reflections should be presented to a simulated "Senior Researcher" agent (self-prompted) to critique the methodology and suggest improvements.
- **Integration:** The feedback must be logged in `skill.md` and actionable advice incorporated into the next cycle.

### Hypothesis Verification
We propose two core hypotheses to be verified in the next phase:

#### H1: The Branching Advantage
*   **Statement:** For deep, random quantum circuits, a full Rank-Decomposition (branching tree) will yield exponentially smaller contraction cost than a Linear Rank-Decomposition (ordering), similar to the Treewidth vs Pathwidth separation.
*   **Verification:** Simulate random stabilizer circuits and compare the max cut-rank of:
    1.  Optimal Linear Ordering (Linear RW).
    2.  Optimal Branching Decomposition (General RW).
*   **Success Metric:** $RW(G) \ll LRW(G)$ for $depth \gg \log n$.

#### H2: The Dynamic Guide
*   **Statement:** The $O(n)$ dynamic rank-width algorithm (Korhonen 2024) can be used as a real-time contraction heuristic.
*   **Verification:** Implement a "Lookahead Contractor" that uses local complementation moves to greedily minimize the cut-rank of the next tensor contraction.
*   **Success Metric:** The contractor finds a contraction order within $1.5 \times$ of the optimal cost found by simulated annealing, but in linear time.

### PI Agent Workflow
The research process is governed by a **Principal Investigator (PI) Agent** that manages the workflow.
- **Current Goal:** **Theoretical Essence of Rank-Width**. Focus on understanding the deep theoretical properties (cut-rank, vertex-minors) and their exact relation to Tensor Networks, rather than premature implementation.
- **Role:** High-level coordination, task assignment, and quality assurance. *Does not perform direct research.*
- **Responsibilities:**
  1.  **Task Assignment:** Evaluates new papers/tasks and assigns them to specialized "PhD Agents" (simulated personas: Theorist, Algorithmist, Physicist).
  2.  **Monitoring:** Checks `task_queue.md` and `progress/` logs.
  3.  **Escalation:** Decides when to pause and ask the human user for help based on the `escalation_protocol.md`.

### Automatic Execution Loop
To maximize efficiency, the PI Agent operates in an **Automatic Execution Loop**:
1.  **Check Queue:** Identify the next high-priority task.
2.  **Auto-Assign:** Delegate to the appropriate PhD Agent.
3.  **Execute:** The PhD Agent performs the task (Search $\to$ Analyze $\to$ Document) *immediately* within the same turn if possible.
4.  **Loop:** If the task is successful and no critical escalation is triggered, the PI Agent *immediately* generates the prompt for the next task and proceeds.
5.  **Stop Condition:** The loop pauses only when:
    *   An **Escalation** condition is met (Roadblock, Conflict, Resource).
    *   The Task Queue is empty.
    *   The user explicitly intervenes.

### Deadline Management Protocol
To ensure efficient execution, the PI Agent manages deadlines dynamically:
1.  **Time Tracking:** Every task must log `Time Spent` (e.g., "00:15").
2.  **Deadline Calculation:**
    *   *Search/Analysis Tasks:* Base 1 hour + 15 min per expected source.
    *   *Coding Tasks:* Base 30 min + 1 hour per 100 lines of estimated code.
    *   *Review Tasks:* Fixed 30 min.
3.  **Adjustment:** If `Time Spent` > 80% of `Deadline`, the PI Agent must either:
    *   Extend the deadline (if progress is clear).
    *   Escalate (if blocked).
4.  **Alerts:** The Task Queue will flag tasks as **[WARNING]** or **[OVERDUE]**.

### Code Quality
- **Compatibility:** Julia 1.x (LTS and stable).
- **Coverage:** Aim for 100% test coverage for core algorithmic logic.
- **Style:** Adherence to Julia style guides (BlueStyle or YAS).

### Mathematical Rigor
- **Verification:** Algorithms must be formally justified against the theorems.
- **Counterexamples:** Active search for counterexamples to test assumptions.

### Literature Coverage
- **Scope:** Must cover Oum & Seymour's foundational work, Courcelle's logic connections, and recent algorithmic advances (e.g., FPT algorithms).

---

## 6. Web Search Protocol

### Resource Collection (`research/web_resources.md`)
- **Archival:** Links to project pages, lecture notes, and slides.
- **Assessment:** Notes on credibility and relevance.

### Methodology
- **Engines:** Google Scholar, Semantic Scholar.
- **Tracking:** documenting search terms and date of access.
- **Maintenance:** Checking for broken links and archiving important pages (e.g., via Internet Archive).
