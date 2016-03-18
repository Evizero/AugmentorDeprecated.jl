A = UInt8[200 150; 50 1]
img_x = grayim(A)
img_y = permutedims(img_x, [2, 1])

@testset "flipdim" begin
    @test raw(flipdim(img_x, "x")) == raw(flipdim(img_x, 1))
    @test raw(flipdim(img_x, "x")) == flipdim(A, 1)
    @test raw(flipdim(img_y, "x")) == raw(flipdim(img_y, 2))
    @test raw(flipdim(img_y, "x")) == flipdim(A', 2)

    @test raw(flipdim(img_x, "y")) == raw(flipdim(img_x, 2))
    @test raw(flipdim(img_x, "y")) == flipdim(A, 2)
    @test raw(flipdim(img_y, "y")) == raw(flipdim(img_y, 1))
    @test raw(flipdim(img_y, "y")) == flipdim(A', 1)
end

@testset "flipx" begin
    @test raw(flipx(img_x)) == raw(flipdim(img_x, "x"))
    @test raw(flipx(img_y)) == raw(flipdim(img_y, "x"))
end

@testset "flipx" begin
    @test raw(flipy(img_x)) == raw(flipdim(img_x, "y"))
    @test raw(flipy(img_y)) == raw(flipdim(img_y, "y"))
end
