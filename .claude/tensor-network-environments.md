# Environment Tensors in Tensor Network Simulation

## What Are Environment Tensors?

In tensor network algorithms, **environment tensors** (also called **boundary tensors**, **overlap tensors**, or **transfer matrices**) are auxiliary tensors that store partial contractions of the tensor network. They represent the "environment" surrounding a specific region of interest in the network, effectively caching the contraction of all tensors to the left or right of that region.

### Conceptual Understanding

Consider a Matrix Product State (MPS) with N sites:

```
|ψ⟩ = A[1]--A[2]--A[3]--...--A[i]--...--A[N-1]--A[N]
```

When computing operations at site `i`, we need to account for:
- **Everything to the left** of site `i` → **Left Environment** `L[i]`
- **Everything to the right** of site `i` → **Right Environment** `R[i]`

This partitioning allows us to focus computational effort on site `i` while treating the rest of the network efficiently through pre-computed environment tensors.

## Mathematical Definition

### Left Environment Tensor

The left environment tensor `L[i]` represents the contraction of all MPS tensors from site 1 to site `i-1`:

For a simple MPS overlap ⟨ψ|ψ⟩:
```
L[1] = 1 (identity, boundary condition)

L[i+1] = Σ L[i] × conj(A[i]) × A[i]
          (contracted over shared indices)
```

**Tensor diagram**:
```
╭─i─┬─j     Left environment structure
|   a       i,j: virtual bond indices
╰─k─┴─l     a: physical index
```

### Right Environment Tensor

The right environment tensor `R[i]` represents the contraction of all MPS tensors from site `i+1` to site N:

```
R[N+1] = 1 (identity, boundary condition)

R[i] = Σ R[i+1] × conj(A[i]) × A[i]
        (contracted over shared indices)
```

## Construction in TreeContractor.jl

### Example from `FullCompress` Algorithm

In `src/compress.jl:146-179`, the FullCompress algorithm demonstrates environment tensor construction:

#### Step 1: Build Left Environments (Line 149-156)

```julia
# Initialize left boundary
L = Vector{MT}(undef, nsite(mps))
L[1] = similar(mps.tensors[1], (1, 1))
fill!(L[1], one(T))

# Sweep left to right, building environments
for i in 1:nsite(mps)-1
    L[i+1] = ein"(ik, iaj), kal->jl"(L[i], conj(mps.tensors[i]), mps.tensors[i])
end
```

**Einstein notation breakdown**:
- `L[i]` has indices `(i,k)` - left MPS bonds
- `conj(mps.tensors[i])` has indices `(i,a,j)` - bra tensor
- `mps.tensors[i]` has indices `(k,a,l)` - ket tensor
- Result `L[i+1]` has indices `(j,l)` - right MPS bonds

This contraction:
1. Takes the previous left environment
2. Contracts it with the conjugate (bra) MPS tensor
3. Contracts with the ket MPS tensor
4. Produces the next left environment

#### Step 2: Use Environments for Compression (Line 159-178)

```julia
embed = similar(mps.tensors[end], (1, 1))
fill!(embed, one(T))

for i in reverse(2:nsite(mps))
    # Construct reduced density matrix using left environment
    ρ = ein"(ik, (iaj, pj)), (kbl, ql)->apbq"(
        L[i],                    # Left environment
        conj(mps.tensors[i]),    # Bra at site i
        conj(embed),             # Right environment (embedded)
        mps.tensors[i],          # Ket at site i
        embed                    # Right environment
    )

    # Diagonalize density matrix
    ρ = reshape(ρ, size(ρ, 1) * size(ρ, 2), size(ρ, 3) * size(ρ, 4)) |> Hermitian
    _, U, _ = truncated_eigen(ρ, atol, maxdim)

    # Project MPS onto optimal truncation basis
    U = reshape(U', :, size(mps.tensors[i])[2], size(embed)[1])
    embed = ein"iaj, (paq, qj)->pi"(mps.tensors[i], conj(U), embed)
    mps.tensors[i] = U
end
```

