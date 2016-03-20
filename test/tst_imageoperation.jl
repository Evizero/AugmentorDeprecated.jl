A = UInt8[200 150; 50 1]
img = grayim(A)
img2 = grayim(A+10)

@testset "ImageOperation" begin
    @test_throws ArgumentError multiplier(FaultyOp())
end

@testset "FlipX" begin
    @test FlipX <: ImageOperation
    op = FlipX()
    @test multiplier(op) == 2
    @test typeof(op) <: FlipX
    op = FlipX(0.7)
    @test multiplier(op) == 2
    @test typeof(op) <: Augmentor.ProbableOperation
    @test op.chance == 0.7
    @test transform(FlipX(0), img) == img
    @test transform(FlipX(1), img) == flipdim(img, "x")
end

@testset "FlipY" begin
    @test FlipY <: ImageOperation
    op = FlipY()
    @test multiplier(op) == 2
    @test typeof(op) <: FlipY
    op = FlipY(0.7)
    @test multiplier(op) == 2
    @test typeof(op) <: Augmentor.ProbableOperation
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

@testset "Tuple of Image" begin
    imgs = (img, img2)
    op = FlipX()
    out1, out2 = transform(op, imgs)
    @test out1 == flipx(img)
    @test out2 == flipx(img2)
    op = FlipX(1)
    out1, out2 = transform(op, imgs)
    @test out1 == flipx(img)
    @test out2 == flipx(img2)
end

