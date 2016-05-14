@testset "Pipeline" begin
    @test eltype(Pipeline) <: ImageOperation
end

@testset "LinearPipeline" begin
    @test LinearPipeline <: Pipeline
    @test eltype(LinearPipeline) <: ImageOperation

    @testset "constructor" begin
        pl = LinearPipeline()
        @test length(pl.operations) == 0

        pl = LinearPipeline([FlipX(), FlipY()])
        @test length(pl.operations) == 2
        @test typeof(pl.operations[1]) <: FlipX
        @test typeof(pl.operations[2]) <: FlipY

        pl = LinearPipeline(FlipY(), FlipX(), Resize(32,32))
        @test length(pl.operations) == 3
        @test typeof(pl.operations[1]) <: FlipY
        @test typeof(pl.operations[2]) <: FlipX
        @test typeof(pl.operations[3]) <: Resize
    end

    @testset "collection interface" begin
        pl = LinearPipeline()
        @test push!(pl, FlipY()) == pl
        @test length(pl.operations) == length(pl) == 1
        @test typeof(pl.operations[1]) <: FlipY
        @test typeof(pl[1]) <: FlipY

        @test push!(pl, FlipX()) == pl
        @test length(pl.operations) == length(pl) == 2
        @test typeof(pl.operations[1]) <: FlipY
        @test typeof(pl[1]) <: FlipY
        @test typeof(pl.operations[2]) <: FlipX
        @test typeof(pl[2]) <: FlipX
        Base.show(pl)

        @test push!(pl, Resize(32, 32)) == pl
        @test length(pl.operations) == length(pl) == 3
        @test typeof(pl.operations[1]) <: FlipY
        @test typeof(pl[1]) <: FlipY
        @test typeof(pl.operations[2]) <: FlipX
        @test typeof(pl[2]) <: FlipX
        @test typeof(pl.operations[3]) <: Resize
        @test typeof(pl[3]) <: Resize

        @test deleteat!(pl, 2) == pl
        @test length(pl.operations) == length(pl) == 2
        @test typeof(pl.operations[1]) <: FlipY
        @test typeof(pl[1]) <: FlipY
        @test typeof(pl.operations[2]) <: Resize
        @test typeof(pl[2]) <: Resize

        @test insert!(pl, 1, FlipX()) == pl
        @test length(pl.operations) == length(pl) == 3
        @test typeof(pl.operations[1]) <: FlipX
        @test typeof(pl[1]) <: FlipX
        @test typeof(pl.operations[2]) <: FlipY
        @test typeof(pl[2]) <: FlipY
        @test typeof(pl.operations[3]) <: Resize
        @test typeof(pl[3]) <: Resize

        @test append!(pl, [FlipY(), FlipX()]) == pl
        @test length(pl.operations) == length(pl) == 5
        @test typeof(pl.operations[1]) <: FlipX
        @test typeof(pl[1]) <: FlipX
        @test typeof(pl.operations[2]) <: FlipY
        @test typeof(pl[2]) <: FlipY
        @test typeof(pl.operations[3]) <: Resize
        @test typeof(pl[3]) <: Resize
        @test typeof(pl.operations[4]) <: FlipY
        @test typeof(pl[4]) <: FlipY
        @test typeof(pl.operations[5]) <: FlipX
        @test typeof(pl[5]) <: FlipX

        @test append!(pl, LinearPipeline([FlipY(), FlipX()])) == pl
        @test length(pl.operations) == length(pl) == 7
        @test typeof(pl[1]) <: FlipX
        @test typeof(pl[2]) <: FlipY
        @test typeof(pl[3]) <: Resize
        @test typeof(pl[4]) <: FlipY
        @test typeof(pl[5]) <: FlipX
        @test typeof(pl[6]) <: FlipY
        @test typeof(pl[7]) <: FlipX
        @test typeof(pl[end]) <: FlipX
    end

    @testset "iterator interface" begin
        count = 0
        pl = LinearPipeline([FlipX(), FlipY(), Resize(32,32)])
        for op in pl
            count += 1
            if count == 1
                @test typeof(op) <: FlipX
            elseif count == 2
                @test typeof(op) <: FlipY
            elseif count == 3
                @test typeof(op) <: Resize
            end
        end
        @test count == 3
    end

    @testset "concrete pipeline and image" begin
        pl = LinearPipeline([FlipX(), FlipY(), CropRatio(1.5), Resize(64,64)])
        @imagetest "LinearPipeline" transform(pl, testimg)
    end
end
