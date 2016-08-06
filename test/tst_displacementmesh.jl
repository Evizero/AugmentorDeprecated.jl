@testset "mesh from field" begin
    srand(123)
    df = gaussian_displacement(3, 3, .3, 2)
    dm = DisplacementMesh(df, testimg)
    show(dm); println()
    showcompact(dm); println()
    @test typeof(dm) <: DisplacementMesh
    @test typeof(dm) <: ImageTransformation
    dm2 = DisplacementMesh(df, size(testimg, "x"), size(testimg, "y"))
    @test dm.input_vertices == dm2.input_vertices
    @test dm.output_vertices == dm2.output_vertices
    @test dm.indices == dm2.indices
    @test size(dm.input_vertices, 1) == 9
    @test size(dm.output_vertices, 1) == 9
    @test size(dm.indices, 1) == 8
    @test dm.indices ==
        [ 1  5  2;
          1  4  5;
          2  5  3;
          3  5  6;
          4  7  5;
          5  7  8;
          5  9  6;
          5  8  9 ]

    srand(123)
    df = gaussian_displacement(4, 8, .3, 2)
    dm = DisplacementMesh(df, testimg)
    @plottest "displacemen_mesh_1" plot(dm)
    # @plottest "displacemen_mesh_2" plot(dm, testimg)
end

@testset "transform" begin
    srand(123)
    df = gaussian_displacement(3, 3, .3, 2)
    dm = DisplacementMesh(df, testimg)

    @imagetest "DisplacementMesh" transform(dm, testimg)
end

