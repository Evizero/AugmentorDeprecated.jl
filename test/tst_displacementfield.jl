function sum_border(A::Matrix{Float64})
    sum = 0.
    w, h = size(A)
    for i = 1:w, j = 1:h
        if i == 1 || j == 1 || i == w || j == h
            sum += abs(A[i, j])
        end
    end
    sum
end

function test_equidistance(df::DisplacementField)
    @testset "equidistance" begin
        w, h = size(df.X)
        for i = 1:w, j = 1:h
            @test_approx_eq df.X[i,j] (j-1)/(h-1)
            @test_approx_eq df.Y[i,j] (i-1)/(w-1)
        end
    end
end

@testset "uniform_displacement" begin
    df = uniform_displacement(5, 8)
    @test typeof(df) <: DisplacementField
    @test sum_border(df.delta_X) == 0.
    @test sum_border(df.delta_Y) == 0.
    test_equidistance(df)

    srand(123)
    df = uniform_displacement(5, 8, .2)
    @test typeof(df) <: DisplacementField
    @test sum_border(df.delta_X) == 0.
    @test sum_border(df.delta_Y) == 0.
    test_equidistance(df)
    @plottest "uniform_displacement" plot(df)

    srand(123)
    df = uniform_displacement(5, 8, scale = .2)
    @test typeof(df) <: DisplacementField
    @test sum_border(df.delta_X) == 0.
    @test sum_border(df.delta_Y) == 0.
    test_equidistance(df)
    @plottest "uniform_displacement" plot(df)

    srand(123)
    df = uniform_displacement(5, 8, .2, true, true)
    @test typeof(df) <: DisplacementField
    @test size(df.X) == (5, 8)
    @test size(df.Y) == (5, 8)
    @test size(df.delta_X) == (5, 8)
    @test size(df.delta_Y) == (5, 8)
    @test sum_border(df.delta_X) == 0.
    @test sum_border(df.delta_Y) == 0.
    test_equidistance(df)
    @plottest "uniform_displacement" plot(df)

    df = uniform_displacement(10, 9, static_border = false)
    @test typeof(df) <: DisplacementField
    @test sum_border(df.delta_X) > 0.
    @test sum_border(df.delta_Y) > 0.
    test_equidistance(df)

    df = uniform_displacement(10, 9, .1, false, true)
    @test typeof(df) <: DisplacementField
    @test size(df.X) == (10, 9)
    @test size(df.Y) == (10, 9)
    @test size(df.delta_X) == (10, 9)
    @test size(df.delta_Y) == (10, 9)
    @test sum_border(df.delta_X) > 0.
    @test sum_border(df.delta_Y) > 0.
    test_equidistance(df)
end

@testset "gaussian_displacement" begin
    df = gaussian_displacement(10, 12)
    @test typeof(df) <: DisplacementField
    @test sum_border(df.delta_X) == 0.
    @test sum_border(df.delta_Y) == 0.
    test_equidistance(df)

    srand(123)
    df = gaussian_displacement(10, 12, .3, 2)
    @test typeof(df) <: DisplacementField
    @test sum_border(df.delta_X) == 0.
    @test sum_border(df.delta_Y) == 0.
    test_equidistance(df)
    @plottest "gaussian_displacement" plot(df)

    srand(123)
    df = gaussian_displacement(10, 12, scale = .3, sigma = 2)
    @test typeof(df) <: DisplacementField
    @test sum_border(df.delta_X) == 0.
    @test sum_border(df.delta_Y) == 0.
    test_equidistance(df)
    @plottest "gaussian_displacement" plot(df)

    srand(123)
    df = gaussian_displacement(10, 12, .3, 2, true, true)
    @test typeof(df) <: DisplacementField
    @test size(df.X) == (10, 12)
    @test size(df.Y) == (10, 12)
    @test size(df.delta_X) == (10, 12)
    @test size(df.delta_Y) == (10, 12)
    @test sum_border(df.delta_X) == 0.
    @test sum_border(df.delta_Y) == 0.
    test_equidistance(df)
    @plottest "gaussian_displacement" plot(df)

    df = gaussian_displacement(10, 12, static_border = false)
    @test typeof(df) <: DisplacementField
    @test sum_border(df.delta_X) > 0.
    @test sum_border(df.delta_Y) > 0.
    test_equidistance(df)

    df = gaussian_displacement(10, 12, .3, 2, false, true)
    @test typeof(df) <: DisplacementField
    @test sum_border(df.delta_X) > 0.
    @test sum_border(df.delta_Y) > 0.
    test_equidistance(df)
end

