# TreeContractor.jl - Project Summary

## Overview

TreeContractor.jl is a Julia package that provides efficient tensor network contraction using Matrix Product State (MPS) representations with compression. The package converts arbitrary tensor networks into MPS form and applies tensors sequentially while controlling bond dimensions through sophisticated compression algorithms.

## Core Architecture

### Main Entry Point

**`contract_with_mps(optcode, tensors, size_dict; maxdim=Inf)`** (src/mps.jl:185)

The primary function that:
1. Converts a tensor network contraction tree (`DynamicNestedEinsum`) into an MPS representation
2. Sequentially applies tensors to the MPS
3. Automatically compresses when bond dimensions exceed `maxdim`
4. Returns the contracted result as MPS tensors

### Key Data Structure

**`LabeledMPS{T, AT, LT}`** (src/mps.jl:1)

A mutable struct representing a Matrix Product State with:
- `tensors::Vector{AT}`: Rank-3 tensors `[left_virtual, physical, right_virtual]`
- `labels::Vector{LT}`: Labels for each tensor site
- `label_to_index::Dict{LT, Int}`: Fast lookup from label to position
- `center::Int`: Canonical center position (-1 if not canonicalized)

Properties:
- Left/right boundary tensors have virtual dimension 1
- Supports canonicalization for efficient operations
- Tracks orthogonality center for optimized computations

## Tensor Application Pipeline

### 1. Code to MPS Conversion

**`code2mps(T, code, size_dict)`** (src/mps.jl:20)

Analyzes the contraction tree and generates:
- Initial MPS structure with identity tensors
- Application sequence (`apply_vec`) specifying tensor order
- Labels for each tensor in the contraction
- Vanishing labels that will be contracted out

### 2. Sequential Tensor Application

**`apply_tensors!(mps, apply_vec, tensors, tensor_labels, vanish_labels_vec; maxdim)`** (src/mps.jl:56)

Main application loop:
```julia
for (i, label, vanish_labels) in zip(apply_vec, tensor_labels, vanish_labels_vec)
    mps = apply_tensor!(mps, tensors[i], label, vanish_labels)
    if maximum(size.(mps.tensors,1)) > maxdim
        compress!(FullCompress(), mps; maxdim)
    end
end
```

Key features:
- Applies tensors one at a time in the order specified by the contraction tree
- Monitors bond dimensions and triggers compression when needed
- Uses `FullCompress()` algorithm for accurate global compression

### 3. Individual Tensor Application

**`apply_tensor!(mps, tensor, tensor_label, vanish_labels)`** (src/mps.jl:69)

Process for each tensor:
1. Convert tensor to MPS form via SVD (`tensor2mps`)
2. Merge tensor-MPS into existing MPS at corresponding positions
3. Handle vanishing indices that get contracted away
4. Update MPS structure by removing contracted sites

Two merge strategies:
- **`apply_rank_3_tensor`** (src/mps.jl:127): Keeps physical dimension (normal merge)
- **`apply_rank_3_tensor_with_vanish`** (src/mps.jl:136): Contracts physical dimension (for indices being eliminated)

## Compression Algorithms

### LocalCompress (Zipup Algorithm)

**Location**: src/compress.jl:137

**Algorithm**:
```julia
function compress!(::LocalCompress, mps; niters=1, atol=1e-12, maxdim)
    for _ in 1:niters
        canonicalize!(mps, nsite(mps); atol, maxdim)  # Right sweep
        canonicalize!(mps, 1; atol, maxdim)           # Left sweep
    end
end
```

**Characteristics**:
- Fast, O(N) complexity per sweep
- Performs local SVDs moving left-right-left
- No environmental information considered
- Precision NOT guaranteed (truncation errors accumulate)
- Good for quick compression during intermediate steps

**References**:
- https://tensornetwork.org/mps/algorithms/zip_up_mpo/

### FullCompress (Density Matrix Algorithm)

**Location**: src/compress.jl:146

**Algorithm**:
1. **Left sweep**: Build left environment tensors
   ```julia
   L[i+1] = ein"(ik, iaj), kal->jl"(L[i], conj(mps[i]), mps[i])
   ```

2. **Right sweep**: For each site i (from right to left):
   - Construct reduced density matrix ρ from environment
   - Diagonalize ρ to find optimal truncation basis
   - Project MPS onto leading eigenvectors
   - Update embedded tensor for next site

**Characteristics**:
- Slower, O(χ³) complexity per site
- Uses global environment information
- **Precision IS guaranteed** - finds optimal truncation in variational sense
- Minimizes truncation error ||ψ - ψ_truncated||²
- Essential for maintaining accuracy in long contractions

**Mathematical Foundation**:

The density matrix at bond i is:
```
ρ = L[i] × (bra[i] ⊗ ket[i]) × R[i+1]
```

