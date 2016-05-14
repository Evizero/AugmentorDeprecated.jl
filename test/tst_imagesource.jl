dir = joinpath(Pkg.dir("Augmentor"), "test/sampledir")

@testset "listfiles" begin
    lst = Augmentor.listfiles(dir;
            expand=false, hidden=false, recursive=false)
    @test typeof(lst) <: Vector{UTF8String}
    @test length(lst) == 2

    lst = Augmentor.listfiles(dir;
            expand=false, hidden=true, recursive=false)
    @test typeof(lst) <: Vector{UTF8String}
    @test length(lst) == 3

    lst = Augmentor.listfiles(dir;
            expand=false, hidden=false, recursive=true)
    @test typeof(lst) <: Vector{UTF8String}
    @test length(lst) == 3

    lst = Augmentor.listfiles(dir;
            expand=false, hidden=true, recursive=true)
    @test typeof(lst) <: Vector{UTF8String}
    @test length(lst) == 5

    lst = Augmentor.listfiles(dir;
            expand=true, hidden=true, recursive=true)
    @test typeof(lst) <: Vector{UTF8String}
    @test length(lst) == 5
end

@testset "DirImageSource" begin
    @test DirImageSource <: ImageSource
    src = DirImageSource(dir)
    @test length(src) == 3
    @test endof(src) == 3
    @test src[end] == src[3]
    @test eltype(src) <: Image
    show(src)
    println()

    img = rand(src)
    @test typeof(img) <: Image

    imgs = rand(src, 2)
    @test typeof(imgs) <: Vector
    @test eltype(imgs) <: Image

    @testset "iterator interface" begin
        count = 0
        for img in src
            count += 1
            @test typeof(img) <: Image
        end
        @test count == 3
    end
end

