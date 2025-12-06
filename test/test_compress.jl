@testset "Canonicalization and Compression" begin
    @testset "canonicalize (strict isometry)" begin
        Random.seed!(42)
        N, center, χ = 10, 5, 20
        T = ComplexF64
        mps = TreeContractor.random_mps(T, N; maxdim=χ)
        norm_init = norm(mps)

        # Use IsometricSVD + NoTrackNorm for strict canonical form with isometric tensors
        TreeContractor.canonicalize!(mps, center, TreeContractor.IsometricSVD(), TreeContractor.NoTrackNorm())

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

    @testset "canonicalize (symmetric)" begin
        Random.seed!(42)
        N, center, χ = 10, 5, 20
        T = ComplexF64
        mps = TreeContractor.random_mps(T, N; maxdim=χ)
        original_vec = vec(mps)

        # Default SymmetricSVD for numerical stability
        TreeContractor.canonicalize!(mps, center)

        @test TreeContractor.orthocenter(mps) == center
        @test TreeContractor.is_canonicalized(mps)
        # State should be preserved (relaxed tolerance for symmetric SVD)
        @test vec(mps) ≈ original_vec rtol=1e-10
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
        
        # Test compression with IsometricSVD + NoTrackNorm to check canonical form
        TreeContractor.compress!(TreeContractor.LocalCompress(), mps, TreeContractor.IsometricSVD(), TreeContractor.NoTrackNorm(); niters=2, maxdim=8)
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
end
