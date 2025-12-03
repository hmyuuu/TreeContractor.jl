using TreeContractor
using Test
using TreeContractor.OMEinsum
using Random
using LinearAlgebra



@testset "tensor2mps and contract_mps" begin
    ashape = (6, 3, 4, 5)
    a = rand(Float64, ashape)
    b, bd_vec = TreeContractor.tensor2mps(a)
    bd = 1
    @test bd_vec[1] == 1
    for (i,s) in enumerate(ashape)
        bdnew = size(b[i])[3]
        @test size(b[i]) == (bd, s, bdnew)
        bd = bdnew
        @test bd_vec[i+1] == bdnew
    end
    @test TreeContractor.contract_mps(b)[] ≈ sum(a) atol = 1e-10
end

@testset "delta_mps" begin
    a = TreeContractor.delta_mps(2,3,Float64)
    @test a[:,1,:] == I(2)
    @test a[:,2,:] == I(2)
    @test a[:,3,:] == I(2)
end

@testset "apply_rank_3_tensor" begin
    Random.seed!(1234)
    t1 = rand(2,2,2)
    t2 = rand(2,2,2)
    t3 = rand(2,2,2)
    t4 = rand(2,2,2)

    m = ein"bfc,efg,cad,gah->bedh"(t1,t2,t3,t4)
    m = reshape(m, 2*2,2*2)

    m1 = TreeContractor.apply_rank_3_tensor(t1,t2)
    m2 = TreeContractor.apply_rank_3_tensor(t3,t4)
    mp = ein"bfc,cad-> bd"(m1,m2)
    @test m ≈ mp atol = 1e-10
end

@testset "contract_with_mps" begin
    code = ein"abc,abd->"
    optcode = optimize_code(code, uniformsize(code, 2), OMEinsum.PathSA())

    Random.seed!(1234)
    t1 = rand(2,2,2)
    t2 = rand(2,2,2)

    tensors = [t1, t2]
    right_answer = optcode(t1, t2)[]

    @test contract_with_mps(optcode, tensors, uniformsize(code, 2))[1][] ≈ right_answer atol = 1e-10
end

@testset "contract_with_mps" begin
    code = ein"ac,bd,ab,cd->"
    size_dict = Dict('a' => 2, 'b' => 3, 'c' => 4, 'd' => 5)
    optcode = optimize_code(code, size_dict, OMEinsum.PathSA())

    Random.seed!(1234)
    t1 = rand(2,4)
    t2 = rand(3,5)
    t3 = rand(2,3)
    t4 = rand(4,5)

    tensors = [t1, t2, t3, t4]
    right_answer = optcode(tensors...)[]

    @test contract_with_mps(optcode, tensors, size_dict)[1][] ≈ right_answer atol = 1e-10
end

@testset "contract_with_mps" begin
    code = ein"abc,cde,egh,fbg->"
    optcode = optimize_code(code, uniformsize(code, 2), OMEinsum.PathSA())

    Random.seed!(1234)
    t1 = rand(2,2,2)
    t2 = rand(2,2,2)
    t3 = rand(2,2,2)
    t4 = rand(2,2,2)
    
    tensors = [t1, t2, t3, t4]
    right_answer = optcode(tensors...)[]
    @show right_answer

    mps, apply_vec, tensor_labels, vanish_labels_vec = TreeContractor.code2mps(optcode,uniformsize(code, 2)); mps = TreeContractor.apply_tensors!(mps, apply_vec, tensors, tensor_labels, vanish_labels_vec)

    @show mps.tensors

    @test contract_with_mps(optcode, tensors, uniformsize(code, 2))[1][] ≈ right_answer atol = 1e-10
end


