using Test
using LinearAlgebra

if !isdefined(Main, :RankWidthAlgorithms)
    include("../src/RankWidthAlgorithms.jl")
    using .RankWidthAlgorithms
end

# Alias for convenience
const LocalSearch = RankWidthAlgorithms.LocalSearch

@testset "Local Search Refinement" begin
    # P4 Graph: 1-2-3-4
    adj = [
        0 1 0 0;
        1 0 1 0;
        0 1 0 1;
        0 0 1 0
    ]
    
    # Construct a "Bad" Tree manually
    # Root splits {1,3} vs {2,4}
    # {1,3} has rank 2 (edges 1-2, 3-2, 3-4) -> actually {1,3} vs {2,4}:
    # Edges crossing cut: (1,2), (3,2), (3,4).
    # Submatrix rows {1,3}, cols {2,4}:
    #   2 4
    # 1 1 0
    # 3 1 1
    # Rank is 2.
    
    # Optimal split is {1,2} vs {3,4}.
    # Submatrix rows {1,2}, cols {3,4}:
    #   3 4
    # 1 0 0
    # 2 1 0
    # Rank is 1.
    
    # Left: {1,3} -> Node(1, 3)
    # Right: {2,4} -> Node(2, 4)
    
    bad_tree = SubCubicTree(0, 
        SubCubicTree(1, 1, 3),
        SubCubicTree(2, 2, 4)
    )
    
    # Verify bad width
    bad_rd = RankDecomposition(adj, bad_tree, 2)
    # My LocalSearch calculates width internally, but let's check manually if we can.
    # The refine_decomposition returns a RankDecomposition with the NEW width.
    
    refined_rd = LocalSearch.refine_decomposition(adj, bad_tree)
    
    println("Original Width: 2")
    println("Refined Width: $(refined_rd.width)")
    
    @test refined_rd.width < 2
    @test refined_rd.width == 1
end
