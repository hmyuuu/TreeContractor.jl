# Performance Analysis: contract_with_mps_contractor

## Identified Performance Issues

### 1. Redundant Dictionary Reconstruction (CRITICAL)
**Location**: `src/mps.jl:372`
**Issue**: `label_to_index = Dict(zip(labels, 1:length(labels)))` is called every time vanishing labels are handled
**Impact**: O(n) allocations per tensor application
**Solution**: Update dictionary incrementally instead of rebuilding

```julia
# Current (slow):
label_to_index = Dict(zip(labels, 1:length(labels)))

# Optimized:
# Update dictionary by shifting indices instead of rebuilding
for (old_idx, new_idx) in enumerate(1:length(labels))
    if old_idx ∉ vanish_pos
        label_to_index[labels[new_idx]] = new_idx
    else
        delete!(label_to_index, labels[old_idx])
    end
end
```

### 2. Redundant Canonical Center Movements (HIGH)
**Location**: `src/mps.jl:320-341`
**Issue**: Moving canonical center back and forth in loops, resetting to -1 after every sweep
**Impact**: Unnecessary O(n) canonicalization operations
**Solution**: Track center position more carefully, avoid resetting unnecessarily

**Problem**: 
- Lines 323-324: Moving center right in a loop
- Lines 328-329: Moving center left in a loop  
- Line 340: Moving right again immediately after
- Line 345: Reset center to -1, losing all canonicalization work

### 3. Multiple Passes Through Affected Region (MEDIUM)
**Location**: `src/mps.jl:294-303` and `src/mps.jl:319-342`
**Issue**: First pass checks bond consistency, second pass does compression - could combine
**Impact**: O(n) extra iterations
**Solution**: Check bonds and compress in a single pass

### 4. Repeated maxlinkdim Computations (MEDIUM)
**Location**: `src/mps.jl:381`
**Issue**: `maxlinkdim(mps)` iterates through all tensors every time
**Impact**: O(n) redundant computations
**Solution**: Cache max bond dimension, update incrementally

### 5. Inefficient Dictionary Lookups in Assertions (LOW)
**Location**: `src/mps.jl:258-260`
**Issue**: Multiple `label_to_index[l]` lookups in assertion loop
**Impact**: Minor overhead, but runs on every tensor application
**Solution**: Cache lookup results

### 6. Unnecessary Permutation and SVD in tensor2mps (MEDIUM)
**Location**: `src/mps.jl:262-263`
**Issue**: `permutedims(tensor, sorted_tensor_label)` creates a copy, then `tensor2mps` does SVD
**Impact**: Extra memory allocation and computation
**Solution**: Consider if permutation is always necessary

### 7. Redundant Bond Dimension Checks (LOW)
**Location**: `src/mps.jl:334`
**Issue**: Checking `bond_dim` every iteration when we already know which bonds need compression
**Impact**: Minor overhead
**Solution**: Compute bond dimensions once before loop

### 8. Inefficient vanish_labels Check (LOW)
**Location**: `src/mps.jl:276`, `src/mps.jl:355`
**Issue**: `labels[i] ∉ vanish_labels` is O(n) lookup (if vanish_labels is Vector)
**Impact**: O(n²) complexity
**Solution**: Use Set for O(1) lookups

## Optimization Priority

1. **HIGH Priority**:
   - Fix redundant dictionary reconstruction (#1)
   - Optimize canonical center movements (#2)
   - Combine bond check and compression passes (#3)

2. **MEDIUM Priority**:
   - Cache maxlinkdim (#4)
   - Optimize tensor2mps permutation (#6)

3. **LOW Priority**:
   - Dictionary lookup caching (#5)
   - Set-based vanish_labels (#8)
   - Redundant bond checks (#7)

## Expected Performance Improvements

After implementing HIGH priority optimizations:
- **Memory**: Reduce allocations by ~30-50% (eliminating dict reconstructions)
- **Time**: Reduce runtime by ~20-40% (eliminating redundant canonicalizations)