@testset "canonicalize" begin
    Random.seed!(42)
    N, center, χ = 10, 5, 20
    T = ComplexF64
    mps = TreeContractor.random_mps(T, N; maxdim=χ)
    norm_init = norm(mps)

    TreeContractor.canonicalize!(mps, center)

    for i in 1:(center - 1)
        U = reshape(mps.tensors[i], size(mps.tensors[i])[1] * size(mps.tensors[i])[2], :)
        @test U' * U ≈ LinearAlgebra.I
    end
    for i in (center + 1):TreeContractor.nsite(mps)
        V = reshape(mps.tensors[i], :, size(mps.tensors[i])[2] * size(mps.tensors[i])[3])
        @test V * V' ≈ LinearAlgebra.I
    end

    @test TreeContractor.orthocenter(mps) == center
    @test norm(mps) ≈ norm_init
    @test TreeContractor.is_canonicalized(mps)
    @test TreeContractor.check_canonical(mps)
end


@testset "compression by local SVD" begin
    N = 6
    Random.seed!(42)
    χ = 8
    # Create MPS with high bond dimensions
    mps = TreeContractor.LabeledMPS([
        randn(ComplexF64, 1, 2, χ),
        [randn(ComplexF64, χ, 2, χ) for _ in 2:(N-1)]...,
        randn(ComplexF64, χ, 2, 1)
    ], [i for i in 1:N])
    
    original_vec = vec(mps)
    original_elements = TreeContractor.num_of_elements(mps)
    
    # Test compression
    TreeContractor.compress!(TreeContractor.LocalCompress(), mps; niters=2, maxdim=8)
    compressed_elements = TreeContractor.num_of_elements(mps)
    
    @test compressed_elements < original_elements
    @test TreeContractor.check_canonical(mps)
    @test vec(mps) ≈ original_vec atol=1e-4
end

@testset "compression by global SVD" begin
    N = 6
    Random.seed!(42)
    χ = 8
    # Create MPS with high bond dimensions
    mps = TreeContractor.LabeledMPS([
        randn(ComplexF64, 1, 2, χ),
        [randn(ComplexF64, χ, 2, χ) for _ in 2:(N-1)]...,
        randn(ComplexF64, χ, 2, 1)
    ], [i for i in 1:N])

    TreeContractor.normalize!(mps)
    
    original_vec = vec(mps)
    original_elements = TreeContractor.num_of_elements(mps)
    
    # Test compression
    TreeContractor.compress!(TreeContractor.FullCompress(), mps; maxdim=8)
    compressed_elements = TreeContractor.num_of_elements(mps)
    
    @test compressed_elements < original_elements
    @test TreeContractor.check_canonical(mps)
    @test vec(mps) ≈ original_vec atol=1e-14
end

@testset "contract_with_mps" begin
    code = ein"abc,cde,egh,fbg,yczd,ybzc->"
    bd = 3
    optcode = optimize_code(code, uniformsize(code, bd), OMEinsum.PathSA())

    Random.seed!(1234)
    t1 = rand(bd,bd,bd)
    t2 = rand(bd,bd,bd)
    t3 = rand(bd,bd,bd)
    t4 = rand(bd,bd,bd)
    t5 = rand(bd,bd,bd,bd)
    t6 = rand(bd,bd,bd,bd)

    tensors = [t1, t2, t3, t4, t5, t6]
    right_answer = optcode(tensors...)[]
    @show right_answer

    @test contract_with_mps(optcode, tensors, uniformsize(code, bd); maxdim = 10)[1][] ≈ right_answer atol = 1e-10
end


@testset "tensor with output label" begin
    code = ein"abc,cde,egh,fbg->f"
    bd = 5
    optcode = optimize_code(code, uniformsize(code, bd), OMEinsum.PathSA())

    Random.seed!(1234)
    t1 = rand(bd,bd,bd)
    t2 = rand(bd,bd,bd)
    t3 = rand(bd,bd,bd)
    t4 = rand(bd,bd,bd)
    
    tensors = [t1, t2, t3, t4]
    right_answer = optcode(tensors...)
    @show right_answer

    @test contract_with_mps(optcode, tensors, uniformsize(code, bd); maxdim = 10)[1][1,:,1] ≈ right_answer atol = 1e-10
