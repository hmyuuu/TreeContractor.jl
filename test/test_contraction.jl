@testset "Tensor Network Contraction" begin
    @testset "contract_with_mps - simple" begin
        code = ein"abc,abd->"
        optcode = optimize_code(code, uniformsize(code, 2), OMEinsum.PathSA())

        Random.seed!(1234)
        t1 = rand(2,2,2)
        t2 = rand(2,2,2)

        tensors = [t1, t2]
        right_answer = optcode(t1, t2)[]

        @test contract_with_mps(optcode, tensors, uniformsize(code, 2))[1][] ≈ right_answer atol = 1e-10
    end

    @testset "contract_with_mps - different sizes" begin
        code = ein"ac,bd,ab,cd->"
        size_dict = Dict('a' => 2, 'b' => 3, 'c' => 4, 'd' => 5)
        optcode = optimize_code(code, size_dict, OMEinsum.PathSA())

        Random.seed!(1234)
        t1 = rand(2,4)
        t2 = rand(3,5)
        t3 = rand(2,3)
        t4 = rand(4,5)

        tensors = [t1, t2, t3, t4]
        right_answer = optcode(tensors...)[]

        @test contract_with_mps(optcode, tensors, size_dict)[1][] ≈ right_answer atol = 1e-10
    end

    @testset "contract_with_mps - chain" begin
        code = ein"abc,cde,egh,fbg->"
        optcode = optimize_code(code, uniformsize(code, 2), OMEinsum.PathSA())

        Random.seed!(1234)
        t1 = rand(2,2,2)
        t2 = rand(2,2,2)
        t3 = rand(2,2,2)
        t4 = rand(2,2,2)
        
        tensors = [t1, t2, t3, t4]
        right_answer = optcode(tensors...)[]

        mps, apply_vec, tensor_labels, vanish_labels_vec = TreeContractor.code2mps(optcode,uniformsize(code, 2))
        mps = TreeContractor.apply_tensors!(mps, apply_vec, tensors, tensor_labels, vanish_labels_vec)

        @test contract_with_mps(optcode, tensors, uniformsize(code, 2))[1][] ≈ right_answer atol = 1e-10
    end

    @testset "contract_with_mps - with maxdim" begin
        code = ein"abc,cde,egh,fbg,yczd,ybzc->"
        bd = 3
        optcode = optimize_code(code, uniformsize(code, bd), OMEinsum.PathSA())

        Random.seed!(1234)
        t1 = rand(bd,bd,bd)
        t2 = rand(bd,bd,bd)
        t3 = rand(bd,bd,bd)
        t4 = rand(bd,bd,bd)
        t5 = rand(bd,bd,bd,bd)
        t6 = rand(bd,bd,bd,bd)

        tensors = [t1, t2, t3, t4, t5, t6]
        right_answer = optcode(tensors...)[]

        @test contract_with_mps(optcode, tensors, uniformsize(code, bd); maxdim = 10)[1][] ≈ right_answer atol = 1e-10
    end

    @testset "tensor with output label" begin
        code = ein"abc,cde,egh,fbg->f"
        bd = 5
        optcode = optimize_code(code, uniformsize(code, bd), OMEinsum.PathSA())

        Random.seed!(1234)
        t1 = rand(bd,bd,bd)
        t2 = rand(bd,bd,bd)
        t3 = rand(bd,bd,bd)
        t4 = rand(bd,bd,bd)
        
        tensors = [t1, t2, t3, t4]
        right_answer = optcode(tensors...)

        @test contract_with_mps(optcode, tensors, uniformsize(code, bd); maxdim = 10)[1][1,:,1] ≈ right_answer atol = 1e-10
    end
end

