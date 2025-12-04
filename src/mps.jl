mutable struct LabeledMPS{T<:Number, AT<:AbstractArray{T,3}, LT}
    # rank-3 tensors: left virtual bond, physical bond, right virtual bond
    # left/right virtual bond set to be of dimension 1 at the most left/right
    tensors::Vector{AT}
    labels::Vector{LT}
    label_to_index::Dict{LT, Int}
    center::Int
    function LabeledMPS(tensors::Vector{AT},labels::Vector{LT}) where {T<:Number, AT<:AbstractArray{T,3}, LT}
        @assert length(tensors) == length(labels) "LabeledMPS must have the same number of tensors and labels"
        @assert size(tensors[1], 1) == 1 "Left virtual bond must have dimension 1"
        @assert size(tensors[end], 3) == 1 "Right virtual bond must have dimension 1"
        label_to_index = Dict{LT, Int}(zip(labels, 1:length(labels)))
        new{T, AT, LT}(tensors, labels, label_to_index, -1)
    end
end

nsite(mps::LabeledMPS) = length(mps.labels)
num_of_elements(mps::LabeledMPS) = sum(length, mps.tensors)
maxlinkdim(mps::LabeledMPS) = maximum(max(size(t, 1), size(t, 3)) for t in mps.tensors)

"""
    LabeledMPO{T<:Number, AT<:AbstractArray{T,4}, LT}

A Matrix Product Operator (MPO) with labeled physical indices.
Each tensor has shape: (left virtual, top physical/bra, bottom physical/ket, right virtual)
"""
struct LabeledMPO{T<:Number, AT<:AbstractArray{T,4}, LT}
    # rank-4 tensors: left virtual, top physical (bra), bottom physical (ket), right virtual
    # left/right virtual bond set to be of dimension 1 at the most left/right
    tensors::Vector{AT}
    labels::Vector{LT}
    label_to_index::Dict{LT, Int}
    function LabeledMPO(tensors::Vector{AT}, labels::Vector{LT}) where {T<:Number, AT<:AbstractArray{T,4}, LT}
        @assert length(tensors) == length(labels) "LabeledMPO must have the same number of tensors and labels"
        @assert size(tensors[1], 1) == 1 "Left virtual bond must have dimension 1"
        @assert size(tensors[end], 4) == 1 "Right virtual bond must have dimension 1"
        label_to_index = Dict{LT, Int}(zip(labels, 1:length(labels)))
        new{T, AT, LT}(tensors, labels, label_to_index)
    end
end

nsite(mpo::LabeledMPO) = length(mpo.labels)
num_of_elements(mpo::LabeledMPO) = sum(length, mpo.tensors)
maxlinkdim(mpo::LabeledMPO) = maximum(max(size(t, 1), size(t, 4)) for t in mpo.tensors)

"""
    nflavor(mps::LabeledMPS)

Return the physical dimension of the MPS (assuming uniform physical dimension).
"""
nflavor(mps::LabeledMPS) = size(mps.tensors[1], 2)

"""
    nflavor(mpo::LabeledMPO)

Return the physical dimension of the MPO (assuming uniform physical dimension).
Returns the ket (bottom) physical dimension.
"""
nflavor(mpo::LabeledMPO) = size(mpo.tensors[1], 3)

"""
    random_mpo(::Type{T}, N::Int; maxdim::Int, d::Int=2, amplitude::Real=1.0) where T

Create a random MPO with `N` sites, physical dimension `d`, and maximum bond dimension `maxdim`.
"""
function random_mpo(::Type{T}, N::Int; maxdim::Int, d::Int=2, amplitude::Real=1.0) where T
    @assert N > 0 "Number of sites must be positive, got: $N"
    @assert maxdim > 0 "Maximum bond dimension must be positive, got: $maxdim"
    @assert d > 0 "Physical dimension must be greater than 0, got: $d"
    # Bond dimension grows as d^2 for MPO
    return LabeledMPO([T(amplitude) .* randn(T, min((d^2)^(i-1), (d^2)^(N-i+1), maxdim), d, d, min((d^2)^i, (d^2)^(N-i), maxdim)) for i in 1:N], [i for i in 1:N])
