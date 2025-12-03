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

###### ContractorMPO and ContractorMPS Types for MPO Application ######

"""
    ContractorMPO{T, AT}

Matrix Product Operator type for tensor network contraction. Each tensor in `data` is rank-4 with indices:
[left_bond, physical_in, physical_out, right_bond]
"""
mutable struct ContractorMPO{T<:Number, AT<:AbstractArray{T,4}}
    data::Vector{AT}
    function ContractorMPO(data::Vector{AT}) where {T<:Number, AT<:AbstractArray{T,4}}
        @assert !isempty(data) "ContractorMPO must have at least one tensor"
        @assert size(data[1], 1) == 1 "Left virtual bond must have dimension 1"
        @assert size(data[end], 4) == 1 "Right virtual bond must have dimension 1"
        new{T, AT}(data)
    end
end

"""
    ContractorMPS{T, AT}

Matrix Product State type for MPO application. Each tensor in `data` is rank-3 with indices:
[left_bond, physical, right_bond]
"""
mutable struct ContractorMPS{T<:Number, AT<:AbstractArray{T,3}}
    data::Vector{AT}
    center::Int
    function ContractorMPS(data::Vector{AT}) where {T<:Number, AT<:AbstractArray{T,3}}
        @assert !isempty(data) "ContractorMPS must have at least one tensor"
        @assert size(data[1], 1) == 1 "Left virtual bond must have dimension 1"
        @assert size(data[end], 3) == 1 "Right virtual bond must have dimension 1"
        new{T, AT}(data, -1)
    end
end

# Helper functions for ContractorMPO
nsite(mpo::ContractorMPO) = length(mpo.data)
nflavor(mpo::ContractorMPO) = size(mpo.data[1], 2)  # physical dimension (input)
maxlinkdim(mpo::ContractorMPO) = maximum([size(t, 1) for t in mpo.data] ∪ [size(t, 4) for t in mpo.data])

# Helper functions for ContractorMPS
nsite(mps::ContractorMPS) = length(mps.data)
nflavor(mps::ContractorMPS) = size(mps.data[1], 2)  # physical dimension
maxlinkdim(mps::ContractorMPS) = maximum([size(t, 1) for t in mps.data] ∪ [size(t, 3) for t in mps.data])

function Base.copy(mps::ContractorMPS{T, AT}) where {T, AT}
    mps_copy = ContractorMPS([copy(t) for t in mps.data])
    mps_copy.center = mps.center
    return mps_copy
end

function code2mps(T, code::DynamicNestedEinsum{LT}, size_dict::Dict{LT, Int}) where LT
    # labels = Vector{LT}()
    labels = copy(code.eins.iy)
    apply_vec = Vector{Int}()
    tensor_labels = Vector{Vector{LT}}()
    vanish_labels_vec = Vector{Vector{LT}}()
    _code2mps!(code, labels, apply_vec, tensor_labels, vanish_labels_vec)
    tensors = [ones(T,1,size_dict[l],1) for l in labels]
    @assert length(tensors) == length(labels) "tensors and labels must have the same length"
    return LabeledMPS(tensors, labels), apply_vec, tensor_labels, vanish_labels_vec
end

"""
    code2contractor_mps(T, code::DynamicNestedEinsum{LT}, size_dict::Dict{LT, Int}) where LT

Convert a contraction code to ContractorMPS representation directly.

Returns:
- `ContractorMPS`: Initial MPS structure
- `labels::Vector{LT}`: Labels for each site
- `label_to_index::Dict{LT, Int}`: Mapping from labels to site indices
- `apply_vec::Vector{Int}`: Order in which tensors should be applied
- `tensor_labels::Vector{Vector{LT}}`: Labels for each tensor to be applied
- `vanish_labels_vec::Vector{Vector{LT}}`: Labels that vanish at each application
"""
function code2contractor_mps(T, code::DynamicNestedEinsum{LT}, size_dict::Dict{LT, Int}) where LT
    labels = copy(code.eins.iy)
    apply_vec = Vector{Int}()
    tensor_labels = Vector{Vector{LT}}()
    vanish_labels_vec = Vector{Vector{LT}}()
    _code2mps!(code, labels, apply_vec, tensor_labels, vanish_labels_vec)
    tensors = [ones(T,1,size_dict[l],1) for l in labels]
    @assert length(tensors) == length(labels) "tensors and labels must have the same length"
    contractor_mps = ContractorMPS(tensors)
    label_to_index = Dict(zip(labels, 1:length(labels)))
    return contractor_mps, labels, label_to_index, apply_vec, tensor_labels, vanish_labels_vec
