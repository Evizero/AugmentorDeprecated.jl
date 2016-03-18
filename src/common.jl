hit_chance(chance::Real) = rand() <= chance
hit_chance{T<:Real}(chance::Array{T}) = rand(size(chance)) .<= chance

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
`listfiles(dir; nargs...)` → `Vector{UTF8String}`

Description
============

Returns the relative paths to those visible files in the directory `dir`
whose file-endings are specified in `formats`.
If `dir` is not provided the current working path will be used.

Usage
======

    listfiles([dir, hidden=false, expand=false, recursive=true, formats=[".png", ".jpg", ".jpeg", ".bmp"])

Arguments
==========

- `hidden`: If `true`, then files starting with "." are also included.

- `recursive`: If `true`, then the function will also recursively step
through all the subdirectories and append the paths to
their content relative to `dir`.

- `expand`: If `true`, then all the paths will be expaned to the full
absolute paths instead of being realtive to `dir`.

- `formats`: The allowed file endings. Files with a different suffix
will not be included in the return value.

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

see also
=========

`DirImageSource`
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

