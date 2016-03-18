"""
`DirImageSource(path; nargs...)` → `DirImageSource`

Description
============

Concrete implementation of `ImageSource` for (nested) directories
of a local filesystem.
The purpose of `DirImageSource` is to seamlesssly load images from
a directory and its subdirectories.
Note that subdirectories will be treated as categories and their
relative paths will be stored as metadata within the loaded
image object.

Every subtype of ImageSource implements most read-only functions
of the array interface.
Additionally, it fully implements the iterator interface and can be
used as for loop to iterate over all the stored images.

Usage
======

    DirImageSource(path = "."; hidden=false, expand=false, recursive=true, formats=[".png", ".jpg", ".jpeg", ".bmp"])

Arguments
==========

- **`path`** : The directory that contains the desired images.
This can also be just a container for subdirectories,
in which the subdirectories contain the actual images.
However, for this to work `recursive` has to be set to `true`

- **`expand`** : If `true`, all the paths will be extended to
absolute paths instead of being  relative to the root directory
specified by `path`.
It is generally recommended to set `expand = false` (default).

- **`recursive`** : If `true`, then all the subdirectories of `path`
will be processed as well. That implies that if any subdirectory,
or their subdirectories, contain any images of a format specified by
`formats`, then those images will be part of the `DirImageSource`.

- **`formats`** : Array of strings. Specifies which file endings
should be considered an image. Any file of such ending will be
available as part of the `DirImageSource`

Methods
========

- **`rand`** : Loads and returns a random image, or an array
of images, from the specified directory (depending on the parameters).
If `recursive` was set to `true`, then all the images from the
subdirectories are considered as well.

- **`length`** : Returns the total number of images that are available
in the specified directory. If `recursive` was set `true`, then all the
images from the subdirectories are counted as well

- **`getindex`** : Loads and returns the image of the given index.
The numerical index is more or less arbitrary and depends on the
order the images were parsed.

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
========

    # create the image source by indexing the directories content.
    # Note: this command won't actually load any images.
    src = DirImageSource("mydatadir/")

    # number of available images
    n = length(src)

    # images can be indexed like an array
    img1 = src[1]

    # loop through all images in the source
    for img in src
        println(img)
    end

see also
=========

`ImageSource`
"""
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