end

@testset "contract_with_mps_contractor" begin
    code = ein"abc,abd->"
    optcode = optimize_code(code, uniformsize(code, 2), OMEinsum.PathSA())
    
    Random.seed!(1234)
    t1 = rand(2,2,2)
    t2 = rand(2,2,2)
    tensors = [t1, t2]
    
    # Test without compression
    result_contractor = contract_with_mps_contractor(optcode, tensors, uniformsize(code, 2); maxdim=Inf, compress_mode=FullCompress(), atol=1e-12)
    result_original = contract_with_mps(optcode, tensors, uniformsize(code, 2); maxdim=Inf)
    reference = optcode(t1, t2)[]
    
    @test result_contractor[1][] ≈ reference atol=1e-10
    @test result_original[1][] ≈ reference atol=1e-10
    @test result_contractor[1][] ≈ result_original[1][] atol=1e-10
end

@testset "contract_with_mps_contractor with compression" begin
    code = ein"abc,cde,egh,fbg->"
    optcode = optimize_code(code, uniformsize(code, 2), OMEinsum.PathSA())
    
    Random.seed!(1234)
    t1 = rand(2,2,2)
    t2 = rand(2,2,2)
    t3 = rand(2,2,2)
    t4 = rand(2,2,2)
    tensors = [t1, t2, t3, t4]
    
    reference = optcode(tensors...)[]
    
    # Test with compression - both methods should produce similar results
    result_contractor_full = contract_with_mps_contractor(optcode, tensors, uniformsize(code, 2); maxdim=10, compress_mode=FullCompress(), atol=1e-12)
    result_contractor_local = contract_with_mps_contractor(optcode, tensors, uniformsize(code, 2); maxdim=10, compress_mode=LocalCompress(), atol=1e-12)
    result_original = contract_with_mps(optcode, tensors, uniformsize(code, 2); maxdim=10)
    
    # With compression, results may differ but should be reasonable
    @test abs(result_contractor_full[1][] - reference) < 1e-5
    @test abs(result_contractor_local[1][] - reference) < 1e-5
    @test abs(result_original[1][] - reference) < 1e-5
end

@testset "ContractorMPO and ContractorMPS basic operations" begin
    Random.seed!(42)
    N = 4
    d = 2  # physical dimension
    χ_mps = 3  # MPS bond dimension
    χ_mpo = 2  # MPO bond dimension
    
    # Create random ContractorMPS
    mps_tensors = [
        randn(ComplexF64, 1, d, χ_mps),
        [randn(ComplexF64, χ_mps, d, χ_mps) for _ in 2:(N-1)]...,
        randn(ComplexF64, χ_mps, d, 1)
    ]
    mps = TreeContractor.ContractorMPS(mps_tensors)
    
    # Create random ContractorMPO
    mpo_tensors = [
        randn(ComplexF64, 1, d, d, χ_mpo),
        [randn(ComplexF64, χ_mpo, d, d, χ_mpo) for _ in 2:(N-1)]...,
        randn(ComplexF64, χ_mpo, d, d, 1)
    ]
    mpo = TreeContractor.ContractorMPO(mpo_tensors)
    
    @test TreeContractor.nsite(mps) == N
    @test TreeContractor.nsite(mpo) == N
    @test TreeContractor.nflavor(mps) == d
    @test TreeContractor.nflavor(mpo) == d
    @test TreeContractor.maxlinkdim(mps) >= 1
    @test TreeContractor.maxlinkdim(mpo) >= 1
    
    # Test copy
    mps_copy = copy(mps)
    @test mps_copy.center == mps.center
    @test length(mps_copy.data) == length(mps.data)
    mps_copy.data[1] .*= 2
    @test mps.data[1] ≠ mps_copy.data[1]  # Should be independent
end

