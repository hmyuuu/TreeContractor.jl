# Profile Comparison: Before vs After Optimizations

## Summary Statistics

### Overall Performance

| Metric | Before Optimization | After Optimization | Change |
|--------|---------------------|-------------------|--------|
| **Total Snapshots** | 512,358 | 473,940 | **-7.5%** ✓ |
| **Compression Calls** | ~5,895 | ~5,559 | **-5.7%** |
| **Total Tensor Applications** | ~5,954 | ~5,613 | Similar workload |

### Key Observations

1. **Modest improvement in total snapshots** (~7.5% reduction)
2. **Small reduction in compression calls** (~6% reduction, less than expected)
3. **Workload is similar** (~5,600 tensor applications in both cases)

## Detailed Comparison

### Compression Frequency

**Before (Line 232-233 in old profile)**:
```
Line 232: apply_tensor_with_compress! calls compress! (5895 samples)
Line 233: compress! itself (5895 samples)
```

**After (Line 523-524 in new profile)**:
```
Line 523: apply_tensor_with_compress! calls compress! (5559 samples)  
Line 524: compress! itself (5559 samples)
```

**Analysis**: Compression calls reduced from ~5,895 to ~5,559 (5.7% reduction). This is less than the expected 50-70% reduction, suggesting the threshold factor may need adjustment.

### Einsum Operations in Compression

**Before**:
- Line 235: 1143+ samples (left environment tensor building)
- Line 241: 3182 samples (multiple einsum calls)
- Line 286: 12286 samples (heavy einsum usage) - **Critical bottleneck**
- Line 332: 4681 samples (additional einsum calls)
- Line 402: 782 samples (eigendecomposition)

**After**:
- Line 525: 986 samples (left environment tensor building) - **15% reduction**
- Line 531: 3111 samples (multiple einsum calls) - **2% reduction**
- Line 577: 11576 samples (density matrix einsum) - **6% reduction**
- Line 622: 4331 samples (embed update einsum) - **8% reduction**
- Line 614: 653 samples (eigendecomposition) - **16% reduction**

**Analysis**: Einsum operations show modest reductions (2-16%), indicating the caching optimizations are working but the main bottleneck (density matrix einsum) still dominates.

### Profile Hotspots Comparison

#### Before Optimization
| Location | Samples | Description |
|----------|---------|-------------|
| Line 232-233 | 5895 | `compress!` calls |
| Line 286 | 12286 | Density matrix einsum (CRITICAL) |
| Line 241 | 3182 | Multiple einsum calls |
| Line 332 | 4681 | Additional einsum calls |
| Line 402 | 782 | Eigendecomposition |

#### After Optimization
| Location | Samples | Description |
|----------|---------|-------------|
| Line 523-524 | 5559 | `compress!` calls (6% ↓) |
| Line 577 | 11576 | Density matrix einsum (6% ↓) |
| Line 531 | 3111 | Multiple einsum calls (2% ↓) |
| Line 622 | 4331 | Embed update einsum (8% ↓) |
| Line 614 | 653 | Eigendecomposition (16% ↓) |

## Why Less Improvement Than Expected?

### 1. Threshold Factor May Not Be Aggressive Enough

The threshold factor of 1.5 (50% over threshold) appears too conservative:
- **Issue**: If bond dimensions grow incrementally, they quickly pass the 1.5x threshold
- **Observation**: Only 6% reduction in compression calls (5895 → 5559) suggests threshold isn't effective enough
- **Analysis**: Compression rate is still ~99% (5559/5613 tensor applications)
- **Recommendation**: Consider increasing threshold factor to 2.0 or 2.5, or make it configurable

### 2. Compression Still Called Very Frequently

Even with threshold optimization:
- **Before**: 5895 compression calls for ~5954 tensor applications ≈ 99% compression rate
- **After**: 5559 compression calls for ~5613 tensor applications ≈ 99% compression rate
- **Problem**: Compression is still happening after almost every tensor application

### 3. Einsum Overhead Remains Dominant

The density matrix einsum (line 577, 11576 samples) is still the largest bottleneck:
- **Before**: 12286 samples (24% of total)
- **After**: 11576 samples (24% of total)
- **Reduction**: Only 6%, indicating the optimization had limited impact on this critical path

## Recommendations for Further Optimization

### 1. Increase Threshold Factor (HIGH PRIORITY)

```julia
# Current: threshold_factor = 1.5
# Suggested: threshold_factor = 2.0 or 2.5
threshold_factor = 2.0  # Only compress when 100% over threshold
```

**Expected impact**: Reduce compression calls by additional 30-50%

### 2. Use LocalCompress for Intermediate Steps

The profile shows FullCompress is still expensive. Consider:
- Use `LocalCompress()` for intermediate compressions (faster)
- Use `FullCompress()` only at the end (accurate)

**Expected impact**: 40-60% faster compression per call

### 3. Batch Compression

Instead of checking after every tensor, compress every N tensors:
```julia
if i % 5 == 0 || current_maxlink > maxdim * threshold_factor
    compress!(...)
end
```

**Expected impact**: Reduce compression calls by 60-80%

### 4. Optimize Density Matrix Einsum (ADVANCED)

The density matrix einsum (line 577) is the dominant bottleneck. Consider:
- Breaking it into smaller einsums
- Using BLAS operations where possible
- Caching more intermediate results

## Performance Metrics

### Current Status
- **Total runtime reduction**: ~7.5% (modest improvement)
- **Compression call reduction**: ~6% (less than expected)
- **Einsum optimization impact**: 2-16% per operation type

### Improvement Potential
If all recommendations are implemented:
- **Threshold factor increase**: +20-30% additional speedup
- **LocalCompress for intermediates**: +40-60% compression speedup
- **Batch compression**: +30-50% reduction in compression calls
- **Combined potential**: **60-80% total speedup**

## Conclusion

The optimizations show **modest improvements** (~7.5% overall), but there's significant room for further optimization:

1. ✅ **Threshold-based compression**: Working but could be more aggressive
2. ✅ **Einsum caching**: Working (2-16% improvements) but density matrix still dominant
3. ⚠️ **Compression frequency**: Still too high (99% of tensor applications trigger compression)
4. 🔄 **Next steps**: Increase threshold factor, use LocalCompress for intermediates, implement batching

The foundation is in place, but more aggressive optimization strategies are needed to achieve the expected 40-50% improvement.

