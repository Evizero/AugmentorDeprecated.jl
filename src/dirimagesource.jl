immutable DirImageSource <: ImageSource
    path::UTF8String
    files::Vector{UTF8String}
end

function _name(filename)
    ending = match(r"\.[a-zA-Z]+$", filename)
    if ending == nothing || ending.offset == 1
        return filename
    else
        filename[1:(ending.offset-1)]
    end
end

function DirImageSource(path = "."; expand = false, nargs...)
    filepaths = listfiles(path; expand = expand, nargs...)
    filenames = map(_ -> relpath(_, path), filepaths)
    DirImageSource(expand ? abspath(path) : path, filenames)
end

function Base.getindex(s::DirImageSource, index::Integer)
    filename = s.files[index]
    img_dir = dirname(filename)
    img_dir = length(img_dir) == 0 ? "." : img_dir
    img_name = _name(relpath(filename, img_dir))
    img = load(joinpath(s.path, filename))::Image
    img["name"] = img_name
    img["category"] = img_dir
    img
end

Base.length(s::DirImageSource) = length(s.files)
Base.start(::DirImageSource) = 1
Base.next(s::DirImageSource, state) = (s[state], state+1)
Base.done(s::DirImageSource, state) = state > length(s)