@testset "MPO application with LocalCompress" begin
    Random.seed!(42)
    N = 4
    d = 2
    χ_mps = 3
    χ_mpo = 2
    
    # Create normalized ContractorMPS
    mps_tensors = [
        randn(ComplexF64, 1, d, χ_mps),
        [randn(ComplexF64, χ_mps, d, χ_mps) for _ in 2:(N-1)]...,
        randn(ComplexF64, χ_mps, d, 1)
    ]
    mps = TreeContractor.ContractorMPS(mps_tensors)
    TreeContractor.normalize!(mps)
    norm_before = norm(mps)
    
    # Create identity ContractorMPO (should preserve state)
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
    mpo = TreeContractor.ContractorMPO(mpo_tensors)
    
    # Apply MPO
    mps_result = TreeContractor.apply!(TreeContractor.LocalCompress(), mpo, copy(mps); atol=1e-12, maxdim=20)
    
    @test TreeContractor.nsite(mps_result) == N
    @test TreeContractor.is_canonicalized(mps_result)
    @test mps_result.center == N
    @test norm(mps_result) ≈ norm_before atol=1e-10
end

@testset "MPO application with FullCompress" begin
    Random.seed!(42)
    N = 4
    d = 2
    χ_mps = 3
    χ_mpo = 2
    
    # Create normalized ContractorMPS
    mps_tensors = [
        randn(ComplexF64, 1, d, χ_mps),
        [randn(ComplexF64, χ_mps, d, χ_mps) for _ in 2:(N-1)]...,
        randn(ComplexF64, χ_mps, d, 1)
    ]
    mps = TreeContractor.ContractorMPS(mps_tensors)
    TreeContractor.normalize!(mps)
    norm_before = norm(mps)
    
    # Create identity ContractorMPO
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
    mpo = TreeContractor.ContractorMPO(mpo_tensors)
    
    # Apply MPO
    mps_result = TreeContractor.apply!(TreeContractor.FullCompress(), mpo, copy(mps); atol=1e-13, maxdim=20)
    
    @test TreeContractor.nsite(mps_result) == N
    @test TreeContractor.is_canonicalized(mps_result)
    @test mps_result.center == 1
    @test norm(mps_result) ≈ norm_before atol=1e-10
end

@testset "MPO application: LocalCompress vs FullCompress" begin
    Random.seed!(42)
    N = 5
    d = 2
    χ_mps = 4
    χ_mpo = 3
    
    # Create normalized ContractorMPS
    mps_tensors = [
        randn(ComplexF64, 1, d, χ_mps),
        [randn(ComplexF64, χ_mps, d, χ_mps) for _ in 2:(N-1)]...,
        randn(ComplexF64, χ_mps, d, 1)
    ]
    mps = TreeContractor.ContractorMPS(mps_tensors)
    TreeContractor.normalize!(mps)
    
    # Create random ContractorMPO
    mpo_tensors = [
        randn(ComplexF64, 1, d, d, χ_mpo),
        [randn(ComplexF64, χ_mpo, d, d, χ_mpo) for _ in 2:(N-1)]...,
        randn(ComplexF64, χ_mpo, d, d, 1)
    ]
    mpo = TreeContractor.ContractorMPO(mpo_tensors)
    
    # Apply with both methods
    mps_local = TreeContractor.apply!(TreeContractor.LocalCompress(), mpo, copy(mps); atol=1e-12, maxdim=30)
    mps_full = TreeContractor.apply!(TreeContractor.FullCompress(), mpo, copy(mps); atol=1e-13, maxdim=30)
    
    # Both should produce valid MPS
    @test TreeContractor.nsite(mps_local) == N
    @test TreeContractor.nsite(mps_full) == N
    @test TreeContractor.is_canonicalized(mps_local)
    @test TreeContractor.is_canonicalized(mps_full)
    
    # Norms should be similar (both methods should preserve norm approximately)
    @test norm(mps_local) ≈ norm(mps_full) atol=1e-8
end