The key insight: **The density matrix ρ combines left and right environments**, capturing all global information needed for optimal truncation.

## Why Are Environments Important?

### 1. Computational Efficiency

**Without environments**: Computing a local observable would require contracting the entire tensor network from scratch each time.

**With environments**: We pre-compute and cache left/right contractions, then reuse them:
- **Time complexity**: O(N) preprocessing + O(1) per query
- **Without caching**: O(N) per query

### 2. Memory Efficiency vs Full Tensor Storage

For an N-site MPS with bond dimension χ and physical dimension d:
- **Full state vector**: O(d^N) memory - exponential!
- **MPS + Environments**: O(N × χ² × d) memory - linear in N!

### 3. Variational Optimization (Critical for DMRG)

In variational algorithms like DMRG:

1. **Fix** all tensors except site `i`
2. **Use environments** to construct effective Hamiltonian at site `i`
3. **Optimize** only tensor `i` in the presence of its environment
4. **Repeat** for all sites

The environments represent "how the rest of the system responds" to changes at site `i`.

### 4. Optimal Truncation (FullCompress Algorithm)

The density matrix constructed from environments:

```
ρ = Tr_outside [ |ψ⟩⟨ψ| ]
```

Diagonalizing ρ gives the **Schmidt decomposition**, which is provably optimal for truncating quantum states. The environment tensors provide the "outside" trace operation.

## Comparison: LocalCompress vs FullCompress

### LocalCompress (No Environments)

```julia
function compress!(::LocalCompress, mps; ...)
    canonicalize!(mps, nsite(mps); atol, maxdim)  # Right sweep
    canonicalize!(mps, 1; atol, maxdim)           # Left sweep
end
```

**Characteristics**:
- No environment tensors stored
- Local SVD at each bond
- **Does NOT consider global state**
- Fast but approximate

### FullCompress (Uses Environments)

```julia
function compress!(::FullCompress, mps; ...)
    # Build left environments
    L = construct_left_environments(mps)

    # Use environments to build density matrices
    for each site:
        ρ = combine(L[i], mps[i], R[i])
        optimize based on ρ
end
```

**Characteristics**:
- **Explicitly constructs** left environment tensors
- **Implicitly builds** right environments via `embed` tensor
- **Considers global correlations** through density matrix
- Slower but **optimal truncation guaranteed**

## Environment Update Strategy

### Static Environments (TreeContractor.jl)

In the FullCompress algorithm:
1. Build **all** left environments once (forward sweep)
2. Use them during optimization (backward sweep)
3. Don't update environments during optimization

### Dynamic Environments (DMRG-style)

In iterative optimization:
1. **Right sweep**: Update left environments as you go
2. **Left sweep**: Update right environments as you go
3. Environments always reflect the **most recent** MPS tensors

Example update pattern:
```julia
# During right sweep at site i
update_left_environment!(L, i)   # L[i+1] = contract(L[i], mps[i])
optimize_site(i)                 # Using L[i] and R[i+1]

# During left sweep at site i
update_right_environment!(R, i)  # R[i] = contract(R[i+1], mps[i])
optimize_site(i)                 # Using L[i-1] and R[i]
```

## Environments in Other Algorithms

### DMRG (Density Matrix Renormalization Group)

Environments are **central** to DMRG:
- Left environment = "system block"
- Right environment = "environment block"
- Optimization tensor = "superblock"

The method sweeps back and forth, updating environments to reflect the optimized MPS.

### MPO-MPS Contraction

When applying an MPO to an MPS:

```
     ╭─┬─┬─┬─╮
     │ │ │ │ │   MPO
─A[1]─A[2]─A[3]─...─A[N]─   MPS
```

Left environment at site i contains:
- MPS tensor (bra)
- MPO tensor
- MPS tensor (ket)

