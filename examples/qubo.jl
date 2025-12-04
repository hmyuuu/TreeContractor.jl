using TreeContractor
using TreeContractor.OMEinsum
using ProblemReductions, Graphs

"""
    qubo_to_tensors(qubo::ProblemReductions.QUBO, β::Float64=1.0)

Convert a QUBO problem to tensor network representation.
For a QUBO: minimize ∑ᵢⱼ Qᵢⱼ xᵢ xⱼ

Returns tensors where:
- Linear terms (diagonal) → rank-1 tensors
- Quadratic terms (off-diagonal) → rank-2 tensors
"""
function qubo_to_tensors(qubo::ProblemReductions.QUBO, β::Float64=1.0)
    Q = qubo.matrix
    n = size(Q, 1)
    
    tensors = Vector{Array{Float64}}()
    einsum_labels = Vector{Vector{Int}}()
    
    # Linear terms (rank-1 tensors)
    for i in 1:n
        push!(tensors, [1.0, exp(-β * Q[i, i])])
        push!(einsum_labels, [i])
    end
    
    # Quadratic terms (rank-2 tensors, upper triangle only)
    for i in 1:n, j in (i+1):n
        if Q[i, j] != 0.0
            quad_tensor = [exp(-β * Q[i, j] * xi * xj) for xi in 0:1, xj in 0:1]
            push!(tensors, quad_tensor)
            push!(einsum_labels, [i, j])
        end
    end
    
    return tensors, einsum_labels, collect(1:n)
end

# ============================================================
# Example: Fully Connected QUBO Problem
# ============================================================
println("=" ^ 65)
println("  Fully Connected QUBO Problem with MPS Tensor Contraction")
println("=" ^ 65)

n = 30
graph = complete_graph(n)
h = ones(n)
Q = ones(n * (n - 1) ÷ 2)
qubo_problem = ProblemReductions.QUBO(graph, Q, h)

println("\nProblem Setup:")
println("  Variables: $n")
println("  Edges: $(ne(graph))")
println("  Total tensors: $(n + ne(graph))")

# Convert to tensor network
tensors, einsum_labels, _ = qubo_to_tensors(qubo_problem, 1.0)
ein_expr = EinCode(einsum_labels, Int[])
size_dict = OMEinsum.get_size_dict(einsum_labels, tensors)

# Optimize contraction order
optcode_tree = optimize_code(ein_expr, size_dict, OMEinsum.TreeSA())
optcode_path = optimize_code(ein_expr, size_dict, OMEinsum.PathSA())

println("\nContraction Complexity:")
println("  TreeSA: ", contraction_complexity(optcode_tree, size_dict))
println("  PathSA: ", contraction_complexity(optcode_path, size_dict))

# ============================================================
# Benchmark: Direct vs MPS Contraction
# ============================================================
println("\n" * "-" ^ 65)
println("  Benchmark: Direct vs MPS Contraction (maxdim=50)")
println("-" ^ 65)

# Direct contraction (exact)
print("\nDirect (TreeSA):        ")
Z_exact = @time optcode_tree(tensors...)[]

# MPS with lazy compression (default)
print("MPS (lazy, ratio=2.0):  ")
Z_lazy = @time contract_with_mps(optcode_path, tensors, size_dict; maxdim=20)[][]

# MPS with compress_every using contract_with_compress!
print("MPS (compress_every):   ")
Z_every = @time contract_with_mps(optcode_path, tensors, size_dict; maxdim=100, compress_every=true)[][]

print("MPS (single_sweep):     ")
Z_single_sweep = @time contract_with_mps(optcode_path, tensors, size_dict; maxdim=100, single_sweep=true)[][]
