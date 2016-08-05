A = UInt8[200 150; 50 1]
img = grayim(A)
img2 = grayim(A+10)
B = UInt8[200 150 100; 80 50 10; 5 3 0]
img3 = grayim(B)

@testset "ImageOperation" begin
    @test_throws ArgumentError multiplier(FaultyOp())
end

@testset "NoOp" begin
    @test NoOp <: ImageOperation
    op = NoOp()
    show(op); println()
    showcompact(op); println()
    @test multiplier(op) == 1
    @test typeof(op) <: NoOp
    @test transform(NoOp(), img) == img
    @test transform(NoOp(), img2) == img2
    @test transform(NoOp(), img3) == img3
end

@testset "FlipX" begin
    @test FlipX <: ImageOperation
    op = FlipX()
    show(op); println()
    showcompact(op); println()
    @test multiplier(op) == 1
    @test typeof(op) <: FlipX
    op = FlipX(0.7)
    @test multiplier(op) == 2
    @test typeof(op) <: Either
    @test_approx_eq op.chance [0.7, .3]
    @test typeof(last(transform(FlipX(), img)["operations"])) <: FlipX
    @test transform(FlipX(0), img) == img
    @test transform(FlipX(1), img) == flipdim(img, "x")
    @imagetest "FlipX" transform(FlipX(), testimg)
end

@testset "FlipY" begin
    @test FlipY <: ImageOperation
    op = FlipY()
    show(op); println()
    showcompact(op); println()
    @test multiplier(op) == 1
    @test typeof(op) <: FlipY
    op = FlipY(0.7)
    show(op); println()
    showcompact(op); println()
    @test multiplier(op) == 2
    @test typeof(op) <: Either
    @test_approx_eq op.chance [0.7, .3]
    @test typeof(last(transform(FlipY(), img)["operations"])) <: FlipY
    @test transform(FlipY(0), img) == img
    @test transform(FlipY(1), img) == flipdim(img, "y")
    @imagetest "FlipY" transform(FlipY(), testimg)
end

@testset "Rotate90" begin
    @test Rotate90 <: ImageOperation
    op = Rotate90()
    show(op); println()
    showcompact(op); println()
    @test multiplier(op) == 1
    @test typeof(op) <: Rotate90
    op = Rotate90(0.7)
    @test multiplier(op) == 2
    @test typeof(op) <: Either
    @test_approx_eq op.chance [0.7, .3]
    @test typeof(last(transform(Rotate90(), img)["operations"])) <: Rotate90
    @test transform(Rotate90(0), img) == img
    @test transform(Rotate90(1), img) == rotate_expand(img, deg2rad(90))
    @imagetest "Rotate90" transform(Rotate90(), testimg)
end

@testset "Rotate180" begin
    @test Rotate180 <: ImageOperation
    op = Rotate180()
    show(op); println()
    showcompact(op); println()
    @test multiplier(op) == 1
    @test typeof(op) <: Rotate180
    op = Rotate180(0.7)
    @test multiplier(op) == 2
    @test typeof(op) <: Either
    @test_approx_eq op.chance [0.7, .3]
    @test typeof(last(transform(Rotate180(), img)["operations"])) <: Rotate180
    @test transform(Rotate180(0), img) == img
    @test transform(Rotate180(1), img) == rotate_expand(img, deg2rad(180))
    @imagetest "Rotate180" transform(Rotate180(), testimg)
end

@testset "Rotate270" begin
    @test Rotate270 <: ImageOperation
    op = Rotate270()
    show(op); println()
    showcompact(op); println()
    @test multiplier(op) == 1
    @test typeof(op) <: Rotate270
    op = Rotate270(0.7)
    @test multiplier(op) == 2
    @test typeof(op) <: Either
    @test_approx_eq op.chance [0.7, .3]
    @test typeof(last(transform(Rotate270(), img)["operations"])) <: Rotate270
    @test transform(Rotate270(0), img) == img
    @test transform(Rotate270(1), img) == rotate_expand(img, deg2rad(270))
    @imagetest "Rotate270" transform(Rotate270(), testimg)
end

