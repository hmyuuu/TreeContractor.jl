###### SVD Distribution Strategies ######
"""
    SVDDistribution

Abstract type for SVD distribution strategies during canonicalization.
"""
abstract type SVDDistribution end

"""
    SymmetricSVD <: SVDDistribution

Distribute √S to both sides of SVD for numerical stability.
This balances tensor magnitudes but breaks strict isometry.
"""
struct SymmetricSVD <: SVDDistribution end

"""
    IsometricSVD <: SVDDistribution

Standard canonical form where one side gets U (or V) as isometry
and the other side absorbs S. Maintains strict isometry property.
"""
struct IsometricSVD <: SVDDistribution end

###### Norm Tracking Strategies ######
"""
    NormTracking

Abstract type for norm tracking strategies during canonicalization.
"""
abstract type NormTracking end

"""
    TrackLognorm <: NormTracking

Extract scale factors during SVD and accumulate in mps.lognorm.
Useful for tensor networks with extreme norm values.
"""
struct TrackLognorm <: NormTracking end

"""
    NoTrackNorm <: NormTracking

Do not track norm during canonicalization (default behavior).
"""
struct NoTrackNorm <: NormTracking end

###### Canonicalization related APIs ######
is_canonicalized(mps::LabeledMPS) = mps.center !== -1
orthocenter(mps::LabeledMPS) = is_canonicalized(mps) ? mps.center : nothing

"""
    canonicalize!(mps::LabeledMPS, i::Int, [svd_dist], [norm_track]; atol, rtol, maxdim)

Canonicalize the LabeledMPS, with the canonical center at site `i`.

# Arguments
- `mps::LabeledMPS`: the LabeledMPS to canonicalize
- `i::Int`: the site index of the canonical center
- `svd_dist::SVDDistribution=SymmetricSVD()`: SVD distribution strategy
- `norm_track::NormTracking=TrackLognorm()`: norm tracking strategy
- `atol::Real=1e-12`: absolute truncation tolerance
- `rtol::Real=0.0`: relative truncation tolerance
- `maxdim::Int=typemax(Int)`: maximum bond dimension
"""
function canonicalize!(mps::LabeledMPS{T}, i::Int, svd_dist::SVDDistribution=SymmetricSVD(), norm_track::NormTracking=TrackLognorm(); atol::RT=1e-12, rtol::RT=zero(RT), maxdim::Int=typemax(Int)) where {RT,T<:Union{RT,Complex{RT}}}
    n = nsite(mps)
    @assert 1 <= i <= n "Center index i must be between 1 and $n"

    if is_canonicalized(mps)  # move center
        for center in mps.center+1:i     # right moving
            canonical_move_right!(mps, svd_dist, norm_track, atol, rtol, maxdim)
        end
        for center in mps.center-1:-1:i  # left moving
            canonical_move_left!(mps, svd_dist, norm_track, atol, rtol, maxdim)
        end
        return mps
    else   # initialize center
        mps.center = 1
        for center in 2:i  # right moving
            canonical_move_right!(mps, svd_dist, norm_track, atol, rtol, maxdim)
        end

        mps.center = n
        for center in n-1:-1:i  # left moving
            canonical_move_left!(mps, svd_dist, norm_track, atol, rtol, maxdim)
        end

        return mps
    end
end

# Scale tracking dispatch
track_scale!(::NoTrackNorm, mps::LabeledMPS, S) = S
function track_scale!(::TrackLognorm, mps::LabeledMPS, S)
    isempty(S) && return S
    scale = S[1]
    mps.lognorm += log(scale)
    return S ./ scale
end

# SVD distribution dispatch - move right
function distribute_svd_right!(::SymmetricSVD, mps::LabeledMPS, j::Int, U, S, V)
    sqrtS = sqrt.(S)
    mps.tensors[j] = reshape(U * Diagonal(sqrtS), size(mps.tensors[j])[1:2]..., :)
    mps.tensors[j + 1] = ein"(i, ij), jak->iak"(sqrtS, V, mps.tensors[j + 1])
end

function distribute_svd_right!(::IsometricSVD, mps::LabeledMPS, j::Int, U, S, V)
    mps.tensors[j] = reshape(U, size(mps.tensors[j])[1:2]..., :)
    mps.tensors[j + 1] = ein"(i, ij), jak->iak"(S, V, mps.tensors[j + 1])
end

# SVD distribution dispatch - move left
function distribute_svd_left!(::SymmetricSVD, mps::LabeledMPS, j::Int, U, S, V)
    sqrtS = sqrt.(S)
    mps.tensors[j] = reshape(Diagonal(sqrtS) * V, :, size(mps.tensors[j])[2:3]...)
    mps.tensors[j - 1] = ein"iaj, (jk, k)->iak"(mps.tensors[j - 1], U, sqrtS)
