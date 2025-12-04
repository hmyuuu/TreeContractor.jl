module TreeContractor

using OMEinsum
using LinearAlgebra


export contract_with_mps
export LabeledMPS, LabeledMPO
export LocalCompress, FullCompress, CompressAlgorithm
export apply!, compress!, apply_tensor!, apply_tensors!
export nsite, nflavor, maxlinkdim
export random_mps, random_mpo

# CompressAlgorithm needs to be defined before mps.jl uses it
abstract type CompressAlgorithm end

"""
    LocalCompress <: CompressAlgorithm

LocalCompress algorithm for compressing an LabeledMPS. It performs local SVDs and updates the LabeledMPS tensors serially, so the precision is not guaranteed.

In the scenario of applying MPO to LabeledMPS, it is also called Zipup algorithm, which compresses the network of LabeledMPS with MPO into a single LabeledMPS.

# References
- https://tensornetwork.org/mps/algorithms/zip_up_mpo/
"""
struct LocalCompress <: CompressAlgorithm end

"""
    FullCompress <: CompressAlgorithm

FullCompress algorithm for compressing an LabeledMPS. It takes environment tensors into account and performs global SVDs, so the precision is guaranteed.

In the scenario of applying MPO to LabeledMPS, it is also called Density Matrix algorithm, which compresses the network of LabeledMPS with MPO into a single LabeledMPS.

# References
- https://tensornetwork.org/mps/index.html#compression
- https://tensornetwork.org/mps/algorithms/denmat_mpo_mps/
"""
struct FullCompress <: CompressAlgorithm end

include("mps.jl")
include("compress.jl")
end
