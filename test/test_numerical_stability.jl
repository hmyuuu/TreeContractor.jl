@testset "Numerical Stability" begin
    @testset "lognorm tracking with extreme scales" begin
        Random.seed!(42)
        N, χ = 8, 10
        
        # Create a base MPS
        mps_base = TreeContractor.random_mps(Float64, N; maxdim=χ)
        base_value = TreeContractor.contract_mps(mps_base)[]
        
        # Test with large scale factor
        scale_large = 1e50
        mps_large = copy(mps_base)
        mps_large.tensors[1] = mps_large.tensors[1] .* scale_large
        
        # With lognorm tracking during canonicalization
        TreeContractor.canonicalize!(mps_large, 1, TreeContractor.SymmetricSVD(), TreeContractor.TrackLognorm())
        recovered_large = TreeContractor.true_value(mps_large)
        @test recovered_large ≈ base_value * scale_large rtol=1e-10
        
        # Test with small scale factor
        scale_small = 1e-50
        mps_small = copy(mps_base)
        mps_small.tensors[1] = mps_small.tensors[1] .* scale_small
        
        TreeContractor.canonicalize!(mps_small, 1, TreeContractor.SymmetricSVD(), TreeContractor.TrackLognorm())
        recovered_small = TreeContractor.true_value(mps_small)
        @test recovered_small ≈ base_value * scale_small rtol=1e-10
        
        # Test log_true_value for very extreme cases
        @test TreeContractor.log_true_value(mps_large) ≈ log(abs(base_value * scale_large)) rtol=1e-10
        @test TreeContractor.log_true_value(mps_small) ≈ log(abs(base_value * scale_small)) rtol=1e-10
    end

    @testset "relative tolerance (rtol)" begin
        Random.seed!(42)
        N, χ = 6, 20
        
        # Create MPS with entries of varying magnitudes
        mps1 = TreeContractor.random_mps(Float64, N; maxdim=χ)
        mps2 = copy(mps1)
        
        original_vec = vec(mps1)
        
        # Compress with absolute tolerance only (use IsometricSVD + NoTrackNorm to verify canonical form)
        TreeContractor.compress!(TreeContractor.LocalCompress(), mps1, TreeContractor.IsometricSVD(), TreeContractor.NoTrackNorm(); atol=1e-12, rtol=0.0, maxdim=10)
        
        # Compress with relative tolerance
        TreeContractor.compress!(TreeContractor.LocalCompress(), mps2, TreeContractor.IsometricSVD(), TreeContractor.NoTrackNorm(); atol=0.0, rtol=1e-10, maxdim=10)
        
        # Both should produce valid canonical form
        @test TreeContractor.check_canonical(mps1)
        @test TreeContractor.check_canonical(mps2)
        
        # Results should be close to original (with some truncation error)
        @test vec(mps1) ≈ original_vec atol=1e-4
        @test vec(mps2) ≈ original_vec atol=1e-4
    end

    @testset "symmetric SVD distribution" begin
        Random.seed!(42)
        N, χ = 8, 15
        
        # Create MPS
        mps_standard = TreeContractor.random_mps(Float64, N; maxdim=χ)
        mps_symmetric = copy(mps_standard)
        
        original_vec = vec(mps_standard)
        
        # Canonicalize with isometric method (NoTrackNorm to preserve tensor norms for comparison)
        TreeContractor.canonicalize!(mps_standard, N÷2, TreeContractor.IsometricSVD(), TreeContractor.NoTrackNorm())
        
        # Canonicalize with symmetric distribution (NoTrackNorm to preserve tensor norms for comparison)
        TreeContractor.canonicalize!(mps_symmetric, N÷2, TreeContractor.SymmetricSVD(), TreeContractor.NoTrackNorm())
        
        # Both should preserve the state
        @test vec(mps_standard) ≈ original_vec atol=1e-10
        @test vec(mps_symmetric) ≈ original_vec atol=1e-10
        
        # Check that symmetric distribution balances tensor magnitudes better
        # (tensors should have more similar Frobenius norms)
        norms_standard = [norm(t) for t in mps_standard.tensors]
        norms_symmetric = [norm(t) for t in mps_symmetric.tensors]
        
        # Coefficient of variation (std/mean) should be smaller for symmetric
        cv_standard = std(norms_standard) / mean(norms_standard)
        cv_symmetric = std(norms_symmetric) / mean(norms_symmetric)
        
        @test cv_symmetric < cv_standard || isapprox(cv_symmetric, cv_standard; atol=0.1)
    end

    @testset "numerical stability comparison" begin
        Random.seed!(42)
        N, χ = 10, 20
        
        # Create MPS with entries that will cause numerical issues without lognorm tracking
        mps_base = TreeContractor.random_mps(Float64, N; maxdim=χ)
        base_value = TreeContractor.contract_mps(mps_base)[]
        
        println("\n=== Numerical Stability Comparison ===")
        
        for log_scale in [10, 50, 100, 150]
            scale = exp(log_scale)
            
            # Test with lognorm tracking
            mps_tracked = copy(mps_base)
            mps_tracked.tensors[1] = mps_tracked.tensors[1] .* scale
            TreeContractor.compress!(TreeContractor.LocalCompress(), mps_tracked, TreeContractor.SymmetricSVD(), TreeContractor.TrackLognorm(); maxdim=χ)
            
            # Recover true value
            recovered = TreeContractor.true_value(mps_tracked)
            expected = base_value * scale
            
            rel_error = abs(recovered - expected) / abs(expected)
            
            println("Scale=exp($log_scale): relative error = $(round(rel_error, sigdigits=3))")
            
            # Should maintain accuracy even at extreme scales
            @test rel_error < 1e-8
        end
    end
end
