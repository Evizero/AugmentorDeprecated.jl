"""
`CropSize <: ImageOperation`

Description
============

Crops out the area of the specified pixel dimensions
around the center of the given image

Usage
======

    CropSize(64, 64)

    CropSize(width = 64, height = 64)

Arguments
==========

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

    # Crop out a 64x32 area in the center of the image
    img_new = transform(CropSize(64, 32), img)

see also
=========

`ImageOperation`, `transform`
"""
immutable CropSize <: ImageOperation
    width::Int
    height::Int

    function CropSize(width::Int, height::Int)
        width > 0 || throw(ArgumentError("width has to be greater than 0"))
        height > 0 || throw(ArgumentError("height has to be greater than 0"))
        new(width, height)
    end
end

CropSize(; width::Int = 64, height::Int = 64) = CropSize(width, height)

Base.showcompact(io::IO, op::CropSize) = print(io, "Crop a centered $(op.width)x$(op.height) window.")
multiplier(::CropSize) = 1

function transform{T<:AbstractImage}(op::CropSize, img::T)
    w = width(img)
    h = height(img)
    op.width <= w || throw(ArgumentError("image width is smaller than desired subimage"))
    op.height <= h || throw(ArgumentError("image height is smaller than desired subimage"))

    cx = floor(Int, w / 2)
    cy = floor(Int, h / 2)
    x = cx - floor(Int, op.width / 2) + 1
    @assert x > 0
    y = cy - floor(Int, op.height / 2) + 1
    @assert y > 0

    result = crop(img, x:(x+op.width-1), y:(y+op.height-1))
    _log_operation!(result, op)
end