@testset "sandwich and expectation" begin
    Random.seed!(42)
    N = 3
    d = 2
    χ_mps = 3
    χ_mpo = 2
    
    # Create normalized ContractorMPS
    mps_tensors = [
        randn(ComplexF64, 1, d, χ_mps),
        [randn(ComplexF64, χ_mps, d, χ_mps) for _ in 2:(N-1)]...,
        randn(ComplexF64, χ_mps, d, 1)
    ]
    mps = TreeContractor.ContractorMPS(mps_tensors)
    TreeContractor.normalize!(mps)
    
    # Create identity ContractorMPO
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
    mpo = TreeContractor.ContractorMPO(mpo_tensors)
    
    # Test sandwich (should be 1 for identity operator on normalized state)
    sandwich_val = TreeContractor.sandwich(mps, mpo, mps)
    @test real(sandwich_val) ≈ 1.0 atol=1e-10
    
    # Test expectation (should also be 1)
    exp_val = TreeContractor.expectation(mpo, mps)
    @test exp_val ≈ 1.0 atol=1e-10
end

@testset "ContractorMPS compression: LocalCompress" begin
    Random.seed!(42)
    N = 6
    d = 2
    χ = 8
    
    # Create ContractorMPS with high bond dimensions
    mps_tensors = [
        randn(ComplexF64, 1, d, χ),
        [randn(ComplexF64, χ, d, χ) for _ in 2:(N-1)]...,
        randn(ComplexF64, χ, d, 1)
    ]
    mps = TreeContractor.ContractorMPS(mps_tensors)
    TreeContractor.normalize!(mps)
    norm_before = norm(mps)
    original_maxdim = TreeContractor.maxlinkdim(mps)
    
    # Test compression
    TreeContractor.compress!(TreeContractor.LocalCompress(), mps; niters=2, maxdim=4, atol=1e-12)
    compressed_maxdim = TreeContractor.maxlinkdim(mps)
    
    @test compressed_maxdim <= 4
    @test compressed_maxdim < original_maxdim
    @test TreeContractor.is_canonicalized(mps)
    @test norm(mps) ≈ norm_before atol=1e-4  # LocalCompress may have some error
end

@testset "ContractorMPS compression: FullCompress" begin
    Random.seed!(42)
    N = 6
    d = 2
    χ = 8
    
    # Create ContractorMPS with high bond dimensions
    mps_tensors = [
        randn(ComplexF64, 1, d, χ),
        [randn(ComplexF64, χ, d, χ) for _ in 2:(N-1)]...,
        randn(ComplexF64, χ, d, 1)
    ]
    mps = TreeContractor.ContractorMPS(mps_tensors)
    TreeContractor.normalize!(mps)
    norm_before = norm(mps)
    original_maxdim = TreeContractor.maxlinkdim(mps)
    
    # Test compression
    TreeContractor.compress!(TreeContractor.FullCompress(), mps; maxdim=4, atol=1e-12)
    compressed_maxdim = TreeContractor.maxlinkdim(mps)
    
    @test compressed_maxdim <= 4
    @test compressed_maxdim < original_maxdim
    @test TreeContractor.is_canonicalized(mps)
    @test norm(mps) ≈ norm_before atol=1e-12  # FullCompress should be more accurate
end

@testset "ContractorMPS canonicalization" begin
    Random.seed!(42)
    N = 5
    d = 2
    χ = 4
    center = 3
    
    # Create ContractorMPS
    mps_tensors = [
        randn(ComplexF64, 1, d, χ),
        [randn(ComplexF64, χ, d, χ) for _ in 2:(N-1)]...,
        randn(ComplexF64, χ, d, 1)
    ]
    mps = TreeContractor.ContractorMPS(mps_tensors)
    TreeContractor.normalize!(mps)
    norm_init = norm(mps)
    
    # Canonicalize
    TreeContractor.canonicalize!(mps, center; atol=1e-12, maxdim=typemax(Int))
    
    @test TreeContractor.is_canonicalized(mps)
    @test mps.center == center
    @test norm(mps) ≈ norm_init atol=1e-10
end
