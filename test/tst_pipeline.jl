@testset "Pipeline" begin
    @test eltype(Pipeline) <: ImageTransformation
end

@testset "LinearPipeline" begin
    @test LinearPipeline <: Pipeline
    @test eltype(LinearPipeline) <: ImageTransformation

    @testset "constructor" begin
        pl = LinearPipeline()
        @test length(pl.transformations) == 0

        pl = LinearPipeline([FlipX(), FlipY()])
        @test length(pl.transformations) == 2
        @test typeof(pl.transformations[1]) <: FlipX
        @test typeof(pl.transformations[2]) <: FlipY

        pl = LinearPipeline(FlipY(), FlipX(), Resize(32,32))
        @test length(pl.transformations) == 3
        @test typeof(pl.transformations[1]) <: FlipY
        @test typeof(pl.transformations[2]) <: FlipX
        @test typeof(pl.transformations[3]) <: Resize
    end

    @testset "collection interface" begin
        pl = LinearPipeline()
        @test push!(pl, FlipY()) == pl
        @test length(pl.transformations) == length(pl) == 1
        @test typeof(pl.transformations[1]) <: FlipY
        @test typeof(pl[1]) <: FlipY

        @test push!(pl, FlipX()) == pl
        @test length(pl.transformations) == length(pl) == 2
        @test typeof(pl.transformations[1]) <: FlipY
        @test typeof(pl[1]) <: FlipY
        @test typeof(pl.transformations[2]) <: FlipX
        @test typeof(pl[2]) <: FlipX
        Base.show(pl)
        println()

        @test push!(pl, Resize(32, 32)) == pl
        @test length(pl.transformations) == length(pl) == 3
        @test typeof(pl.transformations[1]) <: FlipY
        @test typeof(pl[1]) <: FlipY
        @test typeof(pl.transformations[2]) <: FlipX
        @test typeof(pl[2]) <: FlipX
        @test typeof(pl.transformations[3]) <: Resize
        @test typeof(pl[3]) <: Resize

        @test deleteat!(pl, 2) == pl
        @test length(pl.transformations) == length(pl) == 2
        @test typeof(pl.transformations[1]) <: FlipY
        @test typeof(pl[1]) <: FlipY
        @test typeof(pl.transformations[2]) <: Resize
        @test typeof(pl[2]) <: Resize

        @test insert!(pl, 1, FlipX()) == pl
        @test length(pl.transformations) == length(pl) == 3
        @test typeof(pl.transformations[1]) <: FlipX
        @test typeof(pl[1]) <: FlipX
        @test typeof(pl.transformations[2]) <: FlipY
        @test typeof(pl[2]) <: FlipY
        @test typeof(pl.transformations[3]) <: Resize
        @test typeof(pl[3]) <: Resize

        @test append!(pl, [FlipY(), FlipX()]) == pl
        @test length(pl.transformations) == length(pl) == 5
        @test typeof(pl.transformations[1]) <: FlipX
        @test typeof(pl[1]) <: FlipX
        @test typeof(pl.transformations[2]) <: FlipY
        @test typeof(pl[2]) <: FlipY
        @test typeof(pl.transformations[3]) <: Resize
        @test typeof(pl[3]) <: Resize
        @test typeof(pl.transformations[4]) <: FlipY
        @test typeof(pl[4]) <: FlipY
        @test typeof(pl.transformations[5]) <: FlipX
        @test typeof(pl[5]) <: FlipX

        @test append!(pl, LinearPipeline([FlipY(), FlipX()])) == pl
        @test length(pl.transformations) == length(pl) == 7
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

        testimgs = Array{Image,1}()
        push!(testimgs, testimg)
        push!(testimgs, testimg)
        imgs = transform(pl, testimgs)
        @imagetest "LinearPipeline" imgs[1]
        @imagetest "LinearPipeline" imgs[2]
    end
end
