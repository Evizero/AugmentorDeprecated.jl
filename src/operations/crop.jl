"""
`Crop <: ImageOperation`

Description
============

Crops out the area of the specified pixel dimensions starting
at a specified position that denotes the top-left corner
of the crop. A position of `x = 1`, and `y = 1` would mean that
the crop is located in the top-left corner of the original image

Usage
======

    Crop(1, 1, 64, 64)

    Crop(x = 1, y = 1, width = 64, height = 64)

Arguments
==========

- **`x`** : The horizontal offset of the top left corner of the
window that should be cropped out

- **`y`** : The vertical offset of the top left corner of the
window that should be cropped out

- **`width`** : The desired width or the cropped out subimage
in pixels

- **`height`** : The desired height or the cropped out subimage
in pixels

Methods
========

- **`transform`** : Applies the transformation to the given Image
or set of images

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
========

    using Augmentor
    using TestImages

    # load an example image
    img = testimage("lena")

    # Crop out a 64x32 area starting at x=10, y=20
    img_new = transform(Crop(10, 20, 64, 32), img)

see also
=========

`ImageOperation`, `transform`
"""
immutable Crop <: ImageOperation
    x::Int
    y::Int
    width::Int
    height::Int

    function Crop(x::Int, y::Int, width::Int, height::Int)
        x > 0 || throw(ArgumentError("x has to be greater than 0"))
        y > 0 || throw(ArgumentError("y has to be greater than 0"))
        width > 0 || throw(ArgumentError("width has to be greater than 0"))
        height > 0 || throw(ArgumentError("height has to be greater than 0"))
        new(x, y, width, height)
    end
end

Crop(; x::Int = 1, y::Int = 1, width::Int = 64, height::Int = 64) = Crop(x, y, width, height)

Base.show(io::IO, op::Crop) = print(io, "Crop at x=$(op.x) y=$(op.y) a $(op.width)x$(op.height) window.")
multiplier(::Crop) = 1

function transform{T<:AbstractImage}(op::Crop, img::T)
    w = width(img)
    h = height(img)
    op.x < w || throw(ArgumentError("x of crop window is out of bounds"))
    op.y < h || throw(ArgumentError("y of crop window is out of bounds"))

    x_end = op.x + op.width - 1
    y_end = op.y + op.height - 1
    x_end < w || throw(ArgumentError("width of crop window is out of bounds"))
    y_end < h || throw(ArgumentError("height of crop window is out of bounds"))

    result = crop(img, op.x:x_end, op.y:y_end)
    _log_operation!(op, result)
end

