
@testset "uniform_displacement" begin
    srand(123)
    df = uniform_displacement(5, 8)
    @test typeof(df) <: DisplacementField
    @test size(df.X) == (5, 8)
    @test size(df.Y) == (5, 8)
    @test size(df.delta_X) == (5, 8)
    @test size(df.delta_Y) == (5, 8)
    @plottest "uniform_displacement" plot(df, strength = .2)
end

@testset "gaussian_displacement" begin
    srand(123)
    df = gaussian_displacement(10, 12, 2)
    @test typeof(df) <: DisplacementField
    @test size(df.X) == (10, 12)
    @test size(df.Y) == (10, 12)
    @test size(df.delta_X) == (10, 12)
    @test size(df.delta_Y) == (10, 12)
    @plottest "gaussian_displacement" plot(df, strength = .3)
end

