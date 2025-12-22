using Test
using LinearAlgebra

# If Queyranne is not defined, we need to load it.
# Assuming this is included from runtests.jl where RankWidthAlgorithms is loaded.
# But if run independently, we need imports.
if !isdefined(Main, :RankWidthAlgorithms)
    # We assume we are in test/ and need to load parent
    include("../src/RankWidthAlgorithms.jl")
    using .RankWidthAlgorithms
end

# Alias for convenience
const Queyranne = RankWidthAlgorithms.Queyranne

@testset "Queyranne Algorithm" begin
    @testset "Modular Function (Min Element)" begin
        # Create a mock modular function
        struct ModularFunction <: Queyranne.AbstractSymmetricSubmodularFunction
            weights::Vector{Float64}
        end
        
        # For a modular function f(S) = sum(w[i] for i in S)
        # It is submodular. Is it symmetric? No.
        # Queyranne requires SYMMETRIC submodular.
        # Let's construct a symmetric one: f(S) = f(V\S)
        # Example: Cycle Graph Cut Function
        
        # C4 Cycle: 1-2-3-4-1
        # Cuts:
        # {1}: rank 2 (edges 1-2, 1-4)
        # {1,2}: rank 2 (edges 2-3, 1-4)
        # {1,3}: rank 2? No.
        # Edges from {1,3} to {2,4}:
        # 1-2, 1-4, 3-2, 3-4.
        # Matrix:
        # Rows: 1, 3. Cols: 2, 4.
        # M[1,2]=1, M[1,4]=1
        # M[3,2]=1, M[3,4]=1
        # Submatrix = [1 1; 1 1]. Rank is 1.
        
        # Wait. For C4, rank({1,3}) is 1.
        # Because row 1 = [1, 1], row 3 = [1, 1]. Linearly dependent.
        # So min cut is actually 1.0!
        
        adj = [
            0 1 0 1;
            1 0 1 0;
            0 1 0 1;
            1 0 1 0
        ]
        
        f = Queyranne.MatrixRankFunction(adj)
        
        (min_val, min_cut) = Queyranne.queyranne_min_cut(f)
        
        @test min_val == 1.0 # Corrected expectation
        @test !isempty(min_cut)
        @test length(min_cut) < 4
    end
    
    @testset "P3 Path Graph" begin
        # 1-2-3
        # Min cut: {1} (rank 1), {3} (rank 1). {2} (rank 2).
        adj = [
            0 1 0;
            1 0 1;
            0 1 0
        ]
        f = Queyranne.MatrixRankFunction(adj)
        (min_val, min_cut) = Queyranne.queyranne_min_cut(f)
        
        @test min_val == 1.0
        @test (1 in min_cut || 3 in min_cut)
    end
    
    @testset "Disjoint Graph" begin
        # 1-2   3-4
        # Min cut: {1,2} vs {3,4} -> rank 0
        adj = [
            0 1 0 0;
            1 0 0 0;
            0 0 0 1;
            0 0 1 0
        ]
        f = Queyranne.MatrixRankFunction(adj)
        (min_val, min_cut) = Queyranne.queyranne_min_cut(f)
        
        @test min_val == 0.0
    end
end
