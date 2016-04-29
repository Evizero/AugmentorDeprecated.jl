using MLDataUtils

dir = joinpath(Pkg.dir("Augmentor"), "test/sampledir")

@testset "splitdata" begin
    src = DirImageSource(dir)
    @test length(src) == 3

    d1, d2 = splitdata(src, .7)
    @test length(d1) == 2
    @test length(d2) == 1

    @test typeof(get(d1)) <: Vector{Image}
    @test typeof(get(d2)) <: Vector{Image}

    names = Array{ASCIIString, 1}()
    push!(names, d1[1]["name"])
    push!(names, d1[2]["name"])
    push!(names, d2[1]["name"])
    @test length(unique(names)) == 3
end

@testset "MiniBatches" begin
    src = DirImageSource(dir)

    names = Array{ASCIIString, 1}()
    count = 0
    for imgs in MiniBatches(src, size = 1)
        push!(names, imgs[1]["name"])
        count += 1
    end
    @test count == 3
    @test length(unique(names)) == 3
end

@testset "KFolds" begin
    src = DirImageSource(dir)

    names = Array{ASCIIString, 1}()
    count = 0
    for (train, test) in KFolds(src, 3)
        @test length(train) == 2
        @test length(test) == 1
        push!(names, test[1]["name"])
        count += 1
    end
    @test count == 3
    @test length(unique(names)) == 3
end