end

"""
    _code2mps!(code, labels, apply_vec, tensor_labels, vanish_labels_vec)

Recursively process contraction code to generate MPS structure and application order.

This function preserves the ordering from the contraction tree, which is important for:
- PathSA() optimization: Preserves path-like linear ordering for pathwidth compatibility
- TreeSA() optimization: Preserves tree decomposition structure for treewidth compatibility

The vanishing labels are added in the order they appear in the contraction, maintaining
the sequential structure for pathwidth-optimal networks.
"""
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

    # Add vanishing labels in the order they appear - this preserves pathwidth ordering
    # for PathSA()-optimized codes where the structure is already linear/sequential
    for label in vanish_labels
        push!(labels, label)
    end
    @assert OMEinsum.isleaf(code.args[2]) "code.args[2] is not a leaf"
    push!(apply_vec, code.args[2].tensorindex)
    push!(tensor_labels, code.eins.ixs[2])
    push!(vanish_labels_vec, vanish_labels)
    return nothing
end

function apply_tensors!(mps::LabeledMPS, apply_vec::Vector{Int}, tensors::Vector{<:AbstractArray{T}}, tensor_labels::Vector{Vector{LT}}, vanish_labels_vec::Vector{Vector{LT}}; maxdim=Inf) where {T<:Number, LT}
    for (i, label, vanish_labels) in zip(apply_vec, tensor_labels, vanish_labels_vec)
        mps = apply_tensor!(mps, tensors[i], label, vanish_labels)
        if maximum(size.(mps.tensors, 1)) > maxdim
            compress!(FullCompress(), mps; maxdim)
        end
    end
    return mps
end

function apply_tensor!(mps::LabeledMPS, tensor::AbstractArray{T}, tensor_label::Vector{LT}, vanish_labels::Vector{LT}) where {T<:Number, LT}
    @assert length(tensor_label) == length(size(tensor)) "tensor_label and the dimension of tensor are not compatible"
    for (i, l) in enumerate(tensor_label)
        @assert size(mps.tensors[mps.label_to_index[l]], 2) == size(tensor, i) "tensor_label and the dimension of tensor are not compatible at index $i"
    end
    
    sorted_tensor_label = sort(1:length(tensor_label); by=x -> mps.label_to_index[tensor_label[x]])
    mps_vec, bd_vec = tensor2mps(permutedims(tensor, sorted_tensor_label))
   
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
            mps.tensors[i] = apply_rank_3_tensor(mps.tensors[i], delta_mps(bd_vec[pos], size(mps.tensors[i], 2), T))
        end

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
    apply_rank_3_tensor(tensor::AbstractArray{T,3}, merge_tensor::AbstractArray{T,3}) where T

Apply a rank-3 tensor to an existing rank-3 tensor, merging them.
          o-g-        
   d| e/ f|     =>   d|     f| g/
 -a-o--b--o-c-     -a-o--be--o-c-
"""
function apply_rank_3_tensor(tensor::AbstractArray{T,3}, merge_tensor::AbstractArray{T,3}) where T
    merge_code = ein"bfc,efg->befcg"
    m = merge_code(tensor, merge_tensor)
    return reshape(m, size(m,1)*size(m,2), size(m,3), size(m,4)*size(m,5))
end

"""
    apply_rank_3_tensor_with_vanish(tensor::AbstractArray{T,3}, merge_tensor::AbstractArray{T,3}) where T

Apply a rank-3 tensor to an existing rank-3 tensor with vanishing label.
          o-g-        
   d| e/ f|     =>   d|       g/
 -a-o--b--o-c-     -a-o--be--o-c-
"""
function apply_rank_3_tensor_with_vanish(tensor::AbstractArray{T,3}, merge_tensor::AbstractArray{T,3}) where T
    merge_code = ein"bfc,efg->becg"
    m = merge_code(tensor, merge_tensor)
    return reshape(m, size(m,1)*size(m,2), size(m,3)*size(m,4),1)
end

"""
    apply_tensor_with_compress!(mps::ContractorMPS, tensor::AbstractArray, tensor_label::Vector{LT}, vanish_labels::Vector{LT}, labels::Vector{LT}, label_to_index::Dict{LT, Int}; maxdim, compress_mode, atol) where {T<:Number, LT}

