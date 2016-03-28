@testset "_simplify_angle" begin
    # test typical ouput types
    @test typeof(Augmentor._simplify_angle(Float32(0.5))) <: Float32
    @test typeof(Augmentor._simplify_angle(Float64(0.5))) <: Float64
    @test typeof(Augmentor._simplify_angle(Int32(1))) <: Float64
    @test typeof(Augmentor._simplify_angle(Int64(1))) <: Float64

    # test if returntype of +angle is the same as returntype of -angle
    for i in (Float32(0.5), Float64(0.5), Int32(1), Int64(1))
        @test typeof(Augmentor._simplify_angle(i)) <: typeof(Augmentor._simplify_angle(-i))
    end

    # test hardcoded numbers (edge chases)
    @test Augmentor._simplify_angle(0) == 0
    @test Augmentor._simplify_angle(2pi) == 0
    @test Augmentor._simplify_angle(-2pi) == 0
    @test Augmentor._simplify_angle(3pi) == 1pi
    @test Augmentor._simplify_angle(-3pi) == 1pi
    @test Augmentor._simplify_angle(4pi) == 0
    @test Augmentor._simplify_angle(-4pi) == 0

    for angle in 0:.4:4pi
        @test Augmentor._simplify_angle(angle) == angle % 2pi
        if angle > 0
            @test Augmentor._simplify_angle(-angle) == 2pi + (-angle % 2pi)
        end
    end
end

@testset "_expand_size" begin
    # test type stability
    for w in (20, 20.),
        h in (10, 10.),
        angle = (Int16(1), Int32(1), Int64(1), Float16(.5), Float32(.5), Float64(.5))
        @test typeof(Augmentor._expand_size(w, h, angle)) <: Tuple{Int64,Int64}
    end

    # test output sizes for trivial input
    for w in 10:500:1000, h in 10:500:1000
        @test Augmentor._expand_size(w, h, 0) == (w, h)
        @test Augmentor._expand_size(w, h, 1pi) == (w, h)
        @test Augmentor._expand_size(w, h, pi/2) == (h, w)
        @test Augmentor._expand_size(w, h, 3pi/2) == (h, w)
    end

    # test output sized for some known inputs
    @test Augmentor._expand_size(768, 512, deg2rad(30)) == (921, 827)
    @test Augmentor._expand_size(768, 512, deg2rad(45)) == (905, 905)
    @test Augmentor._expand_size(768, 512, deg2rad(120)) == (827, 921)
    @test Augmentor._expand_size(768, 512, deg2rad(190)) == (845, 637)
end

A = UInt8[200 150; 50 1]
img_x = grayim(A)
img_y = permutedims(img_x, [2, 1])

@testset "rotate_expand" begin
    # test types stability
    @test typeof(rotate_expand(A, deg2rad(90))) <: typeof(A)
    @test typeof(rotate_expand(img_x, deg2rad(90))) <: typeof(img_x)
    @test typeof(rotate_expand(A, deg2rad(180))) <: typeof(A)
    @test typeof(rotate_expand(img_x, deg2rad(180))) <: typeof(img_x)
    @test typeof(rotate_expand(A, deg2rad(270))) <: typeof(A)
    @test typeof(rotate_expand(img_x, deg2rad(270))) <: typeof(img_x)

    # test values for some sample matrices
    @test rotate_expand(A, deg2rad(90)) == rotr90(A)
    @test rotate_expand(A, deg2rad(180)) == rot180(A)
    @test rotate_expand(A, deg2rad(270)) == rotl90(A)

    # test values for some sample images
    @test raw(rotate_expand(img_x, deg2rad(90))) == rotr90(A)
    @test raw(rotate_expand(img_y, deg2rad(90))) == rotl90(A')
    @test raw(rotate_expand(img_x, deg2rad(270))) == rotl90(A)
    @test raw(rotate_expand(img_y, deg2rad(270))) == rotr90(A')
    @test raw(rotate_expand(img_x, deg2rad(180))) == rot180(A)
    @test raw(rotate_expand(img_y, deg2rad(180))) == rot180(A')
end

@testset "rotate_crop" begin
    #pending "test types for some sample matrices"
    #pending "test values for some sample matrices"
    #pending "test values for some sample images"
end

