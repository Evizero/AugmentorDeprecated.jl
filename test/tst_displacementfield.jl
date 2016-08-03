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
    println(df)
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
    @test size(df.X) == (8, 5)
    @test size(df.Y) == (8, 5)
    @test size(df.delta_X) == (8, 5)
    @test size(df.delta_Y) == (8, 5)
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
    @test size(df.X) == (9, 10)
    @test size(df.Y) == (9, 10)
    @test size(df.delta_X) == (9, 10)
    @test size(df.delta_Y) == (9, 10)
    @test sum_border(df.delta_X) > 0.
    @test sum_border(df.delta_Y) > 0.
    test_equidistance(df)
end

@testset "gaussian_displacement" begin
    df = gaussian_displacement(10, 12)
    println(df)
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
    df = gaussian_displacement(10, 12, scale = .3, sigma = 1)
    @testset "iterations" begin
        srand(123)
        df2 = gaussian_displacement(10, 12, scale = .3, sigma = 1, iterations = 2)
        for i = 2:11, j = 2:9
            if i == 2 || j == 2 || i == 11 || j == 9
                @test abs(df2.delta_X[i,j]) != abs(df.delta_X[i,j])
                @test abs(df2.delta_Y[i,j]) != abs(df.delta_Y[i,j])
            end
        end
    end

    srand(123)
    df = gaussian_displacement(10, 12, .3, 2, 1, true, true)
    @test typeof(df) <: DisplacementField
    @test size(df.X) == (12, 10)
    @test size(df.Y) == (12, 10)
    @test size(df.delta_X) == (12, 10)
    @test size(df.delta_Y) == (12, 10)
    @test sum_border(df.delta_X) == 0.
    @test sum_border(df.delta_Y) == 0.
    test_equidistance(df)
    @plottest "gaussian_displacement" plot(df)

    df = gaussian_displacement(10, 12, static_border = false)
    @test typeof(df) <: DisplacementField
    @test sum_border(df.delta_X) > 0.
    @test sum_border(df.delta_Y) > 0.
    test_equidistance(df)

    df = gaussian_displacement(10, 12, .3, 2, 1, false, true)
    @test typeof(df) <: DisplacementField
    @test sum_border(df.delta_X) > 0.
    @test sum_border(df.delta_Y) > 0.
    test_equidistance(df)
end

