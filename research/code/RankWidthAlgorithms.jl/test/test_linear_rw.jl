using Test
using LinearAlgebra

if !isdefined(Main, :RankWidthAlgorithms)
    include("../src/RankWidthAlgorithms.jl")
    using .RankWidthAlgorithms
end

@testset "Linear Rank-Width Tests" begin
    # Debug: Check exports
    println("RankWidthAlgorithms exports: ", names(RankWidthAlgorithms))

    @testset "Path Graph (Linear RW = 1)" begin
        # P4: 1-2-3-4
        adj = zeros(Int, 4, 4)
        adj[1,2] = adj[2,1] = 1
        adj[2,3] = adj[3,2] = 1
        adj[3,4] = adj[4,3] = 1
        
        # Qualify function call
        decomp = RankWidthAlgorithms.solve_linear_rank_width(adj)
        @test decomp.width == 1
        println("P4 Linear Ordering: $(decomp.ordering)")
    end

    @testset "Cycle Graph C5 (Linear RW = 2)" begin
        # C5: 1-2-3-4-5-1
        n = 5
        adj = zeros(Int, n, n)
        for i in 1:n-1
            adj[i,i+1] = adj[i+1,i] = 1
        end
        adj[n,1] = adj[1,n] = 1
        
        decomp = RankWidthAlgorithms.solve_linear_rank_width(adj)
        @test decomp.width <= 2
        # C5 has RW 2. Linear RW is at least RW, so >= 2.
        @test decomp.width == 2
    end
    
    @testset "Star Graph K1,3 (Linear RW = 1)" begin
        # 1 is center, 2,3,4 leaves
        adj = zeros(Int, 4, 4)
        for i in 2:4
            adj[1,i] = adj[i,1] = 1
        end
        
        decomp = RankWidthAlgorithms.solve_linear_rank_width(adj)
        @test decomp.width == 1
    end
    
    @testset "Clique K5 (Linear RW = 1)" begin
        n = 5
        adj = ones(Int, n, n) - I
        
        decomp = RankWidthAlgorithms.solve_linear_rank_width(adj)
        @test decomp.width == 1
    end

end