end

Base.copy(mps::LabeledMPS) = LabeledMPS(copy.(mps.tensors), copy(mps.labels))
Base.copy(mpo::LabeledMPO) = LabeledMPO(copy.(mpo.tensors), copy(mpo.labels))

function code2mps(code::DynamicNestedEinsum{LT}, size_dict::Dict{LT, Int}) where LT
    # labels = Vector{LT}()
    labels = copy(code.eins.iy)
    apply_vec = Vector{Int}()
    tensor_labels = Vector{Vector{LT}}()
    vanish_labels_vec = Vector{Vector{LT}}()
    _code2mps!(code, labels, apply_vec,tensor_labels, vanish_labels_vec)
    tensors = [ones(Float64,1,size_dict[l],1) for l in labels]
    @assert length(tensors) == length(labels) "tensors and labels must have the same length"
    return LabeledMPS(tensors, labels), apply_vec, tensor_labels, vanish_labels_vec
end

function _code2mps!(code::DynamicNestedEinsum{LT}, labels::Vector{LT}, apply_vec::Vector{Int}, tensor_labels::Vector{Vector{LT}}, vanish_labels_vec::Vector{Vector{LT}}) where LT
    @assert !OMEinsum.isleaf(code) "code is a empty code"
    input_inds = reduce(∪,code.eins.ixs)
    out_inds = code.eins.iy
    vanish_labels = setdiff(input_inds, out_inds)

    if !OMEinsum.isleaf(code.args[1])
        _code2mps!(code.args[1], labels, apply_vec, tensor_labels, vanish_labels_vec)
    else
        push!(apply_vec, code.args[1].tensorindex)
        push!(tensor_labels, code.eins.ixs[1])
        push!(vanish_labels_vec, setdiff(setdiff(code.eins.ixs[1], out_inds),code.eins.ixs[2]))
    end

    for label in vanish_labels
        push!(labels, label)
    end
    @assert OMEinsum.isleaf(code.args[2]) "code.args[2] is not a leaf"
    push!(apply_vec, code.args[2].tensorindex)
    push!(tensor_labels, code.eins.ixs[2])
    push!(vanish_labels_vec, vanish_labels)
    return nothing
end

"""
    apply_tensors!(mps::LabeledMPS, apply_vec, tensors, tensor_labels, vanish_labels_vec; maxdim=Inf)

Apply tensors to MPS with post-hoc compression when bond dimension exceeds `maxdim`.
This is the original implementation that applies then compresses.
"""
function apply_tensors!(mps::LabeledMPS, apply_vec::Vector{Int}, tensors::Vector{<:AbstractArray{T}}, tensor_labels::Vector{Vector{LT}}, vanish_labels_vec::Vector{Vector{LT}}; maxdim = Inf) where {T<:Number, LT}
    for (i,label, vanish_labels) in zip(apply_vec, tensor_labels, vanish_labels_vec)
        mps = apply_tensor!(mps, tensors[i], label, vanish_labels)
        # @info  mps.tensors .|> size
        if maximum(size.(mps.tensors,1)) > maxdim
            compress!(FullCompress(), mps; maxdim)
            # @info "compress"
            # @info  mps.tensors .|> size
        end
    end
    return mps
end

"""
    apply_tensors!(mode::CompressAlgorithm, mps::LabeledMPS, apply_vec, tensors, tensor_labels, vanish_labels_vec; atol=1e-12, maxdim=Inf)

Apply tensors to MPS with integrated compression using the specified algorithm.
The `mode` can be either `LocalCompress()` (zip-up) or `FullCompress()` (density matrix).

# Arguments
- `mode`: the compression algorithm to use during tensor application
- `mps`: the MPS to apply tensors to
- `apply_vec`: vector of tensor indices to apply
- `tensors`: vector of tensors to apply
- `tensor_labels`: labels for each tensor's indices
- `vanish_labels_vec`: labels to contract (vanish) for each tensor

# Keyword arguments
- `atol`: truncation tolerance for SVD/eigendecomposition
- `maxdim`: maximum bond dimension
"""
function apply_tensors!(mode::CompressAlgorithm, mps::LabeledMPS, apply_vec::Vector{Int}, tensors::Vector{<:AbstractArray{T}}, tensor_labels::Vector{Vector{LT}}, vanish_labels_vec::Vector{Vector{LT}}; atol::Real=1e-12, maxdim::Int=typemax(Int)) where {T<:Number, LT}
    for (i,label, vanish_labels) in zip(apply_vec, tensor_labels, vanish_labels_vec)
        mps = apply_tensor!(mode, mps, tensors[i], label, vanish_labels; atol, maxdim)
    end
    return mps
