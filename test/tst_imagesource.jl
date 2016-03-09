dir = joinpath(Pkg.dir("Augmentor"), "test/sampledir")

context("listfiles") do
    lst = Augmentor.listfiles(dir;
            expand=false, hidden=false, recursive=false)
    @fact typeof(lst) <: Vector{UTF8String} --> true
    @fact length(lst) --> 2

    lst = Augmentor.listfiles(dir;
            expand=false, hidden=true, recursive=false)
    @fact typeof(lst) <: Vector{UTF8String} --> true
    @fact length(lst) --> 3

    lst = Augmentor.listfiles(dir;
            expand=false, hidden=false, recursive=true)
    @fact typeof(lst) <: Vector{UTF8String} --> true
    @fact length(lst) --> 3

    lst = Augmentor.listfiles(dir;
            expand=false, hidden=true, recursive=true)
    @fact typeof(lst) <: Vector{UTF8String} --> true
    @fact length(lst) --> 5
end

context("DirImageSource") do
    @fact DirImageSource <: ImageSource --> true
    src = DirImageSource(dir)
    @fact length(src) --> 3

    img = rand(src)
    @fact typeof(img) <: Image --> true

    imgs = rand(src, 2)
    @fact typeof(imgs) <: Vector --> true
    @fact eltype(imgs) <: Image --> true
end

