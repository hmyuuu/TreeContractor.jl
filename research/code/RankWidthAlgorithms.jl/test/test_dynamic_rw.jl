using Test
using LinearAlgebra

if !isdefined(Main, :RankWidthAlgorithms)
    include("../src/RankWidthAlgorithms.jl")
    using .RankWidthAlgorithms
end

@testset "Dynamic Rank-Width Tests" begin
    
    @testset "Incremental Construction (P4)" begin
        # Build P4: 1-2, 2-3, 3-4
        n = 4
        dg = DynamicGraph(n)
        
        # Initial width should be 0
        @test dg.decomposition.width == 0
        
        # Add 1-2
        w = add_edge!(dg, 1, 2)
        @test w <= 1
        
        # Add 2-3
        w = add_edge!(dg, 2, 3)
        @test w <= 1
        
        # Add 3-4
        w = add_edge!(dg, 3, 4)
        @test w == 1 # P4 has width 1
        
        # Verify structure
        @test dg.adj[1,2] == 1
        @test dg.adj[3,4] == 1
    end
    
    @testset "Incremental Cycle (C5)" begin
        n = 5
        dg = DynamicGraph(n)
        
        # Add edges 1-2, 2-3, 3-4, 4-5
        add_edge!(dg, 1, 2)
        add_edge!(dg, 2, 3)
        add_edge!(dg, 3, 4)
        add_edge!(dg, 4, 5)
        
        # Should be width 1 (Path P5)
        @test dg.decomposition.width == 1
        
        # Close cycle 5-1
        w = add_edge!(dg, 5, 1)
        
        # C5 has width 2.
        # Local search should find this.
        @test w == 2
    end

end
