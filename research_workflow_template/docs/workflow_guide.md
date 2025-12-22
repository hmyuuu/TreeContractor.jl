# Research Workflow Guide

## 1. Purpose
This guide establishes a standardized protocol for conducting research, ensuring a clear separation between theoretical analysis and practical implementation. It is designed to facilitate collaboration and reproducibility.

## 2. Roles & Responsibilities

### Researcher (Theory & Analysis)
- **Focus**: Literature review, proof verification, and theoretical modeling.
- **Output**: Markdown files in `/papers` and `/docs`.
- **Key Rule**: Verify theoretical foundations *before* requesting implementation.

### Implementer (Code & Simulation)
- **Focus**: Algorithm design, coding, testing, and benchmarking.
- **Output**: Source code in `/code` and results in `/data`.
- **Key Rule**: Do not start coding until the theoretical specification is clear and documented.

### Coordinator (Project Management)
- **Focus**: Task assignment, deadline management, and quality assurance.
- **Output**: Updates to `README.md` and task logs.

## 3. Workflow Process

### Step 1: Literature Search (Zotero First)
Before starting new research, follow this search protocol:
1.  **Check Local Library**: Use Zotero or local references first.
2.  **External Search**: Use web search only if local resources are insufficient.
3.  **Log Results**: Record search queries and findings in a search log (e.g., in `/docs`).

### Step 2: Paper Analysis
When analyzing a key paper:
1.  **Create an Analysis File**: Create `papers/[AuthorYear].md`.
2.  **Summarize**: Extract the core theorem or contribution.
3.  **Identify Implications**:
    - **Theoretical**: New proofs, obstructions, or definitions.
    - **Algorithmic**: Complexity classes, data structures needed.
4.  **Synthesize**: Determine actionable next steps (e.g., "Implement Algorithm A").

### Step 3: Implementation Handover
1.  **Specification**: The Researcher writes a clear spec in the paper analysis file.
2.  **Stubbing**: The Implementer creates a placeholder file in `/code` with `NotImplemented` errors.
3.  **Development**: Code is written, tested, and benchmarked.
4.  **Verification**: Results are compared against theoretical predictions.

### Step 4: Documentation & Review
- Update `README.md` with new findings.
- Commit changes with descriptive messages (e.g., `feat:`, `docs:`, `analysis:`).
- Generate reports if needed.

## 4. Best Practices
- **Theory First**: Never code without a plan.
- **Atomic Commits**: Keep changes small and focused.
- **Reproducibility**: Ensure all data generation scripts are included in `/code`.
