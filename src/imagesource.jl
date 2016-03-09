abstract ImageSource

function Base.endswith{T<:AbstractString}(filename::AbstractString, suffixes::AbstractVector{T})
    for suffix in suffixes
        if endswith(filename, suffix)
            return true
        elseif endswith(filename, uppercase(suffix))
            return true
        end
    end
    return false
end

"""
    listfiles([dir, hidden=false, expand=false, recursive=true, formats=[".png", ".jpg", ".jpeg", ".bmp"]) -> Vector{UTF8String}

Returns the relative paths to the visible files in the directory `dir`
that have a file-ending specified in `formats`.
if `dir` is not provided the current working path will be used.

- `hidden`: If `true`, then files starting with "." are also included.

- `recursive`: If `true`, then the function will recursively step
through all the subdirectories as well and append the paths to
their content relative to `dir`.

- `expand`: If `true`, then all the paths will be expaned to the full
absolute paths instead of being realtive to `dir`

- `formats`: The allowed file endings. Files with a different suffix
will not be included in the return value.
"""
function listfiles(
        dir = ".";
        hidden = false,
        expand = false,
        recursive = true,
        formats = [".png", ".jpg", ".jpeg", ".bmp"])
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

    # only include files that end with one of the allowed formats
    files = filter(_ -> endswith(_, formats), files)

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

function Base.getindex(s::DirImageSource, index::Integer)
    filename = s.files[index]
    label = UTF8String(dirname(filename))
    img = load(joinpath(s.path, filename))::Image
    img, label
end

function Base.rand(s::DirImageSource)
    index = rand(1:length(s.files))
    s[index]
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

Base.start(::DirImageSource) = 1
Base.next(s::DirImageSource, state) = (s[state], state+1)
Base.done(s::DirImageSource, state) = state > length(s)

Base.eltype(::Type{DirImageSource}) = Image
Base.length(s::DirImageSource) = length(s.files)
Base.endof(s::DirImageSource) = length(s.files)

function Base.show(io::IO, s::DirImageSource)
    println(io, "Image source: $(s.path)")
    print(io, "$(length(s)) images found")
end

