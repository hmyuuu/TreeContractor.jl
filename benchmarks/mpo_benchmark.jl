using TreeContractor
using BenchmarkTools
using Random
using LinearAlgebra

"""
Benchmark comparison between LocalCompress and FullCompress algorithms for MPO application.
"""

function create_random_mps(T, N, d, χ_mps)
    """Create a random normalized ContractorMPS."""
    mps_tensors = [
        randn(T, 1, d, χ_mps),
        [randn(T, χ_mps, d, χ_mps) for _ in 2:(N-1)]...,
        randn(T, χ_mps, d, 1)
    ]
    mps = ContractorMPS(mps_tensors)
    normalize!(mps)
    return mps
end

function create_random_mpo(T, N, d, χ_mpo)
    """Create a random ContractorMPO."""
    mpo_tensors = [
        randn(T, 1, d, d, χ_mpo),
        [randn(T, χ_mpo, d, d, χ_mpo) for _ in 2:(N-1)]...,
        randn(T, χ_mpo, d, d, 1)
    ]
    return ContractorMPO(mpo_tensors)
end

function create_identity_mpo(T, N, d)
    """Create an identity ContractorMPO."""
    mpo_tensors = [
        zeros(T, 1, d, d, 1),
        [zeros(T, 1, d, d, 1) for _ in 2:(N-1)]...,
        zeros(T, 1, d, d, 1)
    ]
    for i in 1:N
        for a in 1:d
            mpo_tensors[i][1, a, a, 1] = one(T)
        end
    end
    return ContractorMPO(mpo_tensors)
end

function benchmark_mpo_application()
    println("=" ^ 80)
    println("MPO Application Benchmark Comparison")
    println("=" ^ 80)
    println()
    
    Random.seed!(42)
    T = ComplexF64
    d = 2  # physical dimension
    
    # Test cases: (N, χ_mps, χ_mpo, maxdim)
    test_cases = [
        (4, 3, 2, 10),
        (6, 4, 3, 15),
        (8, 5, 4, 20),
        (10, 6, 5, 25),
    ]
    
    for (N, χ_mps, χ_mpo, maxdim) in test_cases
        println("Test case: N=$N, χ_mps=$χ_mps, χ_mpo=$χ_mpo, maxdim=$maxdim")
        println("-" ^ 80)
        
        # Create random MPS and MPO
        mps = create_random_mps(T, N, d, χ_mps)
        mpo = create_random_mpo(T, N, d, χ_mpo)
        
        # Benchmark LocalCompress
        mps_local = copy(mps)
        b_local = @benchmark apply!(LocalCompress(), $mpo, $mps_local; atol=1e-12, maxdim=$maxdim) setup=(mps_local = copy($mps))
        
        # Benchmark FullCompress
        mps_full = copy(mps)
        b_full = @benchmark apply!(FullCompress(), $mpo, $mps_full; atol=1e-13, maxdim=$maxdim) setup=(mps_full = copy($mps))
        
        # Compare results
        mps_local_result = apply!(LocalCompress(), mpo, copy(mps); atol=1e-12, maxdim=maxdim)
        mps_full_result = apply!(FullCompress(), mpo, copy(mps); atol=1e-13, maxdim=maxdim)
        
        norm_local = norm(mps_local_result)
        norm_full = norm(mps_full_result)
        norm_diff = abs(norm_local - norm_full)
        
        println("LocalCompress:")
        println("  Time:     $(BenchmarkTools.prettytime(median(b_local.times)))")
        println("  Memory:   $(BenchmarkTools.prettymemory(b_local.memory))")
        println("  Norm:     $norm_local")
        println()
        println("FullCompress:")
        println("  Time:     $(BenchmarkTools.prettytime(median(b_full.times)))")
        println("  Memory:   $(BenchmarkTools.prettymemory(b_full.memory))")
        println("  Norm:     $norm_full")
        println()
        println("Comparison:")
        println("  Speedup:  $(round(median(b_full.times) / median(b_local.times), digits=2))x (LocalCompress faster)")
        println("  Norm diff: $norm_diff")
        println()
    end
    
    # Test with identity operator (should preserve norm exactly)
    println("=" ^ 80)
    println("Identity Operator Test (should preserve norm)")
    println("=" ^ 80)
    println()
    
    for (N, χ_mps, _, maxdim) in test_cases[1:2]
        println("Test case: N=$N, χ_mps=$χ_mps")
        println("-" ^ 80)
        
        mps = create_random_mps(T, N, d, χ_mps)
        mpo_identity = create_identity_mpo(T, N, d)
        norm_before = norm(mps)
        
        # Test LocalCompress
        mps_local = apply!(LocalCompress(), mpo_identity, copy(mps); atol=1e-12, maxdim=maxdim)
        norm_local = norm(mps_local)
        error_local = abs(norm_local - norm_before)
        
        # Test FullCompress
        mps_full = apply!(FullCompress(), mpo_identity, copy(mps); atol=1e-13, maxdim=maxdim)
        norm_full = norm(mps_full)
        error_full = abs(norm_full - norm_before)
        
        println("Original norm: $norm_before")
        println("LocalCompress norm: $norm_local (error: $error_local)")
        println("FullCompress norm:  $norm_full (error: $error_full)")
        println()
    end
    
    # Accuracy comparison with different truncation tolerances
    println("=" ^ 80)
    println("Accuracy Comparison (varying truncation tolerance)")
    println("=" ^ 80)
    println()
    
    N, χ_mps, χ_mpo, maxdim = test_cases[2]
    mps = create_random_mps(T, N, d, χ_mps)
    mpo = create_random_mpo(T, N, d, χ_mpo)
    
    # Reference: apply without truncation (large maxdim)
    mps_ref = apply!(FullCompress(), mpo, copy(mps); atol=1e-15, maxdim=1000)
    norm_ref = norm(mps_ref)
    
    println("Reference norm (no truncation): $norm_ref")
    println()
    
    for atol in [1e-10, 1e-12, 1e-14]
        println("Tolerance: $atol")
        println("-" ^ 40)
        
        # LocalCompress
        mps_local = apply!(LocalCompress(), mpo, copy(mps); atol=atol, maxdim=maxdim)
        norm_local = norm(mps_local)
        error_local = abs(norm_local - norm_ref)
        
        # FullCompress
        mps_full = apply!(FullCompress(), mpo, copy(mps); atol=atol, maxdim=maxdim)
        norm_full = norm(mps_full)
        error_full = abs(norm_full - norm_ref)
        
        println("  LocalCompress error: $error_local")
        println("  FullCompress error:  $error_full")
        println()
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    benchmark_mpo_application()
end