@testset "Resize" begin
    @test Resize <: ImageOperation
    @test multiplier(Resize()) == 1
    op = Resize()
    show(op); println()
    showcompact(op); println()
    @test op.width == 64
    @test op.height == 64
    op = Resize(width = 23, height = 12)
    @test op.width == 23
    @test op.height == 12
    @test typeof(last(transform(Resize(), img)["operations"])) <: Resize
    @test size(transform(op, img)) == (23, 12)
    @imagetest "Resize" transform(Resize(160, 80), testimg)
    @imagetest "Resize_y" permutedims(transform(Resize(160, 80), permutedims(testimg, [2, 1])), [2, 1])
end

@testset "CropRatio" begin
    @test CropRatio <: ImageOperation
    @test multiplier(CropRatio()) == 1
    op = CropRatio(1//2)
    show(op); println()
    showcompact(op); println()
    @test op.ratio == .5
    op = CropRatio(1/2)
    @test op.ratio == .5
    op = CropRatio(ratio = 1)
    @test op.ratio == 1.
    op = CropRatio(1)
    @test op.ratio == 1.
    @test typeof(last(transform(CropRatio(), img)["operations"])) <: CropRatio

    @test_throws ArgumentError transform(CropRatio(0.), img)
    @test_throws ArgumentError transform(CropRatio(-1.), img)

    @test transform(CropRatio(1), img)  == img
    @test transform(CropRatio(2), img)  == img[:, 1:1]
    @test transform(CropRatio(10), img) == img[:, 1:1]
    @test transform(CropRatio(.5), img) == img[1:1, :]
    @test transform(CropRatio(.1), img) == img[1:1, :]

    @test transform(CropRatio(1), img3)  == img3
    @test transform(CropRatio(2), img3)  == img3[:, 2:2]
    @test transform(CropRatio(10), img3) == img3[:, 2:2]
    @test transform(CropRatio(.5), img3) == img3[2:2, :]
    @test transform(CropRatio(.1), img3) == img3[2:2, :]

    img_1 = grayim(rand(UInt8, 50, 20))
    @test size(transform(op, img_1)) == (20, 20)
    img_2 = grayim(rand(UInt8, 10, 20))
    @test size(transform(op, img_2)) == (10, 10)
    @imagetest "CropRatio2to1" transform(CropRatio(2.), testimg)
    @imagetest "CropRatio1to2" transform(CropRatio(.5), testimg)
end

@testset "CropSize" begin
    @test CropSize <: ImageOperation
    @test multiplier(CropSize()) == 1
    op = CropSize(2, 3)
    show(op); println()
    showcompact(op); println()
    @test op.width == 2
    @test op.height == 3
    op = CropSize(width = 4, height = 5)
    @test op.width == 4
    @test op.height == 5
    op = CropSize()
    @test op.width == 64
    @test op.height == 64
    @test typeof(last(transform(CropSize(1,1), img)["operations"])) <: CropSize

    @test_throws ArgumentError transform(CropSize(3,2), img)
    @test_throws ArgumentError transform(CropSize(2,3), img)
    @test_throws ArgumentError transform(CropSize(0,2), img)
    @test_throws ArgumentError transform(CropSize(2,0), img)
    @test_throws ArgumentError transform(CropSize(-1,2), img)
    @test_throws ArgumentError transform(CropSize(2,-1), img)

    @test transform(CropSize(2,2), img)  == img
    @test transform(CropSize(1,1), img)  == img[2:2, 2:2]
    @test transform(CropSize(3,3), img3) == img3
    @test transform(CropSize(1,3), img3) == img3[2:2, :]
    @test transform(CropSize(3,1), img3) == img3[:, 2:2]
    @test transform(CropSize(2,2), img3) == img3[1:2, 1:2]
    @test transform(CropSize(1,1), img3) == img3[2:2, 2:2]

    op = CropSize(20, 10)
    img_1 = grayim(rand(UInt8, 50, 20))
    @test size(transform(op, img_1)) == (20, 10)
    img_2 = grayim(rand(UInt8, 30, 40))
    @test size(transform(op, img_2)) == (20, 10)
    @imagetest "CropSize" transform(CropSize(64, 32), testimg)
end

@testset "RCropSize" begin
    @test RCropSize <: ImageOperation
    @test multiplier(RCropSize()) == 1
    op = RCropSize(2, 3)
    show(op); println()
    showcompact(op); println()
    @test op.width == 2
    @test op.height == 3
    op = RCropSize(width = 4, height = 5)
    @test op.width == 4
    @test op.height == 5
    op = RCropSize()
    @test op.width == 64
    @test op.height == 64
    @test typeof(last(transform(RCropSize(1,1), img)["operations"])) <: RCropSize

    @test_throws ArgumentError transform(RCropSize(3,2), img)
    @test_throws ArgumentError transform(RCropSize(2,3), img)
    @test_throws ArgumentError transform(RCropSize(0,2), img)
    @test_throws ArgumentError transform(RCropSize(2,0), img)
    @test_throws ArgumentError transform(RCropSize(-1,2), img)
    @test_throws ArgumentError transform(RCropSize(2,-1), img)

    @test size(transform(RCropSize(1,1), img)) == (1, 1)
    @test size(transform(RCropSize(1,2), img)) == (1, 2)
    @test size(transform(RCropSize(2,1), img)) == (2, 1)
    @test size(transform(RCropSize(2,2), img)) == (2, 2)

    @test size(transform(RCropSize(1,1), img3)) == (1, 1)
    @test size(transform(RCropSize(1,2), img3)) == (1, 2)
    @test size(transform(RCropSize(2,1), img3)) == (2, 1)
    @test size(transform(RCropSize(2,2), img3)) == (2, 2)
    @test size(transform(RCropSize(1,3), img3)) == (1, 3)
    @test size(transform(RCropSize(3,1), img3)) == (3, 1)
    @test size(transform(RCropSize(2,3), img3)) == (2, 3)
    @test size(transform(RCropSize(3,2), img3)) == (3, 2)
    @test size(transform(RCropSize(3,3), img3)) == (3, 3)

    op = RCropSize(20, 10)
    img_1 = grayim(rand(UInt8, 50, 20))
    @test size(transform(op, img_1)) == (20, 10)
    img_2 = grayim(rand(UInt8, 30, 40))
    @test size(transform(op, img_2)) == (20, 10)
end

@testset "RCropRatio" begin
    @test RCropRatio <: ImageOperation
    @test multiplier(RCropRatio()) == 1
    op = RCropRatio(1//2)
    show(op); println()
    showcompact(op); println()
    @test op.ratio == .5
    op = RCropRatio(1/2)
    @test op.ratio == .5
    op = RCropRatio(ratio = 1)
    @test op.ratio == 1.
    op = RCropRatio(1)
    @test op.ratio == 1.
    @test typeof(last(transform(RCropRatio(), img)["operations"])) <: RCropRatio

    @test_throws ArgumentError transform(RCropRatio(0.), img)
    @test_throws ArgumentError transform(RCropRatio(-1.), img)

    @test size(transform(RCropRatio(1), img)) == (2, 2)
    @test size(transform(RCropRatio(2), img)) == (2, 1)
    @test size(transform(RCropRatio(10), img)) == (2, 1)
    @test size(transform(RCropRatio(.5), img)) == (1, 2)
    @test size(transform(RCropRatio(.1), img)) == (1, 2)

    @test size(transform(RCropRatio(1), img3)) == (3, 3)
    @test size(transform(RCropRatio(1.5), img3)) == (3, 2)
    @test size(transform(RCropRatio(2), img3)) == (3, 1)
    @test size(transform(RCropRatio(10), img3)) == (3, 1)
    @test size(transform(RCropRatio(.7), img3)) == (2, 3)
    @test size(transform(RCropRatio(.5), img3)) == (1, 3)
    @test size(transform(RCropRatio(.1), img3)) == (1, 3)

    img_1 = grayim(rand(UInt8, 50, 20))
    @test size(transform(op, img_1)) == (20, 20)
    img_2 = grayim(rand(UInt8, 10, 20))
    @test size(transform(op, img_2)) == (10, 10)
end

@testset "Crop" begin
    @test Crop <: ImageOperation
    @test multiplier(Crop()) == 1
    op = Crop(1, 2, 3, 4)
    show(op); println()
    showcompact(op); println()
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
    @test typeof(last(transform(Crop(1,1,1,1), img)["operations"])) <: Crop

    @test_throws ArgumentError transform(Crop(0,1,1,1), img)
    @test_throws ArgumentError transform(Crop(1,0,1,1), img)
    @test_throws ArgumentError transform(Crop(1,1,0,1), img)
    @test_throws ArgumentError transform(Crop(1,1,1,0), img)
    @test_throws ArgumentError transform(Crop(3,1,1,1), img)
    @test_throws ArgumentError transform(Crop(1,3,1,1), img)
    @test_throws ArgumentError transform(Crop(1,1,3,1), img)
    @test_throws ArgumentError transform(Crop(1,1,1,3), img)

    @test transform(Crop(1,1,1,1), img) == img[1:1, 1:1]
    @test transform(Crop(2,2,1,1), img) == img[2:2, 2:2]
    @test transform(Crop(1,1,2,2), img) == img
    @test transform(Crop(1,1,2,1), img) == img[1:2, 1:1]
    @test transform(Crop(1,1,1,2), img) == img[1:1, 1:2]
    @test transform(Crop(2,2,1,1), img3) == img3[2:2, 2:2]

    op = Crop(10, 5, 20, 10)
    img_1 = grayim(rand(UInt8, 50, 20))
    @test transform(op, img_1) == img_1[10:29, 5:14]
    @test size(transform(op, img_1)) == (20, 10)
    img_2 = grayim(rand(UInt8, 30, 40))
    @test transform(op, img_2) == img_2[10:29, 5:14]
    @test size(transform(op, img_2)) == (20, 10)
    @imagetest "Crop" transform(Crop(45, 10, 64, 32), testimg)
end

@testset "Zoom" begin
    @test Zoom <: ImageOperation
    @test multiplier(Zoom()) == 1
    op = Zoom(1//2)
    show(op); println()
    showcompact(op); println()
    @test op.factor == .5
    op = Zoom(1/2)
    @test op.factor == .5
    op = Zoom(factor = 1)
    @test op.factor == 1.
    op = Zoom(1)
    @test op.factor == 1.
    @test typeof(last(transform(Zoom(), img)["operations"])) <: Zoom

    @imagetest "Zoom08" transform(Zoom(0.8), testimg)
    @imagetest "Zoom12" transform(Zoom(1.2), testimg)
end

@testset "Scale" begin
    @test Scale <: ImageOperation
    @test multiplier(Scale()) == 1
    op = Scale(2, .5)
    show(op); println()
    showcompact(op); println()
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
    @test typeof(last(transform(Scale(), img)["operations"])) <: Scale

    @imagetest "Scale_x" transform(Scale(0.8, 1.2), testimg)
    @imagetest "Scale_y" permutedims(transform(Scale(0.8, 1.2), permutedims(testimg, [2, 1])), [2, 1])
end

@testset "Either" begin
    @test Either <: ImageOperation
    @test_throws ArgumentError Either()
    op = Either(NoOp())
    show(op); println()
    showcompact(op); println()
    @test multiplier(op) == 1
    @test op.operations == [NoOp()]
    @test op.chance == [1.]
    @test op.cum_chance == [1.]
    @test transform(op, img) == img
    op = Either(FlipX(), FlipY())
    @test multiplier(op) == 2
    @test op.operations == [FlipX(), FlipY()]
    @test op.chance == [.5, .5]
    @test op.cum_chance == [.5, 1.]
    op = Either([FlipX(), FlipY()])
    @test op.operations == [FlipX(), FlipY()]
    @test op.chance == [.5, .5]
    @test op.cum_chance == [.5, 1.]
    @test_throws AssertionError Either(FlipX(), FlipY(), chance = [0., 0.])
    @test_throws ArgumentError Either(FlipX(), FlipY(), Rotate90(), chance = [.5, .5])
    op = Either(FlipX(), FlipY(), Rotate90())
    @test multiplier(op) == 3
    @test op.operations == [FlipX(), FlipY(), Rotate90()]
    @test op.chance == [1/3, 1/3, 1/3]
    @test op.cum_chance == [1/3, 2/3, 1.]
    op = Either([FlipX(), FlipY(), Rotate90()])
    @test op.operations == [FlipX(), FlipY(), Rotate90()]
    @test op.chance == [1/3, 1/3, 1/3]
    @test op.cum_chance == [1/3, 2/3, 1.]
    op = Either(FlipX(), FlipY(), Rotate90(), chance = [1., 3, 1])
    @test op.operations == [FlipX(), FlipY(), Rotate90()]
    @test op.chance == [.2, .6, .2]
    @test op.cum_chance == [.2, .8, 1.]
    op = Either(FlipX(), FlipY(), chance = [1., 0.])
    @test multiplier(op) == 1
    @test op.operations == [FlipX(), FlipY()]
    @test op.chance == [1., 0]
    @test op.cum_chance == [1., 1.]
    @test transform(op, deepcopy(img)) == transform(FlipX(), deepcopy(img))
    op = Either(FlipX(), FlipY(), chance = [0., 1.])
    @test multiplier(op) == 1
    @test op.operations == [FlipX(), FlipY()]
    @test op.chance == [0., 1]
    @test op.cum_chance == [0., 1.]
    @test transform(op, deepcopy(img)) == transform(FlipY(), deepcopy(img))
end

@testset "RandomDisplacement" begin
    @test RandomDisplacement <: ImageOperation
    @test multiplier(RandomDisplacement(10,10)) == 1
    op = RandomDisplacement(4,5)
    @test op == RandomDisplacement(4., 5.)
    show(op); println()
    showcompact(op); println()
    @test op.gridwidth == 4
    @test op.gridheight == 5
    @test op.scale == .2
    @test op.static_border == true
    @test op.normalize == true

    @test typeof(last(transform(op, testimg)["operations"])) <: DisplacementField

    op = RandomDisplacement(10,12, scale = .4, normalize = false)
    @test op.gridwidth == 10
    @test op.gridheight == 12
    @test op.scale == .4
    @test op.static_border == true
    @test op.normalize == false
    op = RandomDisplacement(10,12, scale = .4, static_border = false)
    @test op.gridwidth == 10
    @test op.gridheight == 12
    @test op.scale == .4
    @test op.static_border == false
    @test op.normalize == true

    @test_throws ArgumentError RandomDisplacement(2,5)
    @test_throws ArgumentError RandomDisplacement(4,2)

    srand(123)
    @imagetest "RandomDisplacement" transform(RandomDisplacement(4,5), testimg)
end

@testset "SmoothedRandomDisplacement" begin
    @test SmoothedRandomDisplacement <: ImageOperation
    @test multiplier(SmoothedRandomDisplacement(10,10)) == 1
    op = SmoothedRandomDisplacement(4,5)
    @test op == SmoothedRandomDisplacement(4., 5.)
    show(op); println()
    showcompact(op); println()
    @test op.gridwidth == 4
    @test op.gridheight == 5
    @test op.scale == .2
    @test op.sigma == 2.
    @test op.iterations == 1
    @test op.static_border == true
    @test op.normalize == true

    @test typeof(last(transform(op, testimg)["operations"])) <: DisplacementField

    op = SmoothedRandomDisplacement(10,12, scale = .4, sigma = 4, iterations = 9, normalize = false)
    @test op.gridwidth == 10
    @test op.gridheight == 12
    @test op.scale == .4
    @test op.sigma == 4.
    @test op.iterations == 9
    @test op.static_border == true
    @test op.normalize == false
    op = SmoothedRandomDisplacement(10,12, scale = 2, sigma = 3, iterations = 2, static_border = false)
    @test op.gridwidth == 10
    @test op.gridheight == 12
    @test op.scale == 2.
    @test op.sigma == 3.
    @test op.iterations == 2
    @test op.static_border == false
    @test op.normalize == true

    @test_throws ArgumentError SmoothedRandomDisplacement(2,5)
    @test_throws ArgumentError SmoothedRandomDisplacement(4,2)
    @test_throws ArgumentError SmoothedRandomDisplacement(4,5, sigma = 0.)
    @test_throws ArgumentError SmoothedRandomDisplacement(4,5, sigma = -1.)
    @test_throws ArgumentError SmoothedRandomDisplacement(4,5, iterations = 0)

    srand(123)
    @imagetest "SmoothedRandomDisplacement" transform(SmoothedRandomDisplacement(4,5), testimg)
end

@testset "Tuple of Image" begin
    imgs = (img, img2)
    op = FlipX()
    out1, out2 = transform(op, imgs)
    @test typeof(last(out1["operations"])) <: FlipX
    @test typeof(last(out2["operations"])) <: FlipX
    @test out1 == flipx(img)
    @test out2 == flipx(img2)
    op = FlipX(1)
    out1, out2 = transform(op, imgs)
    @test out1 == flipx(img)
    @test out2 == flipx(img2)
end

