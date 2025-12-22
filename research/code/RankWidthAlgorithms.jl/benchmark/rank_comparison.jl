using LinearAlgebra
using Random
using Test
include("../src/RankWidthAlgorithms.jl")
using .RankWidthAlgorithms

# Helper to generate a random Graph State
function random_graph_state(n::Int, p::Float64=0.5)
    # Adjacency matrix over GF(2)
    G = Int.(rand(n, n) .< p)
    for i in 1:n; G[i,i] = 0; end
    return Symmetric(G)
end

# Helper to convert GF(2) adjacency to Quantum State Vector
# This is a naive exponential implementation for benchmarking verification
function graph_to_state_vector(G::AbstractMatrix)
    n = size(G, 1)
    dim = 2^n
    psi = zeros(ComplexF64, dim)
    
    # Iterate all basis states |x>
    for x_int in 0:(dim-1)
        x_bits = digits(x_int, base=2, pad=n)
        
        # Phase = (-1)^(sum_{i<j} G_ij x_i x_j)
        phase_exp = 0
        for i in 1:n
            for j in (i+1):n
                if G[i,j] == 1
                    phase_exp += x_bits[i] * x_bits[j]
                end
            end
        end
        
        # Apply Hadamard to |+>^n -> sum |x>
        # Graph state formula: \prod CZ |+>
        # Actually, let's just construct it directly:
        # |G> = \sum_x (-1)^{x^T G_{triu} x} |x>
        
        psi[x_int+1] = (-1)^phase_exp
    end
    return psi / sqrt(dim)
end

# Comparison Function
function benchmark_cut(n::Int, cut_size::Int)
    println("--- Benchmarking n=$n, cut=$cut_size ---")
    
    # 1. Generate Graph
    G = random_graph_state(n)
    A = collect(1:cut_size)
    B = collect((cut_size+1):n)
    
    # 2. Compute GF(2) Cut Rank (Rank-Width approach)
    rw_rank = cut_rank(G, A)
    println("GF(2) Cut Rank: $rw_rank (Bond Dim should be 2^$rw_rank = $(2^rw_rank))")
    
    # 3. Compute Schmidt Rank (SVD approach)
    # Reshape vector into matrix (dim(A) x dim(B))
    psi = graph_to_state_vector(G)
    psi_matrix = reshape(psi, (2^length(A), 2^length(B)))
    
    svd_res = svd(psi_matrix)
    schmidt_rank = count(x -> x > 1e-10, svd_res.S)
    println("Schmidt Rank: $schmidt_rank")
    
    # 4. Verification
    if schmidt_rank == 2^rw_rank
        println("✅ MATCH: Schmidt Rank == 2^(GF(2) Rank)")
    else
        println("❌ MISMATCH: Schmidt Rank ($schmidt_rank) != 2^($rw_rank)")
    end
    println("")
end

# Run Benchmarks
benchmark_cut(6, 3)
benchmark_cut(8, 4)
# benchmark_cut(12, 6) # Warning: 2^12 = 4096, matrix 64x64 is fine.
