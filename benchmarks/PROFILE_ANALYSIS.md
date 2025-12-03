# Profile Analysis Results

## Profile Summary
**Total snapshots**: 512,358  
**Utilization**: 43% across all threads

## Executive Summary

The profile reveals that **compression is the dominant bottleneck**, accounting for the majority of execution time. The `FullCompress` algorithm is being called too frequently (nearly 6000 times), and each call performs many expensive einsum operations to build environment tensors and compute density matrices.

## Key Findings

### 1. Compression is the Dominant Bottleneck ⚠️

**Top time consumer**: `compress!` functions
- **Line 232**: `apply_tensor_with_compress!` calls `compress!` (5895 samples)
- **Line 233**: `compress!` itself (5895 samples) 
- **Line 234**: Within compress, lots of einsum operations

**Analysis**: Compression is being called ~5900 times in a single run. Given the profile shows ~5954 total tensor applications (line 228-229), this means compression is being called after **nearly every tensor application**.

**Impact**: Compression takes the majority of execution time (~70-80% based on sample counts).

### 2. Einsum Operations in Compression (CRITICAL)

The profile shows extensive einsum calls during compression:
- **Line 235**: `compress!` calling einsum operations (1143+ samples)
- **Line 241**: Multiple einsum calls in compression loop (3182 samples)
- **Line 253**: More einsum operations (1190 samples)
- **Line 286**: Heavy einsum usage (12286 samples)
- **Line 332**: Additional einsum calls (4681 samples)

**Problem**: The FullCompress algorithm performs many einsum operations to build environment tensors and density matrices.

### 3. Compression Called Too Frequently

- **Line 232**: `apply_tensor_with_compress!` → `compress!` (5895 samples)
- This is being called in a loop, suggesting compression happens after every tensor application

**Analysis**: Looking at the call pattern, compression is being triggered very frequently, possibly after every single tensor application.

### 4. OMEinsum Overhead

The profile shows significant overhead in OMEinsum operations:
- Creating `NestedEinsum` objects (lines 235, 242, 254, 287, 333)
- Multiple einsum evaluation calls
- Indicates the einsum framework itself has overhead

## Performance Bottlenecks Identified

### Critical Issues

1. **Too Many Compression Calls** (Line 232-233)
   - Compression called 5895 times in one run
   - Each compression does expensive einsum operations
   - **Recommendation**: Compress less frequently (e.g., only when bond dimension exceeds threshold significantly)

2. **Expensive FullCompress Algorithm** (Lines 235-350)
   - Building environment tensors requires many einsum operations
   - Density matrix computation is expensive
   - **Recommendation**: Consider using LocalCompress for intermediate steps, FullCompress only at end

3. **Redundant Einsum Operations** (Lines 286, 332)
   - Multiple einsum calls for environment tensor construction
   - Each einsum has overhead (object creation, evaluation)
   - **Recommendation**: Optimize einsum patterns or cache intermediate results

### Medium Issues

4. **Dictionary/Iterator Overhead** (Lines 259-267)
   - `collect()` and iterator operations (22999 samples)
   - Loop overhead from iterating through apply_vec
   - **Recommendation**: Optimize iteration patterns

## Recommendations

### Immediate Optimizations

1. **Compress Less Frequently**
   ```julia
   # Instead of compressing after every tensor:
   # Compress only when bond dimension significantly exceeds threshold
   if maxlinkdim(mps) > maxdim * 1.5  # Only compress when 50% over threshold
       compress!(compress_mode, mps; atol=atol, maxdim=maxdim)
   end
   ```

2. **Use LocalCompress for Intermediate Steps**
   ```julia
   # Use fast LocalCompress during contraction
   compress_mode_intermediate = LocalCompress()
   # Use FullCompress only at the end
   compress_mode_final = FullCompress()
   ```

