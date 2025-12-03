# MPO Application

This page describes how to apply Matrix Product Operators (MPO) to Matrix Product States (MPS) using TreeContractor.

## Overview

The MPO application functionality allows you to efficiently apply operators represented as Matrix Product Operators to states represented as Matrix Product States. This is a fundamental operation in tensor network methods for quantum many-body systems.

## Types

### ContractorMPO

```julia
ContractorMPO{T, AT}
```

A Matrix Product Operator type. Each tensor in `data` is rank-4 with indices:
`[left_bond, physical_in, physical_out, right_bond]`

### ContractorMPS

```julia
ContractorMPS{T, AT}
```

A Matrix Product State type for MPO application. Each tensor in `data` is rank-3 with indices:
`[left_bond, physical, right_bond]`

## Basic Usage

### Creating ContractorMPO and ContractorMPS

```julia
using TreeContractor
using Random

Random.seed!(42)
N = 4  # number of sites
d = 2  # physical dimension
χ_mps = 3  # MPS bond dimension
χ_mpo = 2  # MPO bond dimension

# Create random ContractorMPS
mps_tensors = [
    randn(ComplexF64, 1, d, χ_mps),
    [randn(ComplexF64, χ_mps, d, χ_mps) for _ in 2:(N-1)]...,
    randn(ComplexF64, χ_mps, d, 1)
]
mps = ContractorMPS(mps_tensors)

# Create random ContractorMPO
mpo_tensors = [
    randn(ComplexF64, 1, d, d, χ_mpo),
    [randn(ComplexF64, χ_mpo, d, d, χ_mpo) for _ in 2:(N-1)]...,
    randn(ComplexF64, χ_mpo, d, d, 1)
]
mpo = ContractorMPO(mpo_tensors)
```

### Applying MPO to MPS

There are two algorithms available:

#### LocalCompress (Zip-up Algorithm)

```julia
mps_result = apply!(LocalCompress(), mpo, mps; atol=1e-12, maxdim=20)
```

- **Speed**: Fast, O(N χ² d²) per sweep
- **Accuracy**: Approximate, precision not guaranteed
- **Use case**: Intermediate steps, rough estimates
- **Canonical center**: Set to rightmost site after application

#### FullCompress (Density Matrix Algorithm)

```julia
mps_result = apply!(FullCompress(), mpo, mps; atol=1e-13, maxdim=20)
```

- **Speed**: Slower, O(N χ³ d²)
- **Accuracy**: Optimal, precision guaranteed
- **Use case**: Final results, high precision needed
- **Canonical center**: Set to leftmost site after application

### Computing Expectation Values

```julia
# Compute expectation value ⟨ψ|O|ψ⟩ / ⟨ψ|ψ⟩
exp_val = expectation(mpo, mps)
```

### Computing Sandwich Products

```julia
# Compute ⟨bra|O|ket⟩
sandwich_val = sandwich(bra, mpo, ket)
```

## Algorithm Details

### LocalCompress Algorithm

The LocalCompress algorithm (also known as the Zip-up algorithm) performs a left-to-right sweep:

1. Start with left environment tensor initialized to identity
2. For each site (left to right):
   - Contract MPO and MPS tensors with left environment
   - Perform truncated SVD
   - Update MPS tensor and left environment
3. Set canonical center to rightmost site

**Reference**: https://tensornetwork.org/mps/algorithms/zip_up_mpo/

### FullCompress Algorithm

The FullCompress algorithm (also known as the Density Matrix algorithm) uses environment tensors:

1. Build left environment tensors by sweeping left to right
2. For each site (right to left):
   - Construct reduced density matrix from left environment and embedded right environment
   - Diagonalize density matrix to find optimal truncation basis
   - Project MPS onto leading eigenvectors
   - Update embedded environment
3. Set canonical center to leftmost site

**Reference**: https://tensornetwork.org/mps/algorithms/denmat_mpo_mps/

## Helper Functions

```julia
nsite(mps::ContractorMPS)      # Number of sites
nsite(mpo::ContractorMPO)      # Number of sites
nflavor(mps::ContractorMPS)    # Physical dimension
nflavor(mpo::ContractorMPO)    # Physical dimension (input)
maxlinkdim(mps::ContractorMPS) # Maximum bond dimension
maxlinkdim(mpo::ContractorMPO) # Maximum bond dimension
norm(mps::ContractorMPS)       # Norm of the MPS
normalize!(mps::ContractorMPS) # Normalize the MPS
```

## Examples

### Identity Operator

```julia
# Create identity MPO (preserves state)
mpo_tensors = [
    zeros(ComplexF64, 1, d, d, 1),
    [zeros(ComplexF64, 1, d, d, 1) for _ in 2:(N-1)]...,
    zeros(ComplexF64, 1, d, d, 1)
]
for i in 1:N
    for a in 1:d
        mpo_tensors[i][1, a, a, 1] = 1.0
    end
end
mpo_identity = ContractorMPO(mpo_tensors)

# Apply identity (should preserve state)
mps_result = apply!(LocalCompress(), mpo_identity, copy(mps))
@assert norm(mps_result) ≈ norm(mps)  # Norm preserved
```

## Performance Considerations

- **Bond dimension**: The maximum bond dimension `maxdim` controls the trade-off between accuracy and computational cost
- **Truncation tolerance**: The `atol` parameter determines when singular values are discarded
- **Algorithm choice**: Use `LocalCompress` for speed, `FullCompress` for accuracy
- **Memory**: FullCompress requires storing environment tensors, using more memory

## References

- [Tensor Network MPS Algorithms](https://tensornetwork.org/mps/algorithms/#mpo)
- [Zip-up MPO Algorithm](https://tensornetwork.org/mps/algorithms/zip_up_mpo/)
- [Density Matrix MPO Algorithm](https://tensornetwork.org/mps/algorithms/denmat_mpo_mps/)

