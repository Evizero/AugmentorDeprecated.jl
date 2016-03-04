context("_simplify_angle") do
    # test typical ouput types
    @fact typeof(Augmentor._simplify_angle(Float32(0.5))) <: Float32 --> true
    @fact typeof(Augmentor._simplify_angle(Float64(0.5))) <: Float64 --> true
    @fact typeof(Augmentor._simplify_angle(Int32(1))) <: Float64 --> true
    @fact typeof(Augmentor._simplify_angle(Int64(1))) <: Float64 --> true

    # test if returntype of +angle is the same as returntype of -angle
    for i in (Float32(0.5), Float64(0.5), Int32(1), Int64(1))
        @fact typeof(Augmentor._simplify_angle(i)) <: typeof(Augmentor._simplify_angle(-i)) --> true
    end

    # test hardcoded numbers (edge chases)
    @fact Augmentor._simplify_angle(0) --> 0
    @fact Augmentor._simplify_angle(2pi) --> 0
    @fact Augmentor._simplify_angle(-2pi) --> 0
    @fact Augmentor._simplify_angle(3pi) --> 1pi
    @fact Augmentor._simplify_angle(-3pi) --> 1pi
    @fact Augmentor._simplify_angle(4pi) --> 0
    @fact Augmentor._simplify_angle(-4pi) --> 0

    for angle in 0:.4:4pi
        @fact Augmentor._simplify_angle(angle) --> angle % 2pi
        if angle > 0
            @fact Augmentor._simplify_angle(-angle) --> 2pi + (-angle % 2pi)
        end
    end
end

context("_expand_size") do
    # test type stability
    for w in (20, 20.),
        h in (10, 10.),
        angle = (Int16(1), Int32(1), Int64(1), Float16(.5), Float32(.5), Float64(.5))
        @fact typeof(Augmentor._expand_size(w, h, angle)) <: Tuple{Int64,Int64} --> true
    end

    # test output sizes for trivial input
    for w in 10:500:1000, h in 10:500:1000
        @fact Augmentor._expand_size(w, h, 0) --> (w, h)
        @fact Augmentor._expand_size(w, h, 1pi) --> (w, h)
        @fact Augmentor._expand_size(w, h, pi/2) --> (h, w)
        @fact Augmentor._expand_size(w, h, 3pi/2) --> (h, w)
    end

    # test output sized for some known inputs
    @fact Augmentor._expand_size(768, 512, deg2rad(30)) --> (921, 827)
    @fact Augmentor._expand_size(768, 512, deg2rad(45)) --> (905, 905)
    @fact Augmentor._expand_size(768, 512, deg2rad(120)) --> (827, 921)
    @fact Augmentor._expand_size(768, 512, deg2rad(190)) --> (845, 637)
end

context("rotate_expand") do
    @pending "test types for some sample matrices" --> true
    @pending "test values for some sample matrices" --> true
    @pending "test values for some sample images" --> true
end

context("rotate_crop") do
    @pending "test types for some sample matrices" --> true
    @pending "test values for some sample matrices" --> true
    @pending "test values for some sample images" --> true
end