For all sites 1 to i-1.

### Time Evolution (TEBD)

During time evolution, environments can be used to:
- Compute local observables efficiently
- Implement variational time evolution
- Control truncation errors during evolution

## Visual Summary

### Environment Partitioning

```
        Site i under study
              ↓
─ [L env] ── [i] ── [R env] ─
    ↑                  ↑
All tensors        All tensors
left of i          right of i
```

### Density Matrix Construction

```
Left Env (L[i])        Right Env (R[i+1])
      ↓                       ↓
   ╭──┴──╮                 ╭──┴──╮
   │  ⟨ψ| ── A*[i] ────── |ψ⟩  │
   │     │     │ │         │     │
   │  |ψ⟩ ──  A[i] ────── ⟨ψ|  │
   ╰──┬──╯                 ╰──┬──╯
      └──────── ρ[i] ─────────┘
```

The density matrix ρ[i] captures **all** quantum correlations!

## Practical Implications for TreeContractor.jl

### Current Implementation

In `contract_with_mps` (src/mps.jl:185):
```julia
for (i, tensor) in enumerate(tensors)
    mps = apply_tensor!(mps, tensor, ...)

    if maximum(size.(mps.tensors, 1)) > maxdim
        compress!(FullCompress(), mps; maxdim)  # Uses environments!
    end
end
```

### Why FullCompress Uses Environments

The FullCompress algorithm (src/compress.jl:146) **must** use environments because:

1. **Optimal truncation requires global information**
   - Can't determine best truncation from local data alone
   - Need to know how site `i` is entangled with rest of system

2. **Schmidt decomposition needs both sides**
   - Left environment = reduced density matrix from left partition
   - Right environment = reduced density matrix from right partition
   - Together they define the Schmidt basis

3. **Precision guarantee**
   - Without environments: truncation is heuristic
   - With environments: truncation minimizes ||ψ - ψ_truncated||²

### Performance Trade-off

| Aspect | LocalCompress | FullCompress |
|--------|---------------|--------------|
| Environment construction | None | O(N χ²) |
| Environment storage | O(1) | O(N χ²) |
| Truncation quality | Approximate | Optimal |
| Speed | Fast | Slower |
| Use case | Intermediate steps | Final compression |

## Key Takeaways

1. **Environment tensors** = cached partial contractions of the tensor network

2. **Left/Right environments** partition the network around a site of interest

3. **Why they matter**:
   - Enable efficient local operations on global states
   - Provide global context for variational optimization
   - Enable optimal truncation via density matrix formulation
   - Reduce computational cost from O(N) to O(1) per query

4. **In TreeContractor.jl**:
   - `LocalCompress`: No environments, local SVD, fast but approximate
   - `FullCompress`: Uses left environments explicitly, optimal truncation, slower

5. **General principle**: When you need **global optimality** (DMRG, variational methods, optimal compression), you **need environments**. When you just need **quick approximate cleanup**, local methods suffice.

## References

1. **TeNPy Lecture Notes**: "Tensor Network Python" - SciPost Phys. Lect. Notes 5 (2018)
   - Detailed discussion of environment construction and updates

2. **TensorNetwork.org**:
   - MPS algorithms: https://tensornetwork.org/mps/algorithms/
   - Density matrix MPO-MPS: https://tensornetwork.org/mps/algorithms/denmat_mpo_mps/

3. **TreeContractor.jl Source Code**:
   - `src/compress.jl:146-179`: FullCompress implementation showing environment construction
   - `src/compress.jl:88-93`: Dot product showing environment-like progressive contraction

4. **Key insight from variational methods**:
   > "The environment represents everything the optimization site 'sees' -
   > it encodes all quantum entanglement with the rest of the system."

---

**Summary**: Environment tensors are the key to efficient, accurate tensor network algorithms. They enable local operations on global quantum states by caching network contractions, and they provide the global information necessary for optimal variational optimization and compression.
