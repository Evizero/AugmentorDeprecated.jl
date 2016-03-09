abstract ImageSource

"""
    listfiles([dir, hidden=false, expand=false, recursive=true]) -> Vector{UTF8String}

Returns the relative paths to the visible files in the directory `dir`.

- `hidden`: If `true`, then files starting with "." are also included.

- `recursive`: If `true`, then the function will recursively step
through all the subdirectories as well and append the paths to
their content relative to `dir`.

- `expand`: If `true`, then all the paths will be expaned to the full
absolute paths instead of being realtive to `dir`
"""
function listfiles(dir = "."; hidden=false, expand=false, recursive=true)
    dircontent = convert(Vector{UTF8String}, readdir(dir))

    # exclude hidden files (i.e. the ones starting with ".")
    if !hidden
        dircontent = filter(_ -> !startswith(_, "."), dircontent)
    end

    # prepend the directory path to the files
    dircontent = map(_ -> joinpath(dir, _), dircontent)

    # fully expand the path for all files if requested
    if expand
        dircontent = map(abspath, dircontent)
    end

    # just filter out entries that are files (exclude dirs)
    files = filter(isfile, dircontent)

    # filter out the dirs as well and recursively append
    # the content of the subdirs to the file list.
    if recursive
        dirs = filter(isdir, dircontent)
        for subdir in dirs
            append!(files,
                    listfiles(subdir;
                        hidden = hidden,
                        expand = expand,
                        recursive = recursive))
        end
    end
    files
end

immutable DirImageSource <: ImageSource
    path::UTF8String
    files::Vector{UTF8String}
end

function DirImageSource(path = "."; expand = false, nargs...)
    filepaths = listfiles(path; expand = expand, nargs...)
    filenames = map(_ -> relpath(_, path), filepaths)
    DirImageSource(expand ? abspath(path) : path, filenames)
end

function Base.rand(s::DirImageSource)
    filename = rand(s.files)
    label = UTF8String(dirname(filename))
    img = load(joinpath(s.path, filename))::Image
    img, label
end

function Base.rand(s::DirImageSource, n)
    imgs = Array(Image, n)
    labels = Array(UTF8String, n)
    for i = 1:n
        img, label = rand(s)
        imgs[i] = img
        labels[i] = label
    end
    imgs, labels
end

Base.length(s::DirImageSource) = length(s.files)

function Base.show(io::IO, s::DirImageSource)
    println(io, "Image source: $(s.path)")
    print(io, "$(length(s)) images found")
end