end

"""
    apply_tensor!(mps::LabeledMPS, tensor, tensor_label, vanish_labels)

Apply a tensor to MPS at positions specified by `tensor_label`, contracting indices in `vanish_labels`.
This is the original implementation without integrated compression.
"""
function apply_tensor!(mps::LabeledMPS, tensor::AbstractArray{T}, tensor_label::Vector{LT}, vanish_labels::Vector{LT}) where {T<:Number, LT}
    @assert length(tensor_label) == length(size(tensor)) "tensor_label and the dimension of tensor are not compatible"
    for (i,l) in enumerate(tensor_label)
        @assert size(mps.tensors[mps.label_to_index[l]],2) == size(tensor,i) "tensor_label and the dimension of tensor are not compatible at index $i"
    end
    
    sorted_tensor_label = sort(1:length(tensor_label); by= x -> mps.label_to_index[tensor_label[x]])
    mps_vec, bd_vec = tensor2mps(permutedims(tensor,sorted_tensor_label))
   
    nsite_mps = nsite(mps)
    pos = 1
    vanish_pos = Int[]
    for i in mps.label_to_index[tensor_label[sorted_tensor_label[1]]]:mps.label_to_index[tensor_label[sorted_tensor_label[end]]]
        if mps.labels[i] == tensor_label[sorted_tensor_label[pos]]
            merge_tensor = mps_vec[pos]
            pos += 1
            if mps.labels[i] ∉ vanish_labels
                mps.tensors[i] = apply_rank_3_tensor(mps.tensors[i], merge_tensor)
            else
                push!(vanish_pos, i)
                mps.tensors[i] = apply_rank_3_tensor_with_vanish(mps.tensors[i], merge_tensor)
                
            end
        else
            mps.tensors[i] = apply_rank_3_tensor(mps.tensors[i], delta_mps(bd_vec[pos], size(mps.tensors[i],2), T))
        end

        # if i > 1
        #     @assert size(mps.tensors[i],1) == size(mps.tensors[i-1],3)
        # end
    end

    if !isempty(vanish_pos)
        for i in vanish_pos
            if i < nsite_mps
                mps.tensors[i+1] = ein"ab,bcd->acd"(mps.tensors[i][:,:,1], mps.tensors[i+1])
            else
                most_right_tensor = findfirst(x -> mps.labels[x] ∉ vanish_labels, nsite_mps:-1:1)
                if isnothing(most_right_tensor)
                    return LabeledMPS([mps.tensors[end]], [-1])
                else
                    most_right_tensor = nsite_mps - most_right_tensor + 1
                    mps.tensors[most_right_tensor] = ein"abc,cd->abd"(mps.tensors[most_right_tensor], mps.tensors[i][:,:,1])
                end
            end
        end

        deleteat!(mps.tensors, vanish_pos)
        deleteat!(mps.labels, vanish_pos)
        mps.label_to_index = Dict(zip(mps.labels, 1:length(mps.labels)))
        mps.center = -1
    end
    return mps
end

