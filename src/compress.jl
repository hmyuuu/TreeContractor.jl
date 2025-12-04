###### Canonicalization related APIs ######
is_canonicalized(mps::LabeledMPS) = mps.center !== -1
orthocenter(mps::LabeledMPS) = is_canonicalized(mps) ? mps.center : nothing

"""
    canonicalize!(mps::LabeledMPS, i::Int; atol::Real=1e-12, maxdim::Int=typemax(Int))

Canonicalize the LabeledMPS, with the canonical center at site `i`. If the LabeledMPS is already canonicalized, move the center to site `i`.

# Arguments
- `mps::LabeledMPS`: the LabeledMPS to canonicalize
- `i::Int`: the site index of the canonical center
- `atol::Real=1e-12`: the truncation error
- `maxdim::Int=typemax(Int)`: the maximum bond dimension for truncation
"""
function canonicalize!(mps::LabeledMPS{T}, i::Int; atol::RT=1e-12, maxdim::Int=typemax(Int)) where {RT,T<:Union{RT,Complex{RT}}}
    n = nsite(mps)
    @assert 1 <= i <= n "Center index i must be between 1 and $n"

    if is_canonicalized(mps)  # move center
        for center in mps.center+1:i     # right moving
            canonical_move_right!(mps, atol, maxdim)
        end
        for center in mps.center-1:-1:i  # left moving
            canonical_move_left!(mps, atol, maxdim)
        end
        return mps
    else   # initialize center
        mps.center = 1
        for center in 2:i  # right moving
            canonical_move_right!(mps, atol, maxdim)
        end

        mps.center = n
        for center in n-1:-1:i  # left moving
            canonical_move_left!(mps, atol, maxdim)
        end

        return mps
    end
end

function canonical_move_right!(mps::LabeledMPS, atol::Real, maxdim::Int)
    @assert is_canonicalized(mps) "LabeledMPS is not canonicalized. Use canonicalize! first."
    @assert mps.center < nsite(mps) "Cannot move right from the rightmost site."
    j = mps.center
    U, S, V, _ = truncated_svd(reshape(mps.tensors[j], :, size(mps.tensors[j])[3]), atol, maxdim)
    mps.tensors[j] = reshape(U, size(mps.tensors[j])[1:2]..., :)
    mps.tensors[j + 1] = ein"(i, ij), jak->iak"(S, V, mps.tensors[j + 1])
    mps.center += 1
    return mps
end

function canonical_move_left!(mps::LabeledMPS, atol::Real, maxdim::Int)
    @assert is_canonicalized(mps) "LabeledMPS is not canonicalized. Use canonicalize! first."
    @assert mps.center > 1 "Cannot move left from the leftmost site."
    j = mps.center
    U, S, V, _ = truncated_svd(reshape(mps.tensors[j], size(mps.tensors[j])[1], :), atol, maxdim)
    mps.tensors[j] = reshape(V, :, size(mps.tensors[j])[2:3]...)
    mps.tensors[j - 1] = ein"iaj, (jk, k)->iak"(mps.tensors[j - 1], U, S)
    mps.center -= 1
    return mps
end

# Check if LabeledMPS is in proper canonical form.
function check_canonical(mps::LabeledMPS; atol::Real=1e-10)
    !is_canonicalized(mps) && return true
    center = orthocenter(mps)
    return _check_canonical(mps.tensors, center; atol)
end
function _check_canonical(tensors::Vector{AT}, center::Int; atol::Real=1e-10) where {T,AT<:AbstractArray{T,3}}
    return all(i -> is_left_canonical(tensors[i]; atol), 1:(center - 1)) && all(i -> is_right_canonical(tensors[i]; atol), (center + 1):length(tensors))
end
function is_left_canonical(tensor::AbstractArray{T,3}; atol::Real=1e-10) where {T}
    return isapprox(ein"iaj, iak->jk"(conj(tensor), tensor), LinearAlgebra.I; atol)
end
function is_right_canonical(tensor::AbstractArray{T,3}; atol::Real=1e-10) where {T}
    return isapprox(ein"iaj, kaj->ik"(conj(tensor), tensor), LinearAlgebra.I; atol)
end

