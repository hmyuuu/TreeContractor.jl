module HardGraphs

using Graphs
using LinearAlgebra
using Random

"""
    generate_random_graph(n::Int, p::Float64=0.5)

Generates a random Erdos-Renyi graph G(n, p).
High rank-width with high probability.
"""
function generate_random_graph(n::Int, p::Float64=0.5)
    adj = rand(n, n) .< p
    # Make symmetric
    for i in 1:n
        for j in i+1:n
            if adj[i, j]
                adj[j, i] = true
            else
                adj[i, j] = false
                adj[j, i] = false
            end
        end
        adj[i, i] = false # No self-loops
    end
    return Matrix{Int}(adj)
end

"""
    generate_grid_graph(m::Int, n::Int)

Generates an m x n grid graph.
Rank-width is approx min(m, n).
"""
function generate_grid_graph(m::Int, n::Int)
    N = m * n
    adj = zeros(Int, N, N)
    
    node(r, c) = (r-1)*n + c
    
    for r in 1:m
        for c in 1:n
            u = node(r, c)
            # Right neighbor
            if c < n
                v = node(r, c+1)
                adj[u, v] = adj[v, u] = 1
            end
            # Down neighbor
            if r < m
                v = node(r+1, c)
                adj[u, v] = adj[v, u] = 1
            end
        end
    end
    return adj
end

"""
    generate_paley_graph(q::Int)

Generates a Paley graph of order q.
q must be a prime power such that q ≡ 1 (mod 4).
These are deterministic quasi-random graphs (expanders).
"""
function generate_paley_graph(q::Int)
    # Basic check for prime (not full prime power check for simplicity)
    # Assumes q is a prime for this implementation
    @assert q % 4 == 1 "q must be congruent to 1 mod 4"
    
    adj = zeros(Int, q, q)
    
    # Quadratic residues mod q
    residues = Set{Int}()
    for x in 1:q-1
        push!(residues, (x^2) % q)
    end
    
    for u in 0:q-1
        for v in 0:q-1
            if u == v
                continue
            end
            diff = mod(u - v, q)
            if diff in residues
                adj[u+1, v+1] = 1
            end
        end
    end
    return adj
end

end # module