Apply a tensor to ContractorMPS and compress if needed.
Simplified approach: apply tensor → handle vanishing labels → compress once.

Uses LocalCompress for intermediate compression (faster) and compress_mode for final compression.

All arguments are modified in place. No return values needed.

# Arguments
- `mps::ContractorMPS`: The ContractorMPS to apply the tensor to (modified in place)
- `tensor::AbstractArray`: The tensor to apply
- `tensor_label::Vector{LT}`: Labels corresponding to tensor dimensions
- `vanish_labels::Vector{LT}`: Labels that will be contracted away
- `labels::Vector{LT}`: Current labels for each site in the MPS (modified in place)
- `label_to_index::Dict{LT, Int}`: Mapping from labels to site indices (modified in place)

# Keyword Arguments
- `maxdim`: Maximum bond dimension for compression
- `compress_mode`: Compression algorithm for final compression (LocalCompress or FullCompress)
                  Intermediate compressions always use LocalCompress for speed
- `atol`: Truncation tolerance

# Returns
- Nothing (all modifications are in place)
"""
function apply_tensor_with_compress!(mps::ContractorMPS, tensor::AbstractArray{T}, tensor_label::Vector{LT}, vanish_labels::Vector{LT}, labels::Vector{LT}, label_to_index::Dict{LT, Int}; maxdim=Inf, compress_mode=FullCompress(), atol=1e-12) where {T<:Number, LT}
    @assert length(tensor_label) == length(size(tensor)) "tensor_label and the dimension of tensor are not compatible"
    for (i, l) in enumerate(tensor_label)
        @assert size(mps.data[label_to_index[l]], 2) == size(tensor, i) "tensor_label and the dimension of tensor are not compatible at index $i"
    end
    
    sorted_tensor_label = sort(1:length(tensor_label); by=x -> label_to_index[tensor_label[x]])
    mps_vec, bd_vec = tensor2mps(permutedims(tensor, sorted_tensor_label))
   
    nsite_mps = nsite(mps)
    pos = 1
    vanish_pos = Int[]
    start_idx = label_to_index[tensor_label[sorted_tensor_label[1]]]
    end_idx = label_to_index[tensor_label[sorted_tensor_label[end]]]
    
    # Apply the entire tensor across all affected sites
    for i in start_idx:end_idx
        if labels[i] == tensor_label[sorted_tensor_label[pos]]
            merge_tensor = mps_vec[pos]
            pos += 1
            if labels[i] ∉ vanish_labels
                mps.data[i] = apply_rank_3_tensor(mps.data[i], merge_tensor)
            else
                push!(vanish_pos, i)
                mps.data[i] = apply_rank_3_tensor_with_vanish(mps.data[i], merge_tensor)
            end
        else
            mps.data[i] = apply_rank_3_tensor(mps.data[i], delta_mps(bd_vec[pos], size(mps.data[i], 2), T))
        end
    end
    
    # Reset canonical center after tensor application (structure changed)
    mps.center = -1

    # Handle vanishing labels
    if !isempty(vanish_pos)
        for i in vanish_pos
            if i < nsite_mps
                mps.data[i+1] = ein"ab,bcd->acd"(mps.data[i][:,:,1], mps.data[i+1])
            else
                most_right_tensor = findfirst(x -> labels[x] ∉ vanish_labels, nsite_mps:-1:1)
                if isnothing(most_right_tensor)
                    # All sites vanish - create a minimal MPS with single tensor
                    mps.data = [mps.data[end]]
                    # Modify labels and label_to_index in place
                    last_label = labels[end]
                    empty!(labels)
                    push!(labels, last_label)
                    empty!(label_to_index)
                    label_to_index[last_label] = 1
                    mps.center = -1
                    return
                else
                    most_right_tensor = nsite_mps - most_right_tensor + 1
                    mps.data[most_right_tensor] = ein"abc,cd->abd"(mps.data[most_right_tensor], mps.data[i][:,:,1])
                end
            end
        end

        deleteat!(mps.data, vanish_pos)
        deleteat!(labels, vanish_pos)
        # Rebuild dict in place - clear and rebuild to update caller's reference
        empty!(label_to_index)
        for (idx, lbl) in enumerate(labels)
            label_to_index[lbl] = idx
        end
        mps.center = -1
    end
    
    # Compression pass - only when bond dimension exceeds threshold
    # Use LocalCompress for intermediate steps (faster, O(N χ² d²))
    # FullCompress will be used at the end for optimal accuracy
    if maxdim < Inf && nsite(mps) > 1
        current_maxlink = maxlinkdim(mps)
        if current_maxlink > maxdim 
            # Use fast LocalCompress for intermediate compression steps
            # This controls bond dimensions efficiently without the overhead of FullCompress
            compress!(LocalCompress(), mps; niters=1, atol=atol, maxdim=maxdim)
        end
    end
end



"""
    tensor2mps(tensor::AbstractArray{T}) where T

