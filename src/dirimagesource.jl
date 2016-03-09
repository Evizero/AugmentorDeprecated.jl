immutable DirImageSource <: ImageSource
    path::UTF8String
    files::Vector{UTF8String}
end

function DirImageSource(path = "."; expand = false, nargs...)
    filepaths = listfiles(path; expand = expand, nargs...)
    filenames = map(_ -> relpath(_, path), filepaths)
    DirImageSource(expand ? abspath(path) : path, filenames)
end

function Base.getindex(s::DirImageSource, index::Integer)
    filename = s.files[index]
    label = UTF8String(dirname(filename))
    img = load(joinpath(s.path, filename))::Image
    img, label
end

function Base.rand(s::DirImageSource, n)
    imgs = Array(Image, n)
    labels = Array(UTF8String, n)
    @inbounds for i = 1:n
        img, label = rand(s)
        imgs[i] = img
        labels[i] = label
    end
    imgs, labels
end

Base.length(s::DirImageSource) = length(s.files)
Base.start(::DirImageSource) = 1
Base.next(s::DirImageSource, state) = (s[state], state+1)
Base.done(s::DirImageSource, state) = state > length(s)