Truncation keeps the eigenvectors with largest eigenvalues, which optimally approximates the quantum state.

**References**:
- https://tensornetwork.org/mps/algorithms/denmat_mpo_mps/
- https://tensornetwork.org/mps/index.html#compression

## Canonicalization

**`canonicalize!(mps, center; atol, maxdim)`** (src/compress.jl:16)

Brings MPS to canonical form with orthogonality center at site `center`:
- Sites left of center: left-orthogonal (isometric A matrices)
- Sites right of center: right-orthogonal (isometric B matrices)
- Center site: holds all singular values (C matrix)

**Benefits**:
- Efficient norm computation: `norm(mps) = norm(mps.tensors[center])`
- Stable numerical operations
- Efficient expectation value calculations
- Foundation for compression algorithms

**Movement operations**:
- **`canonical_move_right!`** (src/compress.jl:43): QR decomposition, move R to next site
- **`canonical_move_left!`** (src/compress.jl:54): LQ decomposition, move L to previous site

## Performance Characteristics

### Time Complexity

- **LocalCompress**: O(N χ² d²) per sweep
- **FullCompress**: O(N χ³ d²)
- **Tensor application**: O(d^k χ²) where k is tensor rank

### Space Complexity

- MPS storage: O(N χ d)
- Full tensor: O(d^N)
- **Memory savings**: Exponential for large N when χ << d^(N/2)

### Accuracy vs Speed Trade-off

| Algorithm | Speed | Accuracy | Use Case |
|-----------|-------|----------|----------|
| LocalCompress | Fast | Approximate | Intermediate steps, rough estimates |
| FullCompress | Slow | Optimal | Final results, high precision needed |

## SVD Truncation Strategy

**`truncated_svd(M, atol, maxdim)`** (src/compress.jl:181)

Truncates singular values by:
1. Keep singular values σᵢ ≥ `atol` (absolute threshold)
2. Keep at most `maxdim` values (dimension limit)
3. Return truncation error: ε² = Σ σᵢ² for discarded values

**`truncated_eigen(M, atol, maxdim)`** (src/compress.jl:192)

Similar for eigendecomposition, used in density matrix approach.

## Usage Examples

### Basic Tensor Network Contraction

```julia
using TreeContractor, OMEinsum

# Define tensor network
code = ein"abc,cde,egh,fbg->"
optcode = optimize_code(code, uniformsize(code, 2), PathSA())

# Create tensors
tensors = [rand(2,2,2) for _ in 1:4]

# Contract with MPS (bond dimension ≤ 10)
result = contract_with_mps(optcode, tensors, uniformsize(code, 2); maxdim=10)
scalar_result = result[1][]
```

### Quantum Error Correction (from examples/qec.jl)

```julia
using TreeContractor, TensorQEC

# Load QEC problem
dem = parse_dem_file("surface_code_d=3_r=3.dem")
ct = compile(TNMMAP(PathSA(), true), dem)

# Contract with different bond dimensions
@time contract_with_mps(ct.code, ct.tensors, uniformsize(ct.code,2); maxdim=20)
@time contract_with_mps(ct.code, ct.tensors, uniformsize(ct.code,2); maxdim=50)
@time contract_with_mps(ct.code, ct.tensors, uniformsize(ct.code,2); maxdim=80)
```

### Quantum Circuit Simulation (from examples/kicked_ising.jl)

```julia
using TreeContractor, Yao, OMEinsum

# Create quantum circuit
nq, nl = 5, 20
circuit = ising_complete(nq, nl; theta=0.1)
network = yao2einsum(circuit;
    initial_state=Dict(zip(1:nq, zeros(Int,nq))),
    final_state=Dict(zip(1:nq, zeros(Int,nq)))
)

# Optimize contraction order
code = optimize_code(flatten(network.code), uniformsize(network.code,2), PathSA())

# Contract with MPS compression
@time contract_with_mps(code, network.tensors, uniformsize(network.code,2); maxdim=10)
```

## Integration with Other Packages

### OMEinsum.jl
- Provides `DynamicNestedEinsum` contraction trees
- `optimize_code()` generates optimal contraction sequences
- `TreeSA()` and `PathSA()` optimization algorithms

### TensorQEC.jl
- Quantum error correction code compilation
- Provides tensor networks for syndrome decoding
- Integration via `TNMMAP` compilation mode

### Yao.jl
- Quantum circuit simulation
- `yao2einsum()` converts circuits to tensor networks
- Enables efficient simulation of large quantum circuits

## Current Implementation Status

### Working Features
✓ Basic tensor network to MPS conversion
✓ Sequential tensor application with vanishing indices
✓ LocalCompress algorithm (sweep-based canonicalization)
✓ FullCompress algorithm (density matrix based)
✓ Canonicalization and orthogonality center tracking
✓ Truncated SVD and eigendecomposition
✓ Linear algebra operations (norm, dot, addition, scaling)

