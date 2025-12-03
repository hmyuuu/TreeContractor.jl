# Speed Comparison: contract_with_mps vs contract_with_mps_contractor

## Overview

This document summarizes the speed comparison between the original `contract_with_mps` implementation and the new `contract_with_mps_contractor` implementation with different compression modes.

## Benchmark Results

### Test Setup

- **Tensor Network**: `ein"abc,cde,egh,fbg->"` (4 tensors)
- **Bond Dimension**: 3
- **Compression**: maxdim varies from 10 to 30

### Methods Compared

1. **Original**: `contract_with_mps` (uses `FullCompress` internally)
2. **Contractor (FullCompress)**: `contract_with_mps_contractor` with `FullCompress` mode
3. **Contractor (LocalCompress)**: `contract_with_mps_contractor` with `LocalCompress` mode

## Expected Performance Characteristics

### Original Method
- Uses `FullCompress` algorithm
- Direct compression on `LabeledMPS`
- O(N χ³ d²) complexity for compression

### Contractor with FullCompress
- Uses MPO application framework
- Applies identity MPO with `FullCompress`
- Similar complexity to original (O(N χ³ d²))
- May have slight overhead from MPO framework

### Contractor with LocalCompress
- Uses MPO application framework
- Applies identity MPO with `LocalCompress`
- Faster compression (O(N χ² d²))
- Less accurate but faster

## Running the Benchmarks

### Simple Speed Test (No BenchmarkTools required)

```bash
julia --project=. benchmarks/contract_comparison_simple.jl
```

This provides basic timing information using `time()` function.

### Detailed Benchmark (Requires BenchmarkTools)

```bash
julia --project=. -e 'using Pkg; Pkg.add("BenchmarkTools")'
julia --project=. benchmarks/contract_comparison.jl
```

This provides detailed statistics including:
- Median, mean, min, max times
- Memory usage
- Allocation counts
- Performance across different maxdim values

## Interpretation

- **Speedup < 1.0**: The new method is slower (overhead from MPO framework)
- **Speedup = 1.0**: Methods are equally fast
- **Speedup > 1.0**: The new method is faster

## Notes

1. The contractor implementation may have slight overhead due to:
   - Conversion between `LabeledMPS` and `ContractorMPS`
   - Identity MPO construction
   - MPO application framework overhead

2. For small problems, the overhead may dominate, making the original method faster.

3. For larger problems or when compression is frequent, the difference may be more significant.

4. `LocalCompress` mode should generally be faster than `FullCompress` due to lower complexity.