"""
    apply_tensor!(::LocalCompress, mps::LabeledMPS, tensor, tensor_label, vanish_labels; atol=1e-12, maxdim=typemax(Int))

Apply a tensor to MPS with zip-up (local) compression.
First applies the tensor, then performs local SVD sweeps for compression only when needed.

# Algorithm
This implements a two-stage approach:
1. Apply tensor to affected sites
2. Handle vanishing labels
3. Apply local SVD compression sweeps (zip-up style) only if bond dimensions exceed maxdim

# References
- https://tensornetwork.org/mps/algorithms/zip_up_mpo/
"""
function apply_tensor!(::LocalCompress, mps::LabeledMPS{T1}, tensor::AbstractArray{T2}, tensor_label::Vector{LT}, vanish_labels::Vector{LT}; atol::Real=1e-12, maxdim::Int=typemax(Int)) where {T1<:Number, T2<:Number, LT}
    # First apply the tensor without compression
    mps = apply_tensor!(mps, tensor, tensor_label, vanish_labels)

    # Then compress using local SVD sweeps (zip-up style) only if needed
    # Optimized: check max bond dimension efficiently
    if maxdim < typemax(Int)
        max_bond = maxlinkdim(mps)
        if max_bond > maxdim
            compress!(LocalCompress(), mps; niters=1, atol, maxdim)
        end
    end

    return mps
end

"""
    apply_tensor!(::FullCompress, mps::LabeledMPS, tensor, tensor_label, vanish_labels; atol=1e-12, maxdim=typemax(Int))

Apply a tensor to MPS with density matrix (full) compression.
First applies the tensor, then uses the density matrix method for optimal global compression only when needed.

# Algorithm
This implements a two-stage approach:
1. Apply tensor to affected sites
2. Handle vanishing labels
3. Apply global density matrix compression to the entire MPS only if bond dimensions exceed maxdim

# References
- https://tensornetwork.org/mps/algorithms/denmat_mpo_mps/
"""
function apply_tensor!(::FullCompress, mps::LabeledMPS{T1}, tensor::AbstractArray{T2}, tensor_label::Vector{LT}, vanish_labels::Vector{LT}; atol::Real=1e-12, maxdim::Int=typemax(Int)) where {T1<:Number, T2<:Number, LT}
    # First apply the tensor without compression
    mps = apply_tensor!(mps, tensor, tensor_label, vanish_labels)

    # Then compress using the density matrix method on the full MPS only if needed
    # Optimized: check max bond dimension efficiently
    if maxdim < typemax(Int)
        max_bond = maxlinkdim(mps)
        if max_bond > maxdim
            compress!(FullCompress(), mps; atol, maxdim)
        end
    end

    return mps
end

#          o-g-
#   d| e/ f|     =>   d|     f| g/
# -a-o--b--o-c-     -a-o--be--o-c-
# Optimized version: pre-compiled einsum for better performance
const _apply_rank_3_einsum = ein"bfc,efg->befcg"
function apply_rank_3_tensor(tensor::AbstractArray{T,3}, merge_tensor::AbstractArray{T,3}) where T
    m = _apply_rank_3_einsum(tensor, merge_tensor)
    return reshape(m, size(m,1)*size(m,2), size(m,3), size(m,4)*size(m,5))
end

#          o-g-
#   d| e/ f|     =>   d|       g/
# -a-o--b--o-c-     -a-o--be--o-c-
# Optimized version: pre-compiled einsum for better performance
const _apply_rank_3_vanish_einsum = ein"bfc,efg->becg"
function apply_rank_3_tensor_with_vanish(tensor::AbstractArray{T,3}, merge_tensor::AbstractArray{T,3}) where T
    m = _apply_rank_3_vanish_einsum(tensor, merge_tensor)
    return reshape(m, size(m,1)*size(m,2), size(m,3)*size(m,4),1)
end

function tensor2mps(tensor::AbstractArray{T}) where T
    tensor_size = tensor |> size
    mps_vec = Vector{Array{T,3}}()
    bd_vec = Vector{Int}(undef, length(tensor_size)+1)
    bd_vec[1] = 1
    for (i,s) in enumerate(tensor_size[1:end-1])
        mat = reshape(tensor, s*bd_vec[i], :)
        U,S,V = svd(mat)
        tensor = Diagonal(S)*V'
        bd_vec[i+1] = size(U,2)
        push!(mps_vec, reshape(U, bd_vec[i], s, bd_vec[i+1]))
    end
    push!(mps_vec, reshape(tensor, bd_vec[end-1], tensor_size[end], 1))
    bd_vec[end] = 1
    return mps_vec, bd_vec