Convert a tensor to MPS representation using successive SVDs.
Returns the MPS tensors and bond dimensions.
"""
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


"""
    delta_mps(bd::Int, n::Int, T::Type{<:Number})

Create a delta tensor (identity) with bond dimension `bd` and physical dimension `n`.
"""
function delta_mps(bd::Int, n::Int, T::Type{<:Number})
    tn = zeros(T,bd,n,bd)
    for i in 1:n
        tn[:,i,:] = I(bd)
    end
    return tn
end

"""
    contract_mps(tensors::Vector{<:AbstractArray{T,3}}) where T

Contract a sequence of MPS tensors into a single tensor.
   d|      =>   
 -a-o-b-        -a-o-b-

         e|     =>   
 -a-o--b--o-c-      a-o-c-
"""
function contract_mps(tensors::Vector{<:AbstractArray{T,3}}) where T
    tensor = ein"adb->ab"(tensors[1])
    contract_code = ein"ab,bec->ac"
    for t in tensors[2:end]
        tensor = contract_code(tensor, t)
    end
    return tensor
end
contract_mps(mps::LabeledMPS) = contract_mps(mps.tensors)


function contract_with_mps(optcode::DynamicNestedEinsum{LT}, tensors::Vector{<:AbstractArray{T}}, size_dict::Dict{LT, Int};maxdim = Inf) where {T<:Number, LT}
    mps, apply_vec, tensor_labels, vanish_labels_vec = code2mps(T, optcode, size_dict)
    mps = apply_tensors!(mps, apply_vec, tensors, tensor_labels, vanish_labels_vec; maxdim)
    return mps.tensors
end


"""
    contract_with_mps_contractor(optcode::DynamicNestedEinsum{LT}, tensors::Vector{<:AbstractArray{T}}, size_dict::Dict{LT, Int}; maxdim=Inf, compress_mode=FullCompress(), atol=1e-12) where {T<:Number, LT}

Contract tensor network using ContractorMPS with direct compression.

This implementation works exclusively with ContractorMPS, eliminating redundant conversions and allocations.
It applies tensors sequentially and compresses directly using the specified compression algorithm.

# Arguments
- `optcode`: Optimized contraction code
- `tensors`: Vector of tensors to contract
- `size_dict`: Dictionary mapping labels to dimensions

# Keyword Arguments
- `maxdim`: Maximum bond dimension for compression
- `compress_mode`: Compression algorithm (`LocalCompress()` or `FullCompress()`)
- `atol`: Truncation tolerance

# Returns
- Result tensors (same format as original `contract_with_mps`)
"""
function contract_with_mps_contractor(optcode::DynamicNestedEinsum{LT}, tensors::Vector{<:AbstractArray{T}}, size_dict::Dict{LT, Int}; maxdim=Inf, compress_mode=FullCompress(), atol=1e-12) where {T<:Number, LT}
    # Get ContractorMPS directly without LabeledMPS conversion
    contractor_mps, labels, label_to_index, apply_vec, tensor_labels, vanish_labels_vec = code2contractor_mps(T, optcode, size_dict)
    
    # Apply tensors sequentially with threshold-based compression
    for (i, label, vanish_labels) in zip(apply_vec, tensor_labels, vanish_labels_vec)
        # Apply tensor and compress - modifies labels and label_to_index in place
        apply_tensor_with_compress!(
            contractor_mps, tensors[i], label, vanish_labels, labels, label_to_index;
            maxdim=maxdim, compress_mode=compress_mode, atol=atol
        )
    end
    
    # Final compression pass to ensure bond dimensions are within threshold
    # This ensures accuracy even if intermediate compressions were skipped due to threshold
    if maxdim < Inf && nsite(contractor_mps) > 1 && maxlinkdim(contractor_mps) > maxdim
        compress!(compress_mode, contractor_mps; atol=atol, maxdim=maxdim)
    end
    
    return contractor_mps.data
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
