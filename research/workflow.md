# Rank-Width Solver Research Workflow

## 1. Purpose
The purpose of this workflow is to guide the autonomous research and development of a **Rank-Width Solver** for Tensor Networks. It coordinates multiple simulated agents (PI, Theory, Algo, Physics) to bridge the gap between Graph Theory (Rank-Width) and Quantum Physics (Tensor Networks), ensuring rigorous theoretical grounding and efficient implementation in Julia.

## 2. Agent Roles & Responsibilities

### Principal Investigator (PI) Agent
- **Role:** Manager, Coordinator, Quality Assurance.
- **Responsibilities:**
    - Assigns tasks to PhD Agents.
    - Monitors the `task_queue.md`.
    - Manages deadlines and resources.
    - Triggers the **Escalation Protocol** when blocked.
    - **Enforce Theory-First Policy:** Ensure no active coding tasks are executed. All implementation tasks must be planned, stubbed, and then immediately **Paused**.
    - *Does not perform direct research.*

### PhD Agents
- **PhD-Theory:** Specializes in Graph Theory, Proofs, and Logic (e.g., Oum, Courcelle).
- **PhD-Algo:** Specializes in Algorithms, Complexity, and Implementation (e.g., Julia, KaHyPar).
    - *Constraint:* For implementation tasks, only produce stubs/plans and mark as `[Paused]`.
- **PhD-Physics:** Specializes in Quantum Mechanics, Tensor Networks, and SVD (e.g., Markov, Shi).
- **The Writer (Specialist):** Dedicated documentation and visualization agent.
    - **Role:** Research Documentation Manager, Task Logger, and Visualizer.
    - **Responsibilities:**
        - Monitors changes to `essence_of_rank_width.md` and paper analysis.
        - Generates `.typ` (Typst) reports for completed tasks.
        - Maintains the Git log and version control for documentation.
        - Creates academic plots using `CeTZ` (Typst) or Julia plotting tools.
        - *Split from PhD-Theory to ensure rigorous documentation standards.*

## 3. Workflow Process (The Automatic Execution Loop)

The workflow operates in a continuous loop managed by the PI Agent.

### Step 0: Conditional Literature Search (Zotero First)
**Trigger:** Perform this step ONLY if the task involves researching, analyzing, or finding papers/literature. Skip for pure coding/admin tasks.

- **Principle:** Always attempt to retrieve from Zotero MCP before using WebSearch.
- **Action:**
    1.  **Check Log:** Review `research/search_logs/` to avoid redundant searches for the same topic.
    2.  **Check Local Library:** Use `mcp_zotero_zotero_search_items` to check if relevant papers exist locally.
    3.  **Search (If needed):** If local items are insufficient OR the task explicitly asks for new papers, perform a broader search (`mcp_zotero_search` or `mcp_zotero_zotero_search_by_tag`).
    4.  **Log:** Save the search query and results (or "No results") to `research/search_logs/[YYYY-MM-DD]_search_log.md`.
    5.  **Error Handling:**
        - If Zotero MCP is unavailable or returns errors, log it and fallback to `WebSearch`.
- **Output:** A list of references to be used in Step 2.

### Step 1: Task Assignment
The PI Agent evaluates the current state and creates a task in `research/task_queue.md`.
- **Command:** Update `research/task_queue.md`.
- **Input:** Current research goals from `research/research_plan.md` and **Search Results from Step 0**.
- **Output:** A new row in the "Active Queue" table.

### Step 2: Execution (PhD Agent)
The assigned PhD Agent picks up the task.

#### 2.1 Sub-Task Breakdown (New)
Before execution, the Agent MUST break the task into logical sub-tasks.
- **Format:** Create a checklist in the response or a temporary scratchpad.
- **Example:**
    - [ ] Sub-task 1: Search for X
    - [ ] Sub-task 2: Analyze Y
    - [ ] Sub-task 3: Document Z

#### 2.2 Execution Loop
The Agent executes all sub-tasks sequentially *within the same turn* (if possible) or across multiple turns, maintaining state.
- **Action (Theory/Research):**
    - **Review Search:** Check the `research/search_logs/` for relevant papers found in Step 0.
    - **Search:** Use `SearchCodebase`, `WebSearch`, or `mcp_zotero` tools (for deeper lookups).
    - **Analyze:** Read papers/code and synthesize findings.
    - **Document:** Create/Update files in `research/papers/` or `research/bibliography.md`.
