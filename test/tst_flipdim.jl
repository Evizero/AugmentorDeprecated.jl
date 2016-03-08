A = UInt8[200 150; 50 1]
img_x = grayim(A)
img_y = permutedims(img_x, [2, 1])

context("flipdim") do
    @fact raw(flipdim(img_x, "x")) --> raw(flipdim(img_x, 1))
    @fact raw(flipdim(img_x, "x")) --> flipdim(A, 1)
    @fact raw(flipdim(img_y, "x")) --> raw(flipdim(img_y, 2))
    @fact raw(flipdim(img_y, "x")) --> flipdim(A', 2)

    @fact raw(flipdim(img_x, "y")) --> raw(flipdim(img_x, 2))
    @fact raw(flipdim(img_x, "y")) --> flipdim(A, 2)
    @fact raw(flipdim(img_y, "y")) --> raw(flipdim(img_y, 1))
    @fact raw(flipdim(img_y, "y")) --> flipdim(A', 1)
end

context("flipx") do
    @fact raw(flipx(img_x)) --> raw(flipdim(img_x, "x"))
    @fact raw(flipx(img_y)) --> raw(flipdim(img_y, "x"))
end

context("flipx") do
    @fact raw(flipy(img_x)) --> raw(flipdim(img_x, "y"))
    @fact raw(flipy(img_y)) --> raw(flipdim(img_y, "y"))
end
