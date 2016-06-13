A = UInt8[200 150; 50 1]
img = grayim(A)
img2 = grayim(A+10)

@testset "ImageOperation" begin
    @test_throws ArgumentError multiplier(FaultyOp())
end

@testset "FlipX" begin
    @test FlipX <: ImageOperation
    op = FlipX()
    show(op); println()
    @test multiplier(op) == 1
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
    show(op); println()
    @test multiplier(op) == 1
    @test typeof(op) <: FlipY
    op = FlipY(0.7)
    show(op); println()
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
    show(op); println()
    @test multiplier(op) == 1
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
    show(op); println()
    @test multiplier(op) == 1
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
    show(op); println()
    @test multiplier(op) == 1
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
    show(op); println()
    @test op.width == 64
    @test op.height == 64
    op = Resize(width = 23, height = 12)
    @test op.width == 23
    @test op.height == 12
    @test size(transform(op, img)) == (23, 12)
    @imagetest "Resize" transform(Resize(160, 80), testimg)
    @imagetest "Resize_y" permutedims(transform(Resize(160, 80), permutedims(testimg, [2, 1])), [2, 1])
end

@testset "CropRatio" begin
    @test CropRatio <: ImageOperation
    @test multiplier(CropRatio()) == 1
    op = CropRatio(1//2)
    show(op); println()
    @test op.ratio == .5
    op = CropRatio(1/2)
    @test op.ratio == .5
    op = CropRatio(ratio = 1)
    @test op.ratio == 1.
    op = CropRatio(1)
    @test op.ratio == 1.

    @test transform(CropRatio(1), img) == img
    img_1 = grayim(rand(UInt8, 50, 20))
    @test size(transform(op, img_1)) == (20, 20)
    img_2 = grayim(rand(UInt8, 10, 20))
    @test size(transform(op, img_2)) == (10, 10)
    @imagetest "CropRatio" transform(CropRatio(2.), testimg)
end

@testset "CropSize" begin
    @test CropSize <: ImageOperation
    @test multiplier(CropSize()) == 1
    op = CropSize(2, 3)
    show(op); println()
    @test op.width == 2
    @test op.height == 3
    op = CropSize(width = 4, height = 5)
    @test op.width == 4
    @test op.height == 5
    op = CropSize()
    @test op.width == 64
    @test op.height == 64

    op = CropSize(20, 10)
    img_1 = grayim(rand(UInt8, 50, 20))
    @test size(transform(op, img_1)) == (20, 10)
    img_2 = grayim(rand(UInt8, 30, 40))
    @test size(transform(op, img_2)) == (20, 10)
    @imagetest "CropSize" transform(CropSize(64, 32), testimg)
end

@testset "Crop" begin
    @test Crop <: ImageOperation
    @test multiplier(Crop()) == 1
    op = Crop(1, 2, 3, 4)
    show(op); println()
    @test op.x == 1
    @test op.y == 2
    @test op.width == 3
    @test op.height == 4
    op = Crop(x = 2, y = 3, width = 4, height = 5)
    @test op.x == 2
    @test op.y == 3
    @test op.width == 4
    @test op.height == 5
    op = Crop()
    @test op.x == 1
    @test op.y == 1
    @test op.width == 64
    @test op.height == 64

    op = Crop(10, 5, 20, 10)
    img_1 = grayim(rand(UInt8, 50, 20))
    @test size(transform(op, img_1)) == (20, 10)
    img_2 = grayim(rand(UInt8, 30, 40))
    @test size(transform(op, img_2)) == (20, 10)
    @imagetest "Crop" transform(Crop(45, 10, 64, 32), testimg)
end

@testset "Zoom" begin
    @test Zoom <: ImageOperation
    @test multiplier(Zoom()) == 1
    op = Zoom(1//2)
    show(op); println()
    @test op.factor == .5
    op = Zoom(1/2)
    @test op.factor == .5
    op = Zoom(factor = 1)
    @test op.factor == 1.
    op = Zoom(1)
    @test op.factor == 1.

    @imagetest "Zoom08" transform(Zoom(0.8), testimg)
    @imagetest "Zoom12" transform(Zoom(1.2), testimg)
end

@testset "Scale" begin
    @test Scale <: ImageOperation
    @test multiplier(Scale()) == 1
    op = Scale(2, .5)
    show(op); println()
    @test op.width == 2
    @test op.height == .5
    op = Scale()
    @test op.width == 1
    @test op.height == 1
    op = Scale(width = 2)
    @test op.width == 2
    @test op.height == 1
    op = Scale(height = 2)
    @test op.width == 1
    @test op.height == 2
    op = Scale(width = 1.5, height = 0.5)
    @test op.width == 1.5
    @test op.height == 0.5

    @imagetest "Scale_x" transform(Scale(0.8, 1.2), testimg)
    @imagetest "Scale_y" permutedims(transform(Scale(0.8, 1.2), permutedims(testimg, [2, 1])), [2, 1])
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

