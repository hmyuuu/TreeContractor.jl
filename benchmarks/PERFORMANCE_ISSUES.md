# Performance Issues in contract_with_mps_contractor

## Critical Issues (High Impact)

### 1. Dictionary Reconstruction (Lines 372, 360, 442, 454, 105)
**Problem**: `Dict(zip(labels, 1:length(labels)))` rebuilds entire dictionary
- Called after every vanishing label removal
- O(n) allocations per call
- Can happen multiple times per tensor application

**Fix**: Update dictionary incrementally
```julia
# Instead of rebuilding:
# label_to_index = Dict(zip(labels, 1:length(labels)))

# Update incrementally:
for idx in sort(vanish_pos, rev=true)
    delete!(label_to_index, labels[idx])
    # Shift indices
    for label in labels[(idx+1):end]
        label_to_index[label] -= 1
    end
end
```

### 2. Redundant Canonical Center Movements (Lines 320-342)
**Problem**: 
- Moving center position multiple times unnecessarily
- Reset to -1 after sweep (line 345), losing canonical form
- Can move center back and forth in the same loop

**Example**:
```julia
# Line 323-324: Move right to position i
# Line 340: Move right again immediately
# Line 345: Reset to -1, losing all work
```

**Fix**: Optimize center movement logic - track position better, avoid resets

### 3. Inefficient vanish_labels Lookup (Lines 276, 355, 421, 437)
**Problem**: `labels[i] ∉ vanish_labels` is O(n) when vanish_labels is Vector
- Called in loops, creating O(n²) complexity
- Also used in `findfirst` operations

**Fix**: Convert to Set for O(1) lookups
```julia
vanish_labels_set = Set(vanish_labels)
if labels[i] ∉ vanish_labels_set  # Now O(1)
```

## Medium Issues

### 4. Multiple Passes Through Affected Region
**Problem**: 
- Lines 294-303: Check bond consistency
- Lines 319-342: Compression sweep
- Could be combined into single pass

### 5. maxlinkdim Called Repeatedly (Line 381)
**Problem**: `maxlinkdim(mps)` iterates through all tensors
- Called even when we might not compress
- Could cache and update incrementally

**Fix**: 
```julia
# Cache max bond dimension
cached_maxdim = maxlinkdim(mps)
# Update incrementally after modifications
# Only recompute when needed
```

### 6. Redundant Bond Dimension Checks (Line 334)
**Problem**: Checking bond dimension every iteration
- Already checked in bond consistency pass
- Could compute once before loop

## Low Priority Issues

### 7. Assertion Loop Dictionary Lookups (Lines 258-260)
**Problem**: Multiple `label_to_index[l]` lookups in assertion
**Fix**: Cache results or remove redundant checks in release mode

### 8. Unnecessary Permutation Copy (Line 263)
**Problem**: `permutedims` creates copy before SVD
**Fix**: Consider if permutation can be avoided or done in-place

## Recommended Fix Order

1. **Fix #3** (vanish_labels Set) - Easy, immediate O(n²) → O(n) improvement
2. **Fix #1** (Dictionary incremental update) - Medium, large allocation reduction  
3. **Fix #2** (Canonical center optimization) - Hard, but major performance win
4. **Fix #5** (maxlinkdim caching) - Easy, minor improvement
5. **Fix #4** (Combine passes) - Medium, reduces iterations

## Expected Improvements

- **Memory**: 30-50% reduction in allocations
- **Speed**: 20-40% faster execution
- **Scalability**: Better for large networks (O(n²) → O(n) operations)





