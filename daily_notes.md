# Daily Notes

## 2024-12-XX - Randomized QB Approximation Research

### Summary
Researched randomized QB (QR-based) approximation algorithms for low-rank matrix decompositions. This is an alternative to randomized SVD that can be faster for large matrices while maintaining good approximation quality.

### Key Findings

1. **Randomized QB Algorithm**:
   - Two-stage process: (1) Random sampling to find approximate range, (2) QR decomposition and projection
   - Factorization: A ≈ QB where Q is orthonormal (from QR) and B is small
   - Complexity: O(mn log(k)) for m×n matrix with rank k approximation

2. **Main Reference**: Halko, Martinsson, Tropp (2011)
   - "Finding structure with randomness: Probabilistic algorithms for constructing approximate matrix decompositions"
   - SIAM Review, 53(2), 217-288
   - arXiv: https://arxiv.org/abs/0909.4061
   - DOI: https://doi.org/10.1137/090771806
   - PDF: https://arxiv.org/pdf/0909.4061.pdf

3. **Advantages over SVD**:
   - Faster computation (QR vs SVD)
   - Lower memory requirements
   - Easier iterative refinement
   - Better for block-wise processing

4. **Potential Applications in TreeContractor.jl**:
   - Could speed up compression for very large bond dimensions
   - Useful for approximate compression in intermediate steps
   - May enable block-wise processing of large tensors

### Additional References

- **Duersch, Gu (2020)**: Randomized QR with Column Pivoting
  - DOI: https://doi.org/10.1137/18M1222740
  - arXiv: https://arxiv.org/abs/1801.07599

- **Oseledets, Tyrtyshnikov (2010)**: TT-cross approximation for tensor networks
  - DOI: https://doi.org/10.1016/j.laa.2009.07.024
  - arXiv: https://arxiv.org/abs/0809.3197

- **Martinsson, Rokhlin, Tygert (2006)**: Randomized matrix decomposition
  - DOI: https://doi.org/10.1016/j.acha.2005.11.002

- **Gu, Eisenstat (1996)**: Rank-revealing QR factorization
  - DOI: https://doi.org/10.1137/S106482759528912X

### References Documented
See `randomized_qb_approximation_references.md` for complete reference list with URLs and detailed algorithm descriptions.

### Next Steps
- Consider implementing randomized QB as an option for large bond dimension compression
- Benchmark against current SVD-based approach
- Evaluate accuracy vs speed trade-offs
