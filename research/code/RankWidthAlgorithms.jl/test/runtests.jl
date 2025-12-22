using Test
using LinearAlgebra

# Directly include the source files if not running as a package
if !isdefined(Main, :RankWidthAlgorithms)
    include("../src/RankWidthAlgorithms.jl")
end
using .RankWidthAlgorithms

@testset "RankWidthAlgorithms.jl" begin
    # Include the Queyranne tests
    include("test_queyranne.jl")
    include("test_localsearch.jl")

    @testset "Structures" begin
        # Create a simple tree: (1, 2) - (3, 4)
        t_left = SubCubicTree(1, 1, 2)
        t_right = SubCubicTree(2, 3, 4)
        root = SubCubicTree(0, t_left, t_right)
        
        @test root.left.left == 1
        @test root.right.right == 4
    end

    @testset "Rank Width Heuristic" begin
        # C4 Graph
        G_c4 = [0 1 0 1; 1 0 1 0; 0 1 0 1; 1 0 1 0]
        rd = rank_width(G_c4)
        
        @test rd.width >= 1
        @test rd.width <= 2 # Naive bound
        # Ideally it should find 1, but it's a randomized heuristic.
        # Let's run it multiple times if needed, or just check validity.
        
        @test rd.G == G_c4
        @test isa(rd.tree, SubCubicTree)
        
        # Tree Graph (Path P4: 1-2-3-4)
        # 1-2, 2-3, 3-4
        # Optimal decomposition: split 2-3 edge -> {1,2} vs {3,4}.
        # Cut rank ({1,2}, {3,4}) -> edges (2,3) -> rank 1.
        G_p4 = [0 1 0 0; 1 0 1 0; 0 1 0 1; 0 0 1 0]
        rd_p4 = rank_width(G_p4)
        @test rd_p4.width == 1 # Should be easy for heuristic on small graph
    end
end