- **Action (Coding/Implementation):**
    - **Plan:** Write detailed comments/docs describing the algorithm.
    - **Stub:** Create the file/function with a `error("Not implemented")` body.
    - **Pause:** Update `research/task_queue.md` status to `[Paused]` and move to "Long-Term" section.
- **Time Tracking:** The agent must log the estimated time spent.

#### 2.3 Completion
Once all sub-tasks are done, the Agent provides a **Consolidated Report**.

### Step 3: Reporting & Review
The PhD Agent updates the task status in `research/task_queue.md`.
- **Status:** Change from `[In Progress]` to `[Review]`.
- **Log:** Update the "Task Log" section with a summary of the action.
- **The Writer Trigger:** Upon completion, "The Writer" agent must:
    1.  Generate a `.typ` report for the task in `research/reports/`.
    2.  Update the version history of modified core files.
    3.  Commit changes to Git (simulated or actual).

### Step 4: PI Evaluation
The PI Agent reviews the output.
- **Success:** If the task is complete and verified, the PI generates the prompt for the *next* task.
- **Failure/Blocker:** If the task failed or is stalled, the PI triggers the Escalation Protocol.

## 4. Environment Setup

### Dependencies
- **Language:** Julia 1.x (LTS)
- **Tools:**
    - `Zotero MCP` (for literature search)
    - `Trae IDE` (for code editing and terminal access)
- **Julia Packages:**
    - `LinearAlgebra`
    - `Test`
    - `BenchmarkTools`

### Directory Structure
```
/Users/hmyuuu/workspace/RankWidthSolver/
├── research/
│   ├── bibliography.md       # Centralized paper list
│   ├── research_plan.md      # High-level goals and PI logic
│   ├── task_queue.md         # Active tasks and history
│   ├── escalation_protocol.md # Rules for asking user for help
│   ├── skill.md              # Learned lessons and technical notes
│   ├── papers/               # Detailed analysis of individual papers
│   ├── search_logs/          # Logs of automated Zotero searches
│   ├── reports/              # .typ reports generated by The Writer
│   └── code/                 # Julia source code (RankWidthAlgorithms.jl)
```

## 5. Input/Output Specifications

### Task Queue Format (`research/task_queue.md`)
```markdown
| ID | Priority | Task Description | Assigned To | Status | Tool Calls | Budget | Links |
|----|----------|------------------|-------------|--------|------------|--------|-------|
| T-00X | High/Med/Low | [Description] | [Agent Name] | [Status] | [Count] | [Max] | [Dependencies] |
```
- **Status:** `[Pending]`, `[In Progress]`, `[Review]`, `[Completed]`, `[Paused]`, `[Blocked]`.

### Escalation Report Format
When the PI Agent needs to stop and ask the user:
```markdown
**🚨 PI ESCALATION REPORT**
**Issue Type:** [Roadblock / Conflict / Resource]
**Context:** [Brief description]
**Attempts Made:** [List of failed attempts]
**Request:** [Specific question for the user]
```

## 6. Deadline Management

- **Tracking:** Every task must track `Tool Calls` (steps taken) and a `Budget` (max allowed steps).
- **Calculation:**
    - **Analysis/Research:** Base 5 calls + 3 calls per expected source.
    - **Implementation (Stubbing):** Base 3 calls.
    - **Review:** Base 2 calls.
- **Alerts:** If `Tool Calls` > 80% of `Budget`, the task is flagged.

## 7. Troubleshooting (Escalation Triggers)

1.  **Research Roadblocks:** Unable to find a paper or definition after 3 attempts.
2.  **Conflicting Findings:** Contradictory theoretical results (e.g., complexity classes).
3.  **Resource Constraints:** Simulations taking too long (> 10 mins).
4.  **Tool Failures:** Linter errors that persist after 3 fix attempts.

## 8. Expected Outcomes
- **Theoretical:** A complete bibliography and "Essence of Rank-Width" synthesis.
- **Algorithmic:** A working `RankWidthAlgorithms.jl` package implementing the $O(n^3)$ approximation.
- **Verification:** Benchmarks proving that GF(2) Rank-Width predicts Schmidt Rank for Stabilizer States.

## 9. Version Control
- All changes are committed to the local workspace.
- Major milestones are marked by "Completed" status in the Task Log.
