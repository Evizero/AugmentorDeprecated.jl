A = rand(UInt8, 50, 20)
img_x = grayim(A)
img_y = permutedims(img_x, [2, 1])

@testset "crop" begin
    # test types stability
    @test typeof(Augmentor.crop(img_x, 1:50, 1:20)) <: typeof(img_x)
    @test typeof(Augmentor.crop(img_y, 1:50, 1:20)) <: typeof(img_y)
    @test_throws BoundsError Augmentor.crop(img_x, 0:50, 1:20)
    @test_throws BoundsError Augmentor.crop(img_x, 1:50, 0:20)
    @test_throws BoundsError Augmentor.crop(img_x, 1:51, 1:20)
    @test_throws BoundsError Augmentor.crop(img_x, 1:50, 1:21)

    # test values for some sample matrices
    @test Augmentor.crop(img_x, 20:40, 5:15) == img_x[20:40, 5:15]
    @test Augmentor.crop(img_y, 20:40, 5:15) == img_y[5:15, 20:40]
end

