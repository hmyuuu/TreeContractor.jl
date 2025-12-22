# Skill Development Log

## Research Methodologies
| Date | Methodology | Context | Effectiveness |
|------|-------------|---------|---------------|
| 2025-12-22 | MCP Zotero Search | Initial "rank-width" broad search | High. Quickly found 10+ relevant items. |
| 2025-12-22 | Targeted Zotero Search | "rank-width tensor network" | Low. No direct hits in user library. |
| 2025-12-22 | Web Search | "rank-width tensor network contraction" | High. Found specific papers (Markov 2008, Gray 2018) establishing the link. |
| 2025-12-22 | "Recursive" Web Search | Searching for citations of Markov 2008 | High. Found Gray 2018 and Dumitrescu 2018, confirming the modern relevance of the method. |

## Challenges & Solutions
- **Challenge:** Lack of direct intersection papers in the initial Zotero library.
  - **Solution:** Pivoted to Web Search using broader terms like "tensor network contraction graph width".
  - **Outcome:** Discovered that "treewidth" is the dominant term in TN literature, but "rank-width" is theoretically superior for low-rank approximations.
- **Challenge:** Distinguishing between "treewidth of graph" vs "treewidth of line graph".
  - **Solution:** Careful reading of Markov & Shi 2008 abstract and Gray 2018 snippets.
  - **Outcome:** Clarified that TN indices $\leftrightarrow$ Line Graph vertices.

## Search Strategy Analysis
- **Effective Strategies:**
  - Combining "rank-width" with "tensor network" in Google Scholar/Web Search.
  - Searching for the *definitions* (e.g., "Schmidt rank vs rank-width") rather than just keywords.
- **Ineffective Strategies:**
  - Searching Zotero for very specific intersection terms when the library is small.

## Critical Thinking Improvements
- Realized that the "rank" in rank-width is the *same* mathematical object as the "bond dimension" (log of) in tensor networks, bridging two separate fields (Graph Theory and Quantum Physics).
- Understood the subtle but critical distinction: Markov & Shi optimize for *size* of intermediate tensors (treewidth), while Oum & Seymour optimize for *rank* (rank-width). This identifies the exact niche for my research (using rank-width for low-rank TNs).

## Time Management
- Creating the bibliography structure *first* helped organize the web search results immediately, preventing information loss.

## Peer Review & Feedback
| Date | Reviewer Role | Feedback Summary | Action Taken |
|------|---------------|------------------|--------------|
| 2025-12-22 | Senior Researcher (Simulated) | **Theoretical Gap:** Rank-Decomposition (Oum) does not trivially map to Contraction Order (Markov). **Risk:** GF(2) rank $\ne$ Schmidt Rank over $\mathbb{C}$. **Validation:** Identified `src/compress.jl` truncation logic as a potential weak point. | Created targeted research tasks to bridge the "Translation Gap" and "Field Gap". Added TODO to review `src/compress.jl`. |

## Search Strategy Analysis
- **Effective Strategies:**
  - Combining "rank-width" with "tensor network" in Google Scholar/Web Search.
  - Searching for the *definitions* (e.g., "Schmidt rank vs rank-width") rather than just keywords.
  - Using "implementation" keywords like `QuickBB` and `KaHyPar` to find practical software papers (Gray 2021).

## Technical Feasibility (KaHyPar)
- **Status:** KaHyPar optimizes "Connectivity" ($\lambda-1$) or "Cut-Net" metrics. It does **not** natively support "Rank" metrics (checking linear dependence of neighbors).
- **Workaround:** We can assign *static weights* to hyperedges (indices) based on their bond dimension ($\log D$).
- **Limitation:** This is still "Carving Width", not "Rank-Width". Implementing true Rank-Width would require modifying the gain computation in KaHyPar's C++ source to perform Gaussian elimination updates, which is computationally expensive ($O(D^3)$ per move).

## Future Development Plan
- [ ] Improve proficiency with Julia for implementing the rank-decomposition algorithm.
- [ ] Deepen understanding of "Linear Rank-width" vs "Path-width".
