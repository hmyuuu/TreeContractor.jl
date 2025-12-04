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
# CompressAlgorithm, LocalCompress, and FullCompress are defined in TreeContractor.jl

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

###### MPO-MPS Application with Compression ######

"""
    apply!(mode::CompressAlgorithm, mpo::LabeledMPO{T}, mps::LabeledMPS{T}; atol=1e-12, maxdim=maxlinkdim(mps) * maxlinkdim(mpo)) where {T}

Apply the MPO to the MPS using the `mode` algorithm, contracting and compressing simultaneously.

# Arguments
- `mode`: the algorithm to use for the application, either `LocalCompress()` (zip-up) or `FullCompress()` (density matrix)
- `mpo`: the MPO to apply
- `mps`: the MPS to apply the MPO to

# Keyword arguments
- `atol`: the truncation tolerance for the SVD/eigendecomposition
- `maxdim`: the maximum bond dimension for the SVD/eigendecomposition

# Returns
- `mps`: the MPS after the application (modified in-place)

# References
- Zip-up (LocalCompress): https://tensornetwork.org/mps/algorithms/zip_up_mpo/
- Density Matrix (FullCompress): https://tensornetwork.org/mps/algorithms/denmat_mpo_mps/
"""
function apply!(::LocalCompress, mpo::LabeledMPO{T}, mps::LabeledMPS{T}; atol::RT=1e-12, maxdim::Int=maxlinkdim(mps) * maxlinkdim(mpo)) where {RT,T<:Union{RT,Complex{RT}}}
    @assert nsite(mpo) == nsite(mps) "MPO and MPS must have the same number of sites"
    @assert nflavor(mpo) == nflavor(mps) "MPO and MPS must have the same physical dimension"

    # Zip-up algorithm: sweep from left to right
    # Index convention for MPO tensor: (left_virtual, bra_physical, ket_physical, right_virtual) = (m, b, a, n)
    # Index convention for MPS tensor: (left_virtual, physical, right_virtual) = (i, a, j)
    # 
    # After applying MPO to MPS at site, the exact result is:
    # mps(i,a,j) * mpo(m,b,a,n) -> (i,m,b,j,n) reshape to (i*m, b, j*n)
    #
    # L_env connects the truncated left bond to the combined (mps_left, mpo_left) space
    # L_env shape: (truncated_left, mps_left, mpo_left)
    L_env = ones(T, 1, 1, 1)
    
    for i in 1:nsite(mps)-1
        # Contract: L_env(l,i,m) * mps[i](i,a,j) * mpo[i](m,b,a,n) -> (l,b,j,n)
        # Physical index 'a' connects MPS to MPO ket
        # Output physical index is 'b' (MPO bra)
        # Right indices: (j,n) = (mps_right, mpo_right) to match exact order
        temp = ein"(lim, iaj), mban->lbjn"(L_env, mps.tensors[i], mpo.tensors[i])
        
        # SVD to truncate: reshape to (l*b, j*n) and decompose
        temp_mat = reshape(temp, size(temp, 1) * size(temp, 2), size(temp, 3) * size(temp, 4))
        U, S, V, _ = truncated_svd(temp_mat, atol, maxdim)
        
        # U becomes the new MPS tensor at site i: (l, b, new_bond)
        mps.tensors[i] = reshape(U, size(temp, 1), size(temp, 2), size(U, 2))
        
        # S*V becomes the new L_env: (new_bond, j, n) = (new_bond, mps_right, mpo_right)
        L_env = reshape(Diagonal(S) * V, size(U, 2), size(temp, 3), size(temp, 4))
    end
    
    # Last site: absorb the remaining L_env
    # Contract: L_env(l,i,m) * mps[end](i,a,j) * mpo[end](m,b,a,n) -> (l,b,j,n)
    # Since it's the last site, j=1 and n=1, so reshape to (l,b,1)
    temp = ein"(lim, iaj), mban->lbjn"(L_env, mps.tensors[end], mpo.tensors[end])
    mps.tensors[end] = reshape(temp, size(temp, 1), size(temp, 2), size(temp, 3) * size(temp, 4))
    
    # Update canonical center (result is right-canonical except for last site)
    mps.center = nsite(mps)
    return mps
end

