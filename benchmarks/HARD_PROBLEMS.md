# Harder Benchmark Problems

## Overview

The benchmarks now use more challenging problems to better test the performance differences between implementations. The harder problems include:

1. **Larger bond dimensions** (5-6 instead of 2-3)
2. **More tensors** (6 instead of 4)
3. **Higher rank tensors** (rank-4 instead of rank-3)
4. **More complex tensor networks**

## Problem Specifications

### Problem 1: Larger Bond Dimension
- **Network**: `ein"abc,cde,egh,fbg->"` (4 tensors)
- **Bond Dimension**: 5
- **Maxdim**: 30-50
- **Complexity**: O(bd³) per tensor, larger intermediate bond dimensions

### Problem 2: More Tensors
- **Network**: `ein"abc,cde,efg,ghi,ijk,kla->"` (6 tensors)
- **Bond Dimension**: 4-5
- **Maxdim**: 25-35
- **Complexity**: More sequential operations, longer contraction path

### Problem 3: Higher Rank Tensors
- **Network**: `ein"abcd,cdef,efgh,ghab->"` (4 rank-4 tensors)
- **Bond Dimension**: 3
- **Maxdim**: 20
- **Complexity**: Higher dimensional tensors, more indices to contract

## Expected Performance Characteristics

### With Harder Problems

1. **Compression becomes more important**: Larger bond dimensions mean compression is triggered more frequently
2. **Algorithm differences are more visible**: The overhead/benefits of different compression methods become clearer
3. **Memory usage increases**: Larger tensors require more memory
4. **Timing differences are more significant**: Harder problems take longer, making differences more measurable

### Observations from Benchmarks

- **FullCompress**: May be slower due to environment tensor construction, but provides better accuracy
- **LocalCompress**: Often faster, especially for problems where compression is frequent
- **Original method**: Baseline performance, uses FullCompress internally

## Running Harder Benchmarks

### Simple Speed Test
```bash
julia --project=. benchmarks/contract_comparison_simple.jl
```

### Detailed Benchmark (with BenchmarkTools)
```bash
julia --project=. -e 'using Pkg; Pkg.add("BenchmarkTools")'
julia --project=. benchmarks/contract_comparison.jl
```

## Performance Scaling

As problems get harder:
- **Bond dimension**: Performance scales as O(χ³) for FullCompress, O(χ²) for LocalCompress
- **Number of tensors**: Linear scaling with more overhead from compression steps
- **Tensor rank**: Higher rank increases contraction complexity

## Notes

- Harder problems may take significantly longer to run
- Memory usage increases with bond dimension
- Compression becomes critical for feasibility
- LocalCompress may show speedup for problems requiring frequent compression