end


function delta_mps(bd::Int, n::Int,T::Type{<:Number})
    tn = zeros(T,bd,n,bd)
    for i in 1:n
        tn[:,i,:] = I(bd)
    end
    return tn
end

#   d|      =>   
# -a-o-b-        -a-o-b-


#         e|     =>   
# -a-o--b--o-c-      a-o-c-
function contract_mps(tensors::Vector{<:AbstractArray{T,3}}) where T
    tensor = ein"adb->ab"(tensors[1])
    contract_code = ein"ab,bec->ac"
    for t in tensors[2:end]
        tensor = contract_code(tensor, t)
    end
    return tensor
end
contract_mps(mps::LabeledMPS) = contract_mps(mps.tensors)


"""
    contract_with_mps(optcode, tensors, size_dict; maxdim=Inf)

Contract tensors following the optimized einsum code using MPS representation.
Uses post-hoc compression when bond dimension exceeds `maxdim`.
"""
function contract_with_mps(optcode::DynamicNestedEinsum{LT}, tensors::Vector{<:AbstractArray{T}}, size_dict::Dict{LT, Int};maxdim = Inf) where {T<:Number, LT}
    mps, apply_vec, tensor_labels, vanish_labels_vec = code2mps(optcode, size_dict)
    mps = apply_tensors!(mps, apply_vec, tensors, tensor_labels, vanish_labels_vec; maxdim)
    return mps.tensors
end

"""
    contract_with_mps(mode::CompressAlgorithm, optcode, tensors, size_dict; atol=1e-12, maxdim=typemax(Int))

Contract tensors following the optimized einsum code using MPS representation with integrated compression.

# Arguments
- `mode`: compression algorithm, either `LocalCompress()` (zip-up) or `FullCompress()` (density matrix)
- `optcode`: optimized einsum contraction code
- `tensors`: vector of tensors to contract
- `size_dict`: dictionary mapping index labels to dimensions

# Keyword arguments
- `atol`: truncation tolerance
- `maxdim`: maximum bond dimension
"""
function contract_with_mps(mode::CompressAlgorithm, optcode::DynamicNestedEinsum{LT}, tensors::Vector{<:AbstractArray{T}}, size_dict::Dict{LT, Int}; atol::Real=1e-12, maxdim::Int=typemax(Int)) where {T<:Number, LT}
    mps, apply_vec, tensor_labels, vanish_labels_vec = code2mps(optcode, size_dict)
    mps = apply_tensors!(mode, mps, apply_vec, tensors, tensor_labels, vanish_labels_vec; atol, maxdim)
    return mps.tensors
end

function random_mps(::Type{T}, N::Int; maxdim::Int, d::Int=2, amplitude::Real=1.0) where T
    @assert N > 0 "Number of sites must be positive, got: $N"
    @assert maxdim > 0 "Maximum bond dimension must be positive, got: $maxdim"
    @assert d > 0 "Physical dimension must be greater than 0, got: $d"
    return LabeledMPS([T(amplitude) .* randn(T, min(d^(i-1), d^(N-i+1), maxdim), d, min(d^i, d^(N-i), maxdim)) for i in 1:N], [i for i in 1:N])
end

function Base.vec(mps::LabeledMPS{T,AT,LT}) where {T,AT,LT<:Integer}
    @assert nsite(mps) <= 30 "MPS too large to be converted to a vector"

    max_label = maximum(mps.labels)
    ixs = Vector{Int}[]
    iy = Int[]
    max_label +=1
    previdx = max_label
    for k in 1:nsite(mps)
        physical = mps.labels[k]
        max_label +=1
        nextidx = max_label
        push!(ixs, [previdx, physical, nextidx])
        k == 1 && push!(iy, previdx)
        push!(iy, physical)
        k == nsite(mps) && push!(iy, nextidx)
        previdx = nextidx
    end
    size_dict = OMEinsum.get_size_dict(ixs, mps.tensors)
    code = optimize_code(
        DynamicEinCode(ixs, iy), size_dict, GreedyMethod()
    )

    return vec(code(mps.tensors...))
end