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
    @imagetest "FlipX" transform(FlipX(), testimg)
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
    @imagetest "FlipY" transform(FlipY(), testimg)
end

@testset "Rotate90" begin
    @test Rotate90 <: ImageOperation
    op = Rotate90()
    @test multiplier(op) == 2
    @test typeof(op) <: Rotate90
    op = Rotate90(0.7)
    @test multiplier(op) == 2
    @test typeof(op) <: Augmentor.ProbableOperation
    @test op.chance == 0.7
    @test transform(Rotate90(0), img) == img
    @test transform(Rotate90(1), img) == rotate_expand(img, deg2rad(90))
    @imagetest "Rotate90" transform(Rotate90(), testimg)
end

@testset "Rotate180" begin
    @test Rotate180 <: ImageOperation
    op = Rotate180()
    @test multiplier(op) == 2
    @test typeof(op) <: Rotate180
    op = Rotate180(0.7)
    @test multiplier(op) == 2
    @test typeof(op) <: Augmentor.ProbableOperation
    @test op.chance == 0.7
    @test transform(Rotate180(0), img) == img
    @test transform(Rotate180(1), img) == rotate_expand(img, deg2rad(180))
    @imagetest "Rotate180" transform(Rotate180(), testimg)
end

@testset "Rotate270" begin
    @test Rotate270 <: ImageOperation
    op = Rotate270()
    @test multiplier(op) == 2
    @test typeof(op) <: Rotate270
    op = Rotate270(0.7)
    @test multiplier(op) == 2
    @test typeof(op) <: Augmentor.ProbableOperation
    @test op.chance == 0.7
    @test transform(Rotate270(0), img) == img
    @test transform(Rotate270(1), img) == rotate_expand(img, deg2rad(270))
    @imagetest "Rotate270" transform(Rotate270(), testimg)
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
    @imagetest "Resize" transform(Resize(160, 80), testimg)
end

@testset "CropRatio" begin
    @test CropRatio <: ImageOperation
    @test multiplier(CropRatio()) == 1
    op = CropRatio(1/2)
    @test op.ratio == .5
    op = CropRatio(1)
    @test op.ratio == 1.

    img_1 = grayim(rand(UInt8, 50, 20))
    @test size(transform(op, img_1)) == (20, 20)
    img_2 = grayim(rand(UInt8, 10, 20))
    @test size(transform(op, img_2)) == (10, 10)
    @imagetest "CropRatio" transform(CropRatio(2.), testimg)
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

