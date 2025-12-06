@testset "Performance Benchmarks" begin
    @testset "performance benchmark" begin
        Random.seed!(42)
        N, χ = 20, 50
        
        # Warmup
        mps_warmup = TreeContractor.random_mps(Float64, 5; maxdim=10)
        TreeContractor.canonicalize!(mps_warmup, 3)
        
        # Benchmark isometric canonicalization (no tracking for fair comparison)
        mps1 = TreeContractor.random_mps(Float64, N; maxdim=χ)
        time_isometric = @elapsed begin
            for _ in 1:3
                TreeContractor.canonicalize!(copy(mps1), N÷2, TreeContractor.IsometricSVD(), TreeContractor.NoTrackNorm())
            end
        end
        
        # Benchmark symmetric canonicalization (no tracking for fair comparison)
        mps2 = TreeContractor.random_mps(Float64, N; maxdim=χ)
        time_symmetric = @elapsed begin
            for _ in 1:3
                TreeContractor.canonicalize!(copy(mps2), N÷2, TreeContractor.SymmetricSVD(), TreeContractor.NoTrackNorm())
            end
        end
        
        # Benchmark with lognorm tracking
        mps3 = TreeContractor.random_mps(Float64, N; maxdim=χ)
        time_tracked = @elapsed begin
            for _ in 1:3
                TreeContractor.canonicalize!(copy(mps3), N÷2, TreeContractor.SymmetricSVD(), TreeContractor.TrackLognorm())
            end
        end
        
        # Benchmark with rtol
        mps4 = TreeContractor.random_mps(Float64, N; maxdim=χ)
        time_rtol = @elapsed begin
            for _ in 1:3
                TreeContractor.canonicalize!(copy(mps4), N÷2; rtol=1e-12)
            end
        end
        
        # Benchmark with all options
        mps5 = TreeContractor.random_mps(Float64, N; maxdim=χ)
        time_all = @elapsed begin
            for _ in 1:3
                TreeContractor.canonicalize!(copy(mps5), N÷2, TreeContractor.SymmetricSVD(), TreeContractor.TrackLognorm(); rtol=1e-12)
            end
        end
        
        println("\n=== Performance Benchmark Results (N=$N, χ=$χ) ===")
        println("IsometricSVD:                  $(round(time_isometric*1000/3, digits=2)) ms")
        println("SymmetricSVD (default):        $(round(time_symmetric*1000/3, digits=2)) ms")
        println("SymmetricSVD + TrackLognorm:   $(round(time_tracked*1000/3, digits=2)) ms")
        println("With rtol:                     $(round(time_rtol*1000/3, digits=2)) ms")
        println("All options:                   $(round(time_all*1000/3, digits=2)) ms")
        
        # Overhead should be reasonable (less than 2x slowdown)
        @test time_symmetric < 2.0 * time_isometric + 0.01
        @test time_tracked < 2.0 * time_isometric + 0.01
        @test time_rtol < 2.0 * time_isometric + 0.01
    end
end
