using TreeContractor
using TreeContractor.OMEinsum
using Yao, Graphs
using OMEinsum

function ising_complete(nq, nl; theta=0.0, error_rate=0.0)
    circuit = chain(nq)
	graph = complete_graph(nq)
    for _ in 1:nl
        append!(circuit, [put(nq, (e.src, e.dst) => rot(kron(Z, X), π/2)) for e in edges(graph)])
        append!(circuit, [put(nq, qind => Rx(theta)) for qind in 1:nq])
        # append!(circuit, [put(nq, qind => quantum_channel(DepolarizingError(1, error_rate))) for qind in 1:nq])
    end
    return circuit
end

c = ising_complete(5,20; theta=0.1, error_rate=0.0);
network = yao2einsum(c; initial_state=Dict(zip(1:nqubits(c), zeros(Int,nqubits(c)))), final_state=Dict(zip(1:nqubits(c), zeros(Int,nqubits(c)))))

code_treesa = optimize_code(network.code, uniformsize(network.code,2), TreeSA())

contraction_complexity(code_treesa,uniformsize(network.code,2))

@time code_treesa(network.tensors...)
code_pathsa = optimize_code(OMEinsum.flatten(network.code), uniformsize(network.code,2), OMEinsum.PathSA())

contraction_complexity(code_pathsa,uniformsize(network.code,2))

@time contract_with_mps_contractor(code_pathsa, network.tensors, uniformsize(network.code,2); maxdim = 5)

