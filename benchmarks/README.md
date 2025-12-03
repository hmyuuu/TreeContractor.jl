# Benchmarks

This directory contains benchmark scripts for TreeContractor.

## MPO Application Benchmark

The `mpo_benchmark.jl` script compares the performance and accuracy of `LocalCompress` and `FullCompress` algorithms for applying Matrix Product Operators (MPO) to Matrix Product States (MPS).

### Running the Benchmark

```julia
using Pkg
Pkg.activate(".")
Pkg.add("BenchmarkTools")  # if not already installed

include("benchmarks/mpo_benchmark.jl")
```

Or from the command line:

```bash
julia --project=. benchmarks/mpo_benchmark.jl
```

### What it Measures

1. **Performance Comparison**: Execution time and memory usage for both algorithms across different system sizes
2. **Accuracy Comparison**: Norm preservation and error accumulation for different truncation tolerances
3. **Identity Operator Test**: Verifies that applying the identity operator preserves the state norm

### Expected Results

- **LocalCompress**: Faster but less accurate, suitable for intermediate calculations
- **FullCompress**: Slower but more accurate, recommended for final results

The benchmark will show:
- Time comparison (LocalCompress is typically 2-5x faster)
- Memory usage
- Norm preservation accuracy
- Error accumulation with different truncation tolerances

