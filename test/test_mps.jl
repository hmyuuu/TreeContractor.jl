@testset "MPS Basic Operations" begin
    @testset "tensor2mps and contract_mps" begin
        ashape = (6, 3, 4, 5)
        a = rand(Float64, ashape)
        b, bd_vec = TreeContractor.tensor2mps(a)
        bd = 1
        @test bd_vec[1] == 1
        for (i,s) in enumerate(ashape)
            bdnew = size(b[i])[3]
            @test size(b[i]) == (bd, s, bdnew)
            bd = bdnew
            @test bd_vec[i+1] == bdnew
        end
        @test TreeContractor.contract_mps(b)[] ≈ sum(a) atol = 1e-10
    end

    @testset "delta_mps" begin
        a = TreeContractor.delta_mps(2,3,Float64)
        @test a[:,1,:] == I(2)
        @test a[:,2,:] == I(2)
        @test a[:,3,:] == I(2)
    end

    @testset "apply_rank_3_tensor" begin
        Random.seed!(1234)
        t1 = rand(2,2,2)
        t2 = rand(2,2,2)
        t3 = rand(2,2,2)
        t4 = rand(2,2,2)

        m = ein"bfc,efg,cad,gah->bedh"(t1,t2,t3,t4)
        m = reshape(m, 2*2,2*2)

        m1 = TreeContractor.apply_rank_3_tensor(t1,t2)
        m2 = TreeContractor.apply_rank_3_tensor(t3,t4)
        mp = ein"bfc,cad-> bd"(m1,m2)
        @test m ≈ mp atol = 1e-10
    end
end

