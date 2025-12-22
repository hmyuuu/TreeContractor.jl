# Escalation Protocol

## Overview
This document defines the conditions and procedures for the PI Agent to escalate issues to the Human User. The goal is to minimize interruption while ensuring critical blockers are addressed.

## Decision Tree for Escalation

### 1. Research Roadblocks
**Scenario:** A PhD Agent cannot find necessary information (e.g., a paper is paywalled, or a theorem is contradictory).
- **Step 1:** PI instructs Agent to try alternative search terms (3 attempts).
- **Step 2:** PI re-assigns to a different Agent type (e.g., Theory $\to$ Physics) to get a new perspective.
- **Step 3:** **ESCALATE** if no progress after 3 attempts or cross-discipline check.

### 2. Conflicting Findings
**Scenario:** Two sources claim opposite facts (e.g., "Rank-width is FPT" vs "Rank-width is NP-hard").
- **Step 1:** PI checks publication dates (trust newer).
- **Step 2:** PI checks citation count (trust seminal).
- **Step 3:** **ESCALATE** only if the conflict affects the core implementation strategy (e.g., choice of algorithm).

### 3. Resource Constraints
**Scenario:** Simulation or search takes too long.
- **Step 1:** PI reduces scope (e.g., "Check top 3 papers" instead of "All papers").
- **Step 2:** **ESCALATE** if the reduced scope invalidates the research goal.

## Escalation Reporting Format

When escalating, the PI Agent must use the following format:

```markdown
**🚨 PI ESCALATION REPORT**

**Issue Type:** [Roadblock / Conflict / Resource]
**Context:** [Brief description of the task and the specific blocker]
**Attempts Made:**
1. [Attempt 1]
2. [Attempt 2]
**Proposed Solution (if any):** [Option A / Option B]
**Request:** [Specific question for the user]
```
