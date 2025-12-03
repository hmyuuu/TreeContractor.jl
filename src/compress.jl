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

# make a isometric matrix unitary
function fullrank(q::AbstractArray{T,2}) where {T}
    return qr(q').Q[:,:]'
end

###### MPO Application ######

"""
    apply!(mode::CompressAlgorithm, mpo::ContractorMPO{T}, mps::ContractorMPS{T}; atol=1e-12, maxdim=maxlinkdim(mps) * maxlinkdim(mpo)) where {T}

Apply the MPO to the MPS using the `mode` algorithm.

# Arguments
- `mode`: the algorithm to use for the application, currently support `LocalCompress()` and `FullCompress()`
- `mpo`: the ContractorMPO to apply
- `mps`: the ContractorMPS to apply the MPO to

# Keyword arguments
- `atol`: the truncation tolerance for the SVD
- `maxdim`: the maximum bond dimension for the SVD

# Returns
- `mps`: the ContractorMPS after the application

# References
- https://tensornetwork.org/mps/algorithms/#mpo
"""
function apply!(::LocalCompress, mpo::ContractorMPO{T}, mps::ContractorMPS{T}; atol=1e-12, maxdim=maxlinkdim(mps) * maxlinkdim(mpo)) where {T}
    @assert nsite(mpo) == nsite(mps)
    @assert nflavor(mpo) == nflavor(mps)

    # sweep from left to right
    L_env = ones(T, 1, 1, 1)
    for i in 1:nsite(mps)-1
        temp = ein"(imj, jak), mban->ibnk"(L_env, mps.data[i], mpo.data[i])
        U, S, V, _ = truncated_svd(reshape(temp, size(temp, 1) * size(temp, 2), size(temp, 3) * size(temp, 4)), atol, maxdim)
        mps.data[i] = reshape(U, size(temp)[1:2]..., :)
        L_env = reshape(Diagonal(S) * V, :, size(temp)[3:4]...)
    end
    temp = ein"(imj, jak), mban->ibnk"(L_env, mps.data[end], mpo.data[end])
    mps.data[end] = reshape(temp, size(temp)[1:2]..., size(temp, 3) * size(temp, 4))
    # update canonical center
    mps.center = nsite(mps)
    return mps
end

function apply!(::FullCompress, mpo::ContractorMPO{T}, mps::ContractorMPS{T}; atol=1e-13, maxdim=maxlinkdim(mps) * maxlinkdim(mpo)) where {T}
    @assert nsite(mpo) == nsite(mps)
    @assert nflavor(mpo) == nflavor(mps)

    # sweep from left to right to construct environment tensors
    L = Vector{eltype(mpo.data)}(undef, nsite(mps)); L[1] = similar(mpo.data[1], (1, 1, 1, 1)); fill!(L[1], one(T))
    # ╭─i─┬─j   Note: physical indices (top to bottom): a, b, c
    # ├─k─┼─l
    # ├─m─┼─n
    # ╰─o─┴─p
    for i in 1:nsite(mps)-1
        L[i+1] = ein"(((ikom, iaj), kbal), mbcn), ocp->jlpn"(L[i], conj(mps.data[i]), conj(mpo.data[i]), mpo.data[i], mps.data[i])
    end

    embed = similar(mps.data[end], (1, 1, 1)); fill!(embed, one(T))
    for i in reverse(2:nsite(mps))
        #     b   r   Note: Indices of environment tensors are [mps virtual, mpo virtual, mps virtual, mpo virtual]. Need to be careful here.
        # ╭─m─┼─n─┤
        # |   a   |
        # ├─i─┴─j─╯
        # ├─k─┬─l─╮
        # |   c   |
        # ╰─o─┼─p─┤
        #     d   s
        ρ = ein"(imko, ((iaj, rnj), mban)), ((kcl, spl), odcp)->brds"(L[i], conj(mps.data[i]), conj(embed), conj(mpo.data[i]), mps.data[i], embed, mpo.data[i])
        ρ = reshape(ρ, size(ρ, 1) * size(ρ, 2), size(ρ, 3) * size(ρ, 4)) |> Hermitian

        _, U, _ = truncated_eigen(ρ, atol, maxdim)
        U = reshape(U', :, size(mpo.data[i], 2), size(embed, 1)) # Note: physical indices according to MPO
        # ─p─┬─q─╮
        #    b   |
        # ─m─┼─n─┤
        #    a   |
        # ─i─┴─j─╯
        embed = ein"pbq, (mban, (iaj, qnj))->pmi"(conj(U), mpo.data[i], mps.data[i], embed)
        mps.data[i] = U
    end  
    #    b   q
    # ─m─┼─n─┤
    #    a   |
    # ─i─┴─j─╯
    mps.data[1] = reshape(ein"mban, (iaj, qnj)->mibq"(mpo.data[1], mps.data[1], embed), :, size(mpo.data[1], 2), size(embed, 1))
    mps.center = 1 # update canonical center

    return mps
end

###### ContractorMPS Canonicalization ######

is_canonicalized(mps::ContractorMPS) = mps.center !== -1

"""
    canonicalize!(mps::ContractorMPS, i::Int; atol::Real=1e-12, maxdim::Int=typemax(Int))

Canonicalize the ContractorMPS, with the canonical center at site `i`. If the ContractorMPS is already canonicalized, move the center to site `i`.

# Arguments
- `mps::ContractorMPS`: the ContractorMPS to canonicalize
- `i::Int`: the site index of the canonical center
- `atol::Real=1e-12`: the truncation error
- `maxdim::Int=typemax(Int)`: the maximum bond dimension for truncation
"""
function canonicalize!(mps::ContractorMPS{T}, i::Int; atol::RT=1e-12, maxdim::Int=typemax(Int)) where {RT,T<:Union{RT,Complex{RT}}}
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

function canonical_move_right!(mps::ContractorMPS, atol::Real, maxdim::Int)
    @assert is_canonicalized(mps) "ContractorMPS is not canonicalized. Use canonicalize! first."
    @assert mps.center < nsite(mps) "Cannot move right from the rightmost site."
    j = mps.center
    U, S, V, _ = truncated_svd(reshape(mps.data[j], :, size(mps.data[j])[3]), atol, maxdim)
    mps.data[j] = reshape(U, size(mps.data[j])[1:2]..., :)
    mps.data[j + 1] = ein"(i, ij), jak->iak"(S, V, mps.data[j + 1])
    mps.center += 1
    return mps
end

function canonical_move_left!(mps::ContractorMPS, atol::Real, maxdim::Int)
    @assert is_canonicalized(mps) "ContractorMPS is not canonicalized. Use canonicalize! first."
    @assert mps.center > 1 "Cannot move left from the leftmost site."
    j = mps.center
    U, S, V, _ = truncated_svd(reshape(mps.data[j], size(mps.data[j])[1], :), atol, maxdim)
    mps.data[j] = reshape(V, :, size(mps.data[j])[2:3]...)
    mps.data[j - 1] = ein"iaj, (jk, k)->iak"(mps.data[j - 1], U, S)
    mps.center -= 1
    return mps
end

###### ContractorMPS Compression ######

"""
    compress!(::LocalCompress, mps::ContractorMPS; niters, atol, maxdim)

Compress ContractorMPS using LocalCompress algorithm. This performs local SVDs and updates tensors serially.
"""
function compress!(::LocalCompress, mps::ContractorMPS{T}; niters::Int=1, atol::RT=1e-12, maxdim::Int=typemax(Int)) where {RT,T<:Union{RT,Complex{RT}}}
    # Start from right canonical form
    for _ in 1:niters
        canonicalize!(mps, nsite(mps); atol, maxdim)
        canonicalize!(mps, 1; atol, maxdim)
    end
    return mps
end

"""
    compress!(::FullCompress, mps::ContractorMPS; atol, maxdim)

Compress ContractorMPS using FullCompress algorithm. This takes environment tensors into account for optimal truncation.
"""
function compress!(::FullCompress, mps::ContractorMPS{T}; atol::RT=1e-12, maxdim::Int=typemax(Int)) where {RT,T<:Union{RT,Complex{RT}}}
    MT = typeof(similar(mps.data[1], (1, 1))) # FIXME: better way to obtain <:AbstractArray{T, 2} from <:AbstractArray{T, 3}?

    # sweep from left to right to construct environment tensors
    L = Vector{MT}(undef, nsite(mps)); L[1] = similar(mps.data[1], (1, 1)); fill!(L[1], one(T))
    # ╭─i─┬─j
    # |   a
    # ╰─k─┴─l
    for i in 1:nsite(mps)-1
        L[i+1] = ein"(ik, iaj), kal->jl"(L[i], conj(mps.data[i]), mps.data[i])
    end

    embed = similar(mps.data[end], (1, 1)); fill!(embed, one(T))
    # Cache conj(embed) since it's reused in the loop
    conj_embed = conj(embed)
    for i in reverse(2:nsite(mps))
        # Cache conj(mps.data[i]) since it's used twice in density matrix computation
        conj_mps_i = conj(mps.data[i])
        
        #     a   p
        # ╭─i─┴─j─╯
        # ╰─k─┬─l─╮
        #     b   q
        # Optimize: pre-compute conj(mps.data[i]) and conj(embed) to avoid repeated conj calls
        ρ = ein"(ik, (iaj, pj)), (kbl, ql)->apbq"(L[i], conj_mps_i, conj_embed, mps.data[i], embed)
        ρ = reshape(ρ, size(ρ, 1) * size(ρ, 2), size(ρ, 3) * size(ρ, 4)) |> Hermitian

        _, U, _ = truncated_eigen(ρ, atol, maxdim)
        U = reshape(U', :, size(mps.data[i])[2], size(embed)[1])
        
        # Update embed for next iteration
        # ─p─┬─q─╮
        #    a   |
        # ─i─┴─j─╯
        # Cache conj(U) since it's used in the einsum
        conj_U = conj(U)
        embed = ein"iaj, (paq, qj)->pi"(mps.data[i], conj_U, embed)
        # Update cached conj_embed for next iteration
        conj_embed = conj(embed)
        mps.data[i] = U
    end
    mps.data[1] = ein"iaj, pj->iap"(mps.data[1], embed)
    mps.center = 1 # update canonical center

    return mps
end

###### ContractorMPS Linear Algebra for MPO Application ######

function LinearAlgebra.norm(mps::ContractorMPS)
    if is_canonicalized(mps)
        center = mps.center
        return sqrt(real(ein"iaj, iaj->"(conj(mps.data[center]), mps.data[center])[]))
    else
        return sqrt(real(dot(mps, mps)))
    end
end

function LinearAlgebra.normalize!(mps::ContractorMPS)
    mps.data[is_canonicalized(mps) ? mps.center : 1] ./= norm(mps)
    return mps
end

function LinearAlgebra.dot(bra::ContractorMPS, ket::ContractorMPS)
    @assert nsite(bra) == nsite(ket) "ContractorMPS must have same number of sites"
    res = foldl(2:nsite(bra); init=ein"ai, aj->ij"(conj(bra.data[1][1, :, :]), ket.data[1][1, :, :])) do res, i
        return ein"(ij, iak), jal->kl"(res, conj(bra.data[i]), ket.data[i])
    end
    return tr(res)
end

"""
    expectation(operator, mps::ContractorMPS)

Compute the expectation value of an Hamiltonian operator on the MPS at a given site. This is a special case of `sandwich` with a single operator string.

# Arguments
- `operator`: the Hamiltonian operator (ContractorMPO)
- `mps`: the ContractorMPS to compute the expectation value

# Returns
- `expectation`: the real expectation value of the Hamiltonian operator on the MPS at the given site
"""
function expectation(operator, mps::ContractorMPS)
    return real(sandwich(mps, operator, mps)) / norm(mps)^2
end

"""
    sandwich(bra::ContractorMPS{T}, mpo::ContractorMPO{T}, ket::ContractorMPS{T}) where {T}

Compute the sandwich product (bra * operator * ket) of an MPO on the MPS.

# Arguments
- `bra`: the bra state
- `mpo`: the ContractorMPO to compute the sandwich product
- `ket`: the ket state

# Returns
- `sandwich`: the sandwich product of the MPO on the MPS
"""
function sandwich(bra::ContractorMPS{T}, mpo::ContractorMPO{T}, ket::ContractorMPS{T}) where {T}
    # TODO: use simple sweep!!!!
    return dot(bra, apply!(LocalCompress(), mpo, copy(ket)))
end