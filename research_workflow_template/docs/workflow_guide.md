# Research Workflow Guide (Agent-Based)

## 1. Purpose
This workflow coordinates autonomous agents (PI, PhDs, Writer) to conduct rigorous research. It enforces a "Theory-First" policy, ensuring that all code is based on verified theoretical foundations.

## 2. Agent Roles & Responsibilities

### Principal Investigator (PI) Agent
- **Role**: Manager, Coordinator, Quality Assurance.
- **Responsibilities**:
    - Assigns tasks via `task_queue.md`.
    - Manages the **Escalation Protocol**.
    - **Enforce Theory-First Policy**: Ensure no active coding tasks are executed without a theoretical plan.

### PhD Agents
- **PhD-Theory**: Specializes in Proofs, Logic, and Literature Analysis.
- **PhD-Algo**: Specializes in Complexity, Data Structures, and Implementation.
    - *Constraint*: **NO CODING IMMEDIATELY.** Focus on paper analysis first.
- **PhD-Physics**: Specializes in Domain Applications (e.g., Quantum, Physics).
- **The Writer**: Documentation and Reporting.
    - **Role**: Generates `.typ` reports and maintains version control.

## 3. Workflow Process (The Execution Loop)

### Step 0: Conditional Literature Search (Zotero First)
**Trigger**: When a task involves researching new topics.
1.  **Check Local Library**: Use Zotero tools first.
2.  **External Search**: Use WebSearch only if local is insufficient.
3.  **Log**: Record findings in `search_logs/[YYYY-MM-DD]_search_log.md`.

### Step 0.5: Group Meeting Protocol (Paper Analysis)
**Trigger**: Deep research of a key paper.
1.  **Fetch**: Retrieve full text/abstract into `papers/`.
2.  **Analyze (Round Table)**:
    - **Theory**: Core theorems?
    - **Algo**: Complexity?
    - **Physics**: Application?
3.  **Synthesize**: PI creates sub-tasks based on insights.

### Step 1: Task Assignment
The PI assigns a task from `task_queue.md`.
- **Mode**: `Plan Mode` is enforced for high-priority tasks.
- **Reference Check**: Ensure all dependencies are met.

### Step 2: Execution (PhD Agent)
1.  **Sub-Task Breakdown**: Create a checklist.
2.  **Execution Loop**:
    - **Research**: Read papers, update `bibliography.md`.
    - **Code**: Plan -> Stub -> Implement.
    - **Log**: Update `skill.md` with lessons learned.

### Step 3: Reporting & Review
1.  **Update Queue**: Set status to `[Review]`.
2.  **Writer Trigger**:
    - Generate `.typ` report in `reports/`.
    - Commit changes with standardized messages.

### Step 4: PI Evaluation
- **Success**: Mark `[Completed]` and plan next task.
- **Failure**: Trigger **Escalation Protocol**.

## 4. Input/Output Specifications

### Task Queue Format
See `task_queue.md`. All tasks must track `Tool Calls` and `Budget`.

### Escalation Report
See `escalation_protocol.md`. Use when blocked or finding conflicts.

## 5. Environment & Dependencies
- **Language**: [Primary Language, e.g., Julia/Python]
- **Tools**: Zotero, Typst (for reports), Git.
- **Key Files**:
    - `research_plan.md`: High-level roadmap.
    - `skill.md`: Shared memory of "what works".
