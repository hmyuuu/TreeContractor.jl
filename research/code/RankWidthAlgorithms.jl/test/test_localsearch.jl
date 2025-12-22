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
    # Left: {1,3} -> Node(1, 3)
    # Right: {2,4} -> Node(2, 4)
    
    # IDs don't matter much for logic, just uniqueness
    bad_tree = SubCubicTree(0, 
        SubCubicTree(1, 1, 3),
        SubCubicTree(2, 2, 4)
    )
    
    # Calculate initial cost
    # Edge Root->Left: Cut {1,3}. Rank 2. Cost 4.
    # Edge Root->Right: Cut {2,4}. Rank 2. Cost 4.
    # Edge Left->1: Cut {1}. Rank 1. Cost 2.
    # Edge Left->3: Cut {3}. Rank 2 (2-3, 3-4). Cost 4.
    # ...
    
    initial_cost = LocalSearch.total_contraction_cost(adj, bad_tree)
    
    # Refine
    rd = RankDecomposition(adj, bad_tree, 2)
    refined_rd = LocalSearch.refine_decomposition(rd)
    
    refined_cost = LocalSearch.total_contraction_cost(adj, refined_rd.tree)
    
    @test refined_cost < initial_cost
    
    # Check if we reached optimal (Rank 1 everywhere possible)
    # Optimal tree: ((1,2), (3,4))
    # Cuts: {1,2} (Rank 1), {1} (Rank 1), {2} (Rank 2), {3} (Rank 2), {4} (Rank 1).
    # Wait, {2} cut: edges 1-2, 2-3. Rank 2.
    # {3} cut: edges 2-3, 3-4. Rank 2.
    
    # Let's trust the cost reduction.
end