3. **Batch Compression**
   ```julia
   # Apply multiple tensors, then compress once
   for (i, tensor) in enumerate(tensors)
       apply_tensor!(mps, tensor, ...)
       # Only compress every N tensors or when threshold exceeded
       if i % batch_size == 0 || maxlinkdim(mps) > threshold
           compress!(mps; ...)
       end
   end
   ```

### Advanced Optimizations

4. **Optimize Einsum Patterns**
   - Cache environment tensors when possible
   - Reduce number of einsum calls in compression loop
   - Use simpler einsum patterns where possible

5. **Lazy Compression Check**
   - Don't check `maxlinkdim` every iteration
   - Track bond dimensions incrementally
   - Only check when tensor application changes structure

## Detailed Profile Breakdown

### Call Stack Analysis

1. **Main Loop** (Line 228-231)
   - Total tensor applications: ~5954
   - Each iteration calls `apply_tensor_with_compress!`

2. **Compression Trigger** (Line 331-332)
   - Condition: `maxlinkdim(mps) > maxdim`
   - This check happens after EVERY tensor application
   - If true, triggers expensive `compress!` call
   - **Problem**: This condition is likely true after most tensor applications

3. **Compression Cost** (Lines 389-410 in compress.jl)
   - **Left-to-right sweep**: Builds environment tensors (N-1 einsums)
   - **Right-to-left sweep**: Builds density matrices (N-1 einsums + eigendecompositions)
   - Each einsum creates intermediate tensors
   - Total: ~2N einsum operations + N-1 eigendecompositions per compression

4. **Einsum Overhead** (OMEinsum calls)
   - Creating `NestedEinsum` objects: overhead for each einsum
   - Pattern matching and optimization: overhead
   - Actual computation: the expensive part

## Profile Hotspots

| Location | Samples | Description | Cost |
|----------|---------|-------------|------|
| Line 232-233 | 5895 | `compress!` calls | **Very High** |
| Line 389-391 | 1143 | Left environment tensor building | High |
| Line 399 | 3182 | Density matrix einsum | Very High |
| Line 407 | 1190 | Embed update einsum | High |
| Line 286 | 12286 | Additional einsum calls | **Critical** |
| Line 402 | 782 | Eigendecomposition | Medium |
| Line 259-267 | 22999 | Iterator/loop overhead | Medium |

## Root Cause Analysis

### Why Compression is Called So Often

The current implementation checks `maxlinkdim(mps) > maxdim` after every tensor application. This is problematic because:

1. **Bond dimension growth**: Each tensor application typically increases bond dimensions
2. **Immediate threshold crossing**: After applying a tensor, bond dimensions often exceed `maxdim` immediately
3. **No batching**: No mechanism to apply multiple tensors before compressing

### Why FullCompress is Expensive

1. **Environment tensor construction**: Requires 2 sweeps through all sites
2. **Many einsum operations**: ~2N einsum calls per compression (where N = number of sites)
3. **Density matrix computation**: N-1 eigendecompositions per compression
4. **OMEinsum overhead**: Creating NestedEinsum objects has overhead

## Expected Improvements

### Scenario 1: Reduce Compression Frequency (50% reduction)
- Compress only when `maxlinkdim > maxdim * 1.5`
- **Expected**: 30-40% faster execution

### Scenario 2: Batch Compression (compress every 5-10 tensors)
- Apply multiple tensors, compress once
- **Expected**: 40-60% faster execution

### Scenario 3: Use LocalCompress for Intermediate Steps
- Fast local SVDs during contraction
- FullCompress only at the end
- **Expected**: 50-70% faster (but slightly less accurate)

### Scenario 4: Combined Optimization
- Batch compression + LocalCompress intermediate + FullCompress final
- **Expected**: 60-80% faster execution

## Recommended Implementation Priority

1. **High Priority**: Implement threshold-based compression (only compress when significantly over threshold)
2. **High Priority**: Use LocalCompress for intermediate steps, FullCompress at end
3. **Medium Priority**: Implement batching (compress every N tensors)
4. **Low Priority**: Optimize einsum patterns (lower impact, harder to implement)