function apply!(::FullCompress, mpo::LabeledMPO{T}, mps::LabeledMPS{T}; atol::RT=1e-12, maxdim::Int=maxlinkdim(mps) * maxlinkdim(mpo)) where {RT,T<:Union{RT,Complex{RT}}}
    @assert nsite(mpo) == nsite(mps) "MPO and MPS must have the same number of sites"
    @assert nflavor(mpo) == nflavor(mps) "MPO and MPS must have the same physical dimension"

    # Density matrix algorithm for MPO-MPS application
    # Index convention for MPO tensor: (left_virtual, bra_physical, ket_physical, right_virtual) = (m, b, a, n)
    # Index convention for MPS tensor: (left_virtual, physical, right_virtual) = (i, a, j)
    #
    # The result of MPO|ψ⟩ at site i is:
    #   mps(i,a,j) * mpo(m,b,a,n) -> (i,m,b,j,n) reshape to (i*m, b, j*n)
    
    N = nsite(mps)
    
    # Step 1: First apply MPO to MPS to get the full (uncompressed) result
    # Store the combined tensors before compression
    combined = Vector{Array{T,3}}(undef, N)
    for i in 1:N
        # Contract MPS with MPO: mps(i,a,j) * mpo(m,b,a,n) -> (i,m,b,j,n)
        temp = ein"iaj, mban->imbjn"(mps.tensors[i], mpo.tensors[i])
        combined[i] = reshape(temp, 
            size(mps.tensors[i], 1) * size(mpo.tensors[i], 1),
            size(mpo.tensors[i], 2),
            size(mps.tensors[i], 3) * size(mpo.tensors[i], 4))
    end
    
    # Step 2: Build left environment tensors for the combined state
    # L[i] has indices (bra, ket) for the density matrix of the left part
    MT = typeof(similar(mps.tensors[1], (1, 1)))
    L = Vector{MT}(undef, N)
    L[1] = similar(mps.tensors[1], (1, 1))
    fill!(L[1], one(T))
    
    # ╭─i─┬─j
    # |   a
    # ╰─k─┴─l
    for i in 1:N-1
        L[i+1] = ein"(ik, iaj), kal->jl"(L[i], conj(combined[i]), combined[i])
    end
    
    # Step 3: Sweep R→L computing reduced density matrix and optimal projectors
    embed = similar(mps.tensors[end], (1, 1))
    fill!(embed, one(T))
    
    for i in reverse(2:N)
        #     a   p
        # ╭─i─┴─j─╯
        # ╰─k─┬─l─╮
        #     b   q
        ρ = ein"(ik, (iaj, pj)), (kbl, ql)->apbq"(L[i], conj(combined[i]), conj(embed), combined[i], embed)
        ρ = reshape(ρ, size(ρ, 1) * size(ρ, 2), size(ρ, 3) * size(ρ, 4)) |> Hermitian

        _, U, _ = truncated_eigen(ρ, atol, maxdim)
        U = reshape(U', :, size(combined[i], 2), size(embed, 1))
        
        # ─p─┬─q─╮
        #    a   |
        # ─i─┴─j─╯
        embed = ein"iaj, (paq, qj)->pi"(combined[i], conj(U), embed)
        mps.tensors[i] = U
    end
    
    mps.tensors[1] = ein"iaj, pj->iap"(combined[1], embed)
    mps.center = 1
    
    return mps
end

function truncated_svd(M::AbstractMatrix, atol::Real, maxdim::Int)
    @assert atol >= zero(atol) "Truncation tolerance must be nonnegative."
    @assert maxdim > 0 "Truncated bond dimension must be positive."

    res = LinearAlgebra.svd(M)
    r = min(searchsortedfirst(res.S, atol; rev=true) - 1, maxdim, length(res.S))

    # Note: may have performance issue due to the copy
    return res.U[:, 1:r], res.S[1:r], res.Vt[1:r, :], sum(res.S[(r + 1):end] .^ 2) # FIXME: why do such truncation?
end

function truncated_eigen(M::AbstractMatrix, atol::Real, maxdim::Int)
    @assert atol >= zero(atol) "Truncation tolerance must be nonnegative."
    @assert maxdim > 0 "Truncated bond dimension must be positive."

    res = LinearAlgebra.eigen(M; sortby=x -> -x)
    r = min(searchsortedfirst(res.values, atol; rev=true) - 1, maxdim, length(res.values))

    # Note: may have performance issue due to the copy
    return res.values[1:r], res.vectors[:, 1:r], sum(res.values[(r + 1):end] .^ 2) # FIXME: why do such truncation?
end