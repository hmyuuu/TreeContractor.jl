using Test
using LinearAlgebra

if !isdefined(Main, :RankWidthAlgorithms)
    include("../src/RankWidthAlgorithms.jl")
    using .RankWidthAlgorithms
end

const ParseTrees = RankWidthAlgorithms.ParseTrees

@testset "Parse Tree Construction" begin
    # P4 Graph: 1-2-3-4
    adj = [
        0 1 0 0;
        1 0 1 0;
        0 1 0 1;
        0 0 1 0
    ]
    
    # Use built-in rank_width to get a decomposition (should be optimal width 1)
    rd = rank_width(adj; refine=true)
    
    @test rd.width == 1
    
    # Build Parse Tree
    pt = ParseTrees.build_parse_tree(rd)
    
    # Verify properties
    # Root should cover all vertices [1,2,3,4] (leaves of subtree)
    # Root cut rank should be 0 (V vs Empty)
    @test pt.cut_rank == 0
    @test isempty(pt.basis_indices)
    
    # Helper to traverse and check
    function check_node(node)
        if node.is_leaf
            @test node.label in 1:4
            @test node.left === nothing
            @test node.right === nothing
            # Rank of leaf cut (leaf vs rest)
            # For 1: adj(1)={2}. Rank 1. Basis {1}.
            # For 2: adj(2)={1,3}. Rank 2? No, rank of row 2 in matrix G.
            # Row 2 is [1 0 1 0]. Rest is {1,3,4}. G[{2}, {1,3,4}] = [1 1 0]. Not zero.
            # Rank is 1.
            @test node.cut_rank >= 1 # Unless isolated vertex
            @test length(node.basis_indices) == node.cut_rank
        else
            @test node.left !== nothing
            @test node.right !== nothing
            
            # Check cut rank consistency
            # Rank of this cut must be <= width (1)
            # Root is 0, others <= 1.
            # Wait, if width is 1, all internal cuts must be <= 1.
            if node.cut_rank > 0
                @test node.cut_rank <= rd.width
            end
            
            check_node(node.left)
            check_node(node.right)
        end
    end
    
    check_node(pt)
    println("Parse Tree Verified for P4.")
end
