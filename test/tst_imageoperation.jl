A = UInt8[200 150; 50 1]
img = grayim(A)

@testset "ImageOperation" begin
    @test_throws ArgumentError multiplier(FaultyOp())
end

@testset "FlipX" begin
    @test FlipX <: ImageOperation
    @test multiplier(FlipX()) == 2
    op = FlipX()
    @test op.chance == 0.5
    op = FlipX(0.7)
    @test op.chance == 0.7
    @test transform(FlipX(0), img) == img
    @test transform(FlipX(1), img) == flipdim(img, "x")
end

@testset "FlipY" begin
    @test FlipY <: ImageOperation
    @test multiplier(FlipY()) == 2
    op = FlipY()
    @test op.chance == 0.5
    op = FlipY(0.7)
    @test op.chance == 0.7
    @test transform(FlipY(0), img) == img
    @test transform(FlipY(1), img) == flipdim(img, "y")
end

@testset "Resize" begin
    @test Resize <: ImageOperation
    @test multiplier(Resize()) == 1
    op = Resize()
    @test op.width == 64
    @test op.height == 64
    op = Resize(width = 23, height = 12)
    @test op.width == 23
    @test op.height == 12
    @test size(transform(op, img)) == (23, 12)
end

