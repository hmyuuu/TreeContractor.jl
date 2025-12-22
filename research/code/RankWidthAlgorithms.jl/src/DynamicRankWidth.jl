module DynamicRankWidth

using LinearAlgebra
using ..RankWidthAlgorithms: RankDecomposition, SubCubicTree, cut_rank, LocalSearch

export DynamicGraph, add_edge!, get_decomposition

"""
    DynamicGraph

A data structure that maintains a graph and its rank-decomposition
under edge updates.
"""
mutable struct DynamicGraph
    adj::Matrix{Int}
    n::Int
    decomposition::RankDecomposition
    
    # Internal cache for optimization (optional)
end

"""
    DynamicGraph(n::Int)

Initializes an empty dynamic graph with n vertices.
"""
function DynamicGraph(n::Int)
    adj = zeros(Int, n, n)
    # Initial decomposition: Arbitrary tree (e.g., caterpillar 1-2-3...)
    # For n=1, just a node.
    # For n>1, build a balanced tree or path.
    
    # Let's use the static heuristic to build an initial tree on the empty graph (width 0)
    # Or just build a simple path structure manually.
    
    # Heuristic: 1-2-3-... path structure
    # Actually, let's use the existing builder on the empty matrix
    # RankWidthAlgorithms is the parent module. We need to access it.
    # But this is a submodule. We imported RankDecomposition etc from ..RankWidthAlgorithms
    # But we didn't import rank_width.
    
    # We cannot access RankWidthAlgorithms.rank_width if it's not imported or passed.
    # Let's fix imports.
    
    # Actually, we should just build a trivial decomposition manually to avoid circular deps or complex imports.
    # Single node tree if n=1.
    
    if n == 1
        tree = SubCubicTree(1, nothing, nothing)
        decomp = RankDecomposition(adj, tree, 0)
    else
        # Build a caterpillar 1-2-3...
        # Root splits {1} vs {2..n}
        # Right child splits {2} vs {3..n} etc.
        
        function build_caterpillar(vertices, id_counter)
            if length(vertices) == 1
                return vertices[1]
            end
            
            left = vertices[1]
            right = build_caterpillar(vertices[2:end], id_counter)
            
            id_counter[] += 1
            return SubCubicTree(id_counter[], left, right)
        end
        
        id_counter = Ref(n+1) # IDs 1..n are leaves
        tree = build_caterpillar(collect(1:n), id_counter)
        decomp = RankDecomposition(adj, tree, 0)
    end
    
    return DynamicGraph(adj, n, decomp)
end

"""
    add_edge!(dg::DynamicGraph, u::Int, v::Int)

Adds an edge (u, v) to the graph and updates the rank-decomposition.
Attempts to maintain low width using Local Search.
"""
function add_edge!(dg::DynamicGraph, u::Int, v::Int)
    if u == v || u < 1 || u > dg.n || v < 1 || v > dg.n
        return
    end
    
    if dg.adj[u, v] == 1
        return # Already exists
    end
    
    dg.adj[u, v] = 1
    dg.adj[v, u] = 1
    
    # Update decomposition
    # Strategy:
    # 1. The existing tree topology is still valid as a "Parse Tree", 
    #    but the width might have increased.
    # 2. We verify the current width.
    # 3. If width is too high, we trigger refinement.
    
    # Ideally, we would use "Prefix Rebuilding" (Korhonen 2024),
    # but for this prototype, we re-run Local Search Refinement.
    # This is O(n^2) per update, which fits the Fomin 2021 model.
    
    # Note: We need to update the `G` in the RankDecomposition struct too?
    # RankDecomposition is immutable. We create a new one.
    
    current_tree = dg.decomposition.tree
    
    # Refine
    # Note: refine_decomposition calculates the width internally.
    new_decomp = LocalSearch.refine_decomposition(dg.adj, current_tree)
    
    dg.decomposition = new_decomp
    return new_decomp.width
end

"""
    get_decomposition(dg::DynamicGraph)

Returns the current RankDecomposition.
"""
function get_decomposition(dg::DynamicGraph)
    return dg.decomposition
end

end # module
