@testset "Pipeline" begin
    @test eltype(Pipeline) <: ImageTransformation
end

@testset "LinearPipeline" begin
    @testset "concrete pipeline and image" begin
        pl = [FlipX(), FlipY(), CropRatio(1.5), Resize(64,64)]
        @imagetest "LinearPipeline" transform(pl, testimg)

        testimgs = Array{Image,1}()
        push!(testimgs, testimg)
        push!(testimgs, testimg)
        imgs = transform(pl, testimgs)
        @imagetest "LinearPipeline" imgs[1]
        @imagetest "LinearPipeline" imgs[2]
    end
end
