using TreeContractor
using TensorQEC
using TreeContractor.OMEinsum
using Profile

"""
Profile contract_with_mps_contractor to identify performance bottlenecks
"""
function profile_contractor()
    println("=" ^ 80)
    println("Profiling contract_with_mps_contractor")
    println("=" ^ 80)
    
    # Load QEC problem
    dem = TensorQEC.parse_dem_file("examples/data/surface_code_d=3_r=3.dem")
    ct2 = compile(TNMMAP(OMEinsum.PathSA(), true), dem)
    
    println("Problem: Surface code d=3, r=3")
    println("Contraction complexity: ", contraction_complexity(ct2.code, uniformsize(ct2.code, 2)))
    println()
    
    # Warm up
    println("Warming up...")
    contract_with_mps_contractor(ct2.code, ct2.tensors, uniformsize(ct2.code, 2); maxdim=2, compress_mode=TreeContractor.FullCompress())
    
    println("Starting profile (collecting samples)...")
    println()
    
    # Profile the function
    Profile.clear()
    @profile contract_with_mps_contractor(ct2.code, ct2.tensors, uniformsize(ct2.code, 2); maxdim=2, compress_mode=TreeContractor.FullCompress())
    
    # Display results
    println("Profile results (top 30 functions by sample count):")
    println("=" ^ 80)
    Profile.print(format=:flat, sortedby=:count, maxdepth=30, mincount=1)
    
    println()
    println("=" ^ 80)
    println("Timing analysis")
    println("=" ^ 80)
    
    # Simple timing
    times = Float64[]
    for i in 1:3
        t = @elapsed contract_with_mps_contractor(ct2.code, ct2.tensors, uniformsize(ct2.code, 2); maxdim=20, compress_mode=TreeContractor.FullCompress())
        push!(times, t)
    end
    avg_time = sum(times) / length(times)
    println("Average time: $(round(avg_time, digits=4)) seconds")
    println("Min time: $(round(minimum(times), digits=4)) seconds")
    println("Max time: $(round(maximum(times), digits=4)) seconds")
    
    return times
end

if abspath(PROGRAM_FILE) == @__FILE__
    profile_contractor()
end