### Known Limitations
- Memory usage grows with bond dimension χ
- FullCompress is O(χ³) - can be slow for large χ
- No GPU acceleration yet
- No parallel tensor application

## Performance Optimization Opportunities

### Current Implementation Analysis

The code excerpt provided in the user request shows commented-out `@show` statements and debugging code, suggesting:

1. **Contraction Order**: The current `contract_with_mps` already uses optimized contraction order from OMEinsum
2. **Compression Trigger**: Compression is triggered when `max bond dim > maxdim` (src/mps.jl:60-64)

### Recommended Improvements

#### 1. Apply + Compress Fusion

**Current**: Apply tensor → check bond dim → compress if needed

**Improved**: Apply tensor and compress simultaneously

Implementation strategy:
```julia
function apply_tensor_with_local_compress!(mps, tensor, tensor_label, vanish_labels; atol, maxdim)
    # Apply tensor
    mps = apply_tensor!(mps, tensor, tensor_label, vanish_labels)

    # Immediately compress locally after each tensor application
    for i in affected_sites
        # Local SVD compression at each modified bond
        truncate_bond!(mps, i; atol, maxdim)
    end
end
```

**Benefits**:
- Prevents bond dimension explosion between applications
- More stable numerics
- Lower memory peak usage

#### 2. Adaptive Compression Strategy

**Current**: Only `FullCompress` used when threshold exceeded

**Improved**: Hybrid strategy based on bond dimension growth

```julia
function apply_tensors_adaptive!(mps, apply_vec, tensors, ...; maxdim)
    for (i, tensor) in enumerate(tensors)
        mps = apply_tensor!(mps, tensor, ...)

        current_maxdim = maximum(size.(mps.tensors, 1))

        if current_maxdim > 0.7 * maxdim
            # Use local compress for quick reduction
            compress!(LocalCompress(), mps; maxdim)
        end

        if current_maxdim > maxdim || i == length(tensors)
            # Use full compress for accurate truncation
            compress!(FullCompress(), mps; maxdim)
        end
    end
end
```

**Benefits**:
- LocalCompress for intermediate cleanup (fast)
- FullCompress for accurate final result
- Better balance of speed and accuracy

#### 3. Customization from RydbergToolkit.jl

Based on the reference to RydbergToolkit.jl, likely improvements include:

**Parallel sweeps**: Apply multiple tensors before compressing
```julia
function apply_batch_then_compress!(mps, tensors, batch_size; maxdim)
    for batch in partition(tensors, batch_size)
        for tensor in batch
            apply_tensor!(mps, tensor, ...)
        end
        compress!(FullCompress(), mps; maxdim)
    end
end
```

**Specialized operators**: Optimize for common quantum gate patterns
- Single-qubit gates: no bond dimension growth
- Two-qubit gates: controlled compression
- Long-range gates: strategic placement

## Future Directions

### Short-term
- Implement apply + compress fusion
- Add adaptive compression strategy
- Benchmark against RydbergToolkit.jl implementations
- Profile memory usage and optimize allocations

### Medium-term
- GPU support via CUDA.jl or Metal.jl
- Parallel tensor application where possible
- Improved truncation heuristics (adaptive tolerances)
- Support for mixed canonical forms

### Long-term
- Automatic contraction order optimization for MPS
- Integration with Julia's AD ecosystem
- Support for infinite MPS (iMPS)
- Quantum chemistry applications (DMRG integration)

## References

1. **MPS Algorithms**: https://tensornetwork.org/mps/algorithms/
2. **Zipup/Local Compress**: https://tensornetwork.org/mps/algorithms/zip_up_mpo/
3. **Density Matrix/Global Compress**: https://tensornetwork.org/mps/algorithms/denmat_mpo_mps/
4. **MPS Compression**: https://tensornetwork.org/mps/index.html#compression

## Repository Information

- **Package**: TreeContractor.jl
- **Version**: 1.0.0-DEV
- **Author**: nzy1997
- **Main Files**:
  - `src/TreeContractor.jl`: Module definition
  - `src/mps.jl`: MPS data structure and tensor application
  - `src/compress.jl`: Compression algorithms and canonicalization
  - `examples/qec.jl`: Quantum error correction example
  - `examples/kicked_ising.jl`: Quantum circuit simulation example

## Dependencies

- **OMEinsum.jl** (0.8-0.9): Einstein summation and contraction optimization
- **LinearAlgebra.jl**: Standard linear algebra operations
- **TensorQEC.jl** (2.2.1): Quantum error correction support

---

*This summary focuses on the tensor network contraction pipeline and compression algorithms, with emphasis on the `contract_with_mps` functionality and performance optimization strategies.*