###### Linear Algebra APIs ######
LinearAlgebra.norm(mps::LabeledMPS) = sqrt(real(is_canonicalized(mps) ? ein"iaj, iaj->"(conj(mps.tensors[orthocenter(mps)]), mps.tensors[orthocenter(mps)])[] : dot(mps, mps)))
function LinearAlgebra.normalize!(mps::LabeledMPS)
    mps.tensors[is_canonicalized(mps) ? orthocenter(mps) : 1] ./= norm(mps)
    return mps
end

function LinearAlgebra.dot(A::LabeledMPS, B::LabeledMPS)
    res = foldl(2:nsite(A); init=ein"ai, aj->ij"(conj(A.tensors[1][1, :, :]), B.tensors[1][1, :, :])) do res, i
        return ein"(ij, iak), jal->kl"(res, conj(A.tensors[i]), B.tensors[i])
    end
    return tr(res)
end

function Base.:(+)(mps1::LabeledMPS{T1}, mps2::LabeledMPS{T2}) where {T1, T2}
    T = promote_type(T1, T2)
    n = nsite(mps1)
    n == 1 && return LabeledMPS([T.(mps1.tensors[1]) .+ T.(mps2.tensors[1])]; center=-1)
    @assert n == nsite(mps2) "LabeledMPS have different number of sites"
    return LabeledMPS([cat(T.(mps1.tensors[i]), T.(mps2.tensors[i]); dims=i==1 ? (3,) : i==n ? (1,) : (1,3)) for i = 1:n]; center=-1)
end

function Base.:(*)(coeff::Number, mps::LabeledMPS{T}) where {T}
    mps_copy = copy(mps)
    mps_copy.tensors[1] = T(coeff) * mps_copy.tensors[1]
    return mps_copy
end

###### Operations ######
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

function compress!(::LocalCompress, mps::LabeledMPS{T}; niters::Int=1, atol::RT=1e-12, maxdim::Int=typemax(Int)) where {RT,T<:Union{RT,Complex{RT}}}
    # Start from right canonical form
    for _ in 1:niters
        canonicalize!(mps, nsite(mps); atol, maxdim)
        canonicalize!(mps, 1; atol, maxdim)
    end
    return mps
end