end

function distribute_svd_left!(::IsometricSVD, mps::LabeledMPS, j::Int, U, S, V)
    mps.tensors[j] = reshape(V, :, size(mps.tensors[j])[2:3]...)
    mps.tensors[j - 1] = ein"iaj, (jk, k)->iak"(mps.tensors[j - 1], U, S)
end

function canonical_move_right!(mps::LabeledMPS, svd_dist::SVDDistribution, norm_track::NormTracking, atol::Real, rtol::Real, maxdim::Int)
    @assert is_canonicalized(mps) "LabeledMPS is not canonicalized. Use canonicalize! first."
    @assert mps.center < nsite(mps) "Cannot move right from the rightmost site."
    j = mps.center
    U, S, V, _ = truncated_svd(reshape(mps.tensors[j], :, size(mps.tensors[j])[3]), atol, rtol, maxdim)
    S = track_scale!(norm_track, mps, S)
    distribute_svd_right!(svd_dist, mps, j, U, S, V)
    mps.center += 1
    return mps
end

function canonical_move_left!(mps::LabeledMPS, svd_dist::SVDDistribution, norm_track::NormTracking, atol::Real, rtol::Real, maxdim::Int)
    @assert is_canonicalized(mps) "LabeledMPS is not canonicalized. Use canonicalize! first."
    @assert mps.center > 1 "Cannot move left from the leftmost site."
    j = mps.center
    U, S, V, _ = truncated_svd(reshape(mps.tensors[j], size(mps.tensors[j])[1], :), atol, rtol, maxdim)
    S = track_scale!(norm_track, mps, S)
    distribute_svd_left!(svd_dist, mps, j, U, S, V)
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

function compress!(::LocalCompress, mps::LabeledMPS{T}, svd_dist::SVDDistribution=SymmetricSVD(), norm_track::NormTracking=TrackLognorm(); niters::Int=1, atol::RT=1e-12, rtol::RT=zero(RT), maxdim::Int=typemax(Int)) where {RT,T<:Union{RT,Complex{RT}}}
    # Start from right canonical form
    for _ in 1:niters
        canonicalize!(mps, nsite(mps), svd_dist, norm_track; atol, rtol, maxdim)
        canonicalize!(mps, 1, svd_dist, norm_track; atol, rtol, maxdim)
    end
    return mps
end

function compress!(::FullCompress, mps::LabeledMPS{T}; atol::RT=1e-12, rtol::RT=zero(RT), maxdim::Int=typemax(Int)) where {RT,T<:Union{RT,Complex{RT}}}
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

        _, U, _ = truncated_eigen(ρ, atol, rtol, maxdim)
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

function truncated_svd(M::AbstractMatrix, atol::Real, rtol::Real, maxdim::Int)
    @assert atol >= zero(atol) "Absolute truncation tolerance must be nonnegative."
    @assert rtol >= zero(rtol) "Relative truncation tolerance must be nonnegative."
    @assert maxdim > 0 "Truncated bond dimension must be positive."

    res = LinearAlgebra.svd(M)
    # Cutoff is the larger of absolute tolerance or relative tolerance * max singular value
    cutoff = isempty(res.S) ? atol : max(atol, rtol * res.S[1])
    r = min(searchsortedfirst(res.S, cutoff; rev=true) - 1, maxdim, length(res.S))

    # Slicing creates copies (necessary for reshape compatibility in callers)
    return res.U[:, 1:r], res.S[1:r], res.Vt[1:r, :], sum(abs2, @view(res.S[(r + 1):end]))
end

function truncated_eigen(M::AbstractMatrix, atol::Real, rtol::Real, maxdim::Int)
    @assert atol >= zero(atol) "Absolute truncation tolerance must be nonnegative."
    @assert rtol >= zero(rtol) "Relative truncation tolerance must be nonnegative."
    @assert maxdim > 0 "Truncated bond dimension must be positive."

    res = LinearAlgebra.eigen(M; sortby=x -> -x)
    # Cutoff is the larger of absolute tolerance or relative tolerance * max eigenvalue
    cutoff = isempty(res.values) ? atol : max(atol, rtol * res.values[1])
    r = min(searchsortedfirst(res.values, cutoff; rev=true) - 1, maxdim, length(res.values))

    # Slicing creates copies (necessary for reshape compatibility in callers)
    return res.values[1:r], res.vectors[:, 1:r], sum(abs2, @view(res.values[(r + 1):end]))
end