function compress!(::FullCompress, mps::LabeledMPS{T}; atol::RT=1e-12, maxdim::Int=typemax(Int)) where {RT,T<:Union{RT,Complex{RT}}}
    MT = typeof(similar(mps.tensors[1], (1, 1))) # FIXME: better way to obtain <:AbstractArray{T, 2} from <:AbstractArray{T, 3}?

    # sweep from left to right to construct environment tensors
    L = Vector{MT}(undef, nsite(mps)); L[1] = similar(mps.tensors[1], (1, 1)); fill!(L[1], one(T))
    # ╭─i─┬─j
    # |   a
    # ╰─k─┴─l
    for i in 1:nsite(mps)-1
        L[i+1] = ein"(ik, iaj), kal->jl"(L[i], conj(mps.tensors[i]), mps.tensors[i])
    end

    embed = similar(mps.tensors[end], (1, 1)); fill!(embed, one(T))
    for i in reverse(2:nsite(mps))
        #     a   p
        # ╭─i─┴─j─╯
        # ╰─k─┬─l─╮
        #     b   q
        ρ = ein"(ik, (iaj, pj)), (kbl, ql)->apbq"(L[i], conj(mps.tensors[i]), conj(embed), mps.tensors[i], embed)
        ρ = reshape(ρ, size(ρ, 1) * size(ρ, 2), size(ρ, 3) * size(ρ, 4)) |> Hermitian

        _, U, _ = truncated_eigen(ρ, atol, maxdim)
        U = reshape(U', :, size(mps.tensors[i])[2], size(embed)[1])
        # ─p─┬─q─╮
        #    a   |
        # ─i─┴─j─╯
        embed = ein"iaj, (paq, qj)->pi"(mps.tensors[i], conj(U), embed)
        mps.tensors[i] = U
    end
    mps.tensors[1] = ein"iaj, pj->iap"(mps.tensors[1], embed)
    mps.center = 1 # update canonical center

    return mps
end

"""
    contract_with_compress!(mps::LabeledMPS, tensor::AbstractArray, tensor_label::Vector, vanish_labels::Vector; atol::Real=1e-12, maxdim::Int=typemax(Int))

Apply a tensor to the MPS and perform compression in a single sweep. This combines tensor application 
with density matrix compression, applying the tensor at the relevant sites and compressing using 
environment tensors.

# Arguments
- `mps::LabeledMPS`: the LabeledMPS to operate on
- `tensor::AbstractArray{T}`: the tensor to apply
- `tensor_label::Vector{LT}`: labels of the tensor indices
- `vanish_labels::Vector{LT}`: labels that will be contracted away

# Keyword arguments
- `atol::Real=1e-12`: the truncation tolerance
- `maxdim::Int=typemax(Int)`: the maximum bond dimension for truncation

# Returns
- `mps`: the LabeledMPS after tensor application and compression
"""
function contract_with_compress!(mps::LabeledMPS{T}, tensor::AbstractArray{T2}, tensor_label::Vector{LT}, vanish_labels::Vector{LT}; atol::RT=1e-12, maxdim::Int=typemax(Int)) where {RT, T<:Union{RT,Complex{RT}}, T2<:Number, LT}
    # First apply the tensor
    mps = apply_tensor!(mps, tensor, tensor_label, vanish_labels)
    
    # If MPS is too small, no compression needed
    nsite(mps) <= 1 && return mps
    
    MT = typeof(similar(mps.tensors[1], (1, 1)))
    
    # Build left environment tensors
    L = Vector{MT}(undef, nsite(mps))
    L[1] = similar(mps.tensors[1], (1, 1))
    fill!(L[1], one(T))
    
    # ╭─i─┬─j
    # |   a
    # ╰─k─┴─l
    for i in 1:nsite(mps)-1
        L[i+1] = ein"(ik, iaj), kal->jl"(L[i], conj(mps.tensors[i]), mps.tensors[i])
    end
    
    # Sweep from right to left, compressing at each site
    embed = similar(mps.tensors[end], (1, 1))
    fill!(embed, one(T))
    
    for i in reverse(2:nsite(mps))
        #     a   p
        # ╭─i─┴─j─╯
        # ╰─k─┬─l─╮
        #     b   q
        ρ = ein"(ik, (iaj, pj)), (kbl, ql)->apbq"(L[i], conj(mps.tensors[i]), conj(embed), mps.tensors[i], embed)
        ρ = reshape(ρ, size(ρ, 1) * size(ρ, 2), size(ρ, 3) * size(ρ, 4)) |> Hermitian
        
        _, U, _ = truncated_eigen(ρ, atol, maxdim)
        U = reshape(U', :, size(mps.tensors[i])[2], size(embed)[1])
        
        # ─p─┬─q─╮
        #    a   |
        # ─i─┴─j─╯
        embed = ein"iaj, (paq, qj)->pi"(mps.tensors[i], conj(U), embed)
        mps.tensors[i] = U
    end
    
    mps.tensors[1] = ein"iaj, pj->iap"(mps.tensors[1], embed)
    mps.center = 1
    
    return mps
end

# Threshold for using iterative methods vs full decomposition
# Iterative methods have overhead; they're only faster for large matrices (n > 256) 
# when requesting few eigenvalues (maxdim < n/4)
const ITERATIVE_THRESHOLD = 256

function truncated_svd(M::AbstractMatrix, atol::Real, maxdim::Int)
    @assert atol >= zero(atol) "Truncation tolerance must be nonnegative."
    @assert maxdim > 0 "Truncated bond dimension must be positive."
    
    m, n = size(M)
    min_dim = min(m, n)
    
    # Use iterative SVD (via eigensolve of M'M or MM') for large matrices when maxdim is small
    # Only beneficial when matrix is large AND we need few singular values
    if min_dim > ITERATIVE_THRESHOLD && maxdim < min_dim ÷ 4
        return _truncated_svd_iterative(M, atol, maxdim)
    else
        return _truncated_svd_full(M, atol, maxdim)
    end
end

function _truncated_svd_full(M::AbstractMatrix, atol::Real, maxdim::Int)
    res = LinearAlgebra.svd(M)
    r = min(searchsortedfirst(res.S, atol; rev=true) - 1, maxdim, length(res.S))
    r = max(r, 1)  # Ensure at least rank 1
    trunc_error = r < length(res.S) ? sum(res.S[(r + 1):end] .^ 2) : zero(eltype(res.S))
    return res.U[:, 1:r], res.S[1:r], res.Vt[1:r, :], trunc_error
end

function _truncated_svd_iterative(M::AbstractMatrix{T}, atol::Real, maxdim::Int) where T
    m, n = size(M)
    
    # Choose whether to work with M'M or MM' based on dimensions
    if m >= n
        # Work with M'M (n×n), get right singular vectors
        MtM = M' * M
        vals, vecs, info = eigsolve(MtM, min(maxdim + 5, n), :LR; krylovdim=max(30, 2*maxdim))
        
        # vals are eigenvalues of M'M = singular values squared
        svals = sqrt.(real.(vals))
        V = hcat(vecs...)  # Right singular vectors
        
        # Filter by tolerance
        r = min(searchsortedfirst(svals, atol; rev=true) - 1, maxdim, length(svals))
        r = max(r, 1)
        
        svals = svals[1:r]
        V = V[:, 1:r]
        
        # Compute U = M * V * S^{-1}
        U = M * V * Diagonal(1 ./ svals)
        Vt = V'
        
        trunc_error = r < length(vals) ? sum(real.(vals[(r+1):end])) : zero(real(T))
        return U, svals, Vt, trunc_error
    else
        # Work with MM' (m×m), get left singular vectors
        MMt = M * M'
        vals, vecs, info = eigsolve(MMt, min(maxdim + 5, m), :LR; krylovdim=max(30, 2*maxdim))
        
        svals = sqrt.(real.(vals))
        U = hcat(vecs...)  # Left singular vectors
        
        # Filter by tolerance
        r = min(searchsortedfirst(svals, atol; rev=true) - 1, maxdim, length(svals))
        r = max(r, 1)
        
        svals = svals[1:r]
        U = U[:, 1:r]
        
        # Compute V = S^{-1} * U' * M
        Vt = Diagonal(1 ./ svals) * U' * M
        
        trunc_error = r < length(vals) ? sum(real.(vals[(r+1):end])) : zero(real(T))
        return U, svals, Vt, trunc_error
    end
end

function truncated_eigen(M::AbstractMatrix, atol::Real, maxdim::Int)
    @assert atol >= zero(atol) "Truncation tolerance must be nonnegative."
    @assert maxdim > 0 "Truncated bond dimension must be positive."
    
    n = size(M, 1)
    
    # Use iterative eigensolver for large matrices when maxdim is small
    # Only beneficial when matrix is large AND we need few eigenvalues
    if n > ITERATIVE_THRESHOLD && maxdim < n ÷ 4
        return _truncated_eigen_iterative(M, atol, maxdim)
    else
        return _truncated_eigen_full(M, atol, maxdim)
    end
end

function _truncated_eigen_full(M::AbstractMatrix, atol::Real, maxdim::Int)
    res = LinearAlgebra.eigen(Hermitian(M); sortby=x -> -x)
    r = min(searchsortedfirst(res.values, atol; rev=true) - 1, maxdim, length(res.values))
    r = max(r, 1)  # Ensure at least rank 1
    trunc_error = r < length(res.values) ? sum(res.values[(r + 1):end] .^ 2) : zero(eltype(res.values))
    return res.values[1:r], res.vectors[:, 1:r], trunc_error
end

function _truncated_eigen_iterative(M::AbstractMatrix{T}, atol::Real, maxdim::Int) where T
    n = size(M, 1)
    
    # Use KrylovKit's eigsolve for largest eigenvalues
    # Request a few extra to handle tolerance filtering
    num_vals = min(maxdim + 5, n)
    vals, vecs, info = eigsolve(Hermitian(M), num_vals, :LR; krylovdim=max(30, 2*maxdim))
    
    # Convert to real (eigenvalues of Hermitian are real)
    real_vals = real.(vals)
    
    # Filter by tolerance
    r = min(searchsortedfirst(real_vals, atol; rev=true) - 1, maxdim, length(real_vals))
    r = max(r, 1)
    
    filtered_vals = real_vals[1:r]
    filtered_vecs = hcat(vecs[1:r]...)
    
    # Estimate truncation error (sum of discarded eigenvalues squared)
    trunc_error = r < length(real_vals) ? sum(real_vals[(r+1):end] .^ 2) : zero(real(T))
    
    return filtered_vals, filtered_vecs, trunc_error
end

