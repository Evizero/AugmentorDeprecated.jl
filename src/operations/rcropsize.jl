"""
`RCropSize <: ImageOperation`

Description
============

Crops out an area of the specified pixel dimensions
at a randomized position of the given image

Usage
======

    RCropSize(64, 64)

    RCropSize(width = 64, height = 64)

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
    img_new = transform(RCropSize(64, 32), img)

see also
=========

`ImageOperation`, `transform`
"""
immutable RCropSize <: ImageOperation
    width::Int
    height::Int

    function RCropSize(width::Int, height::Int)
        width > 0 || throw(ArgumentError("width has to be greater than 0"))
        height > 0 || throw(ArgumentError("height has to be greater than 0"))
        new(width, height)
    end
end

RCropSize(; width::Int = 64, height::Int = 64) = RCropSize(width, height)

Base.show(io::IO, op::RCropSize) = print(io, "Crop a random $(op.width)x$(op.height) window.")
multiplier(::RCropSize) = 1

function transform{T<:AbstractImage}(op::RCropSize, img::T)
    w = width(img)
    h = height(img)
    op.width < w || throw(ArgumentError("image width is smaller than desired subimage"))
    op.height < h || throw(ArgumentError("image height is smaller than desired subimage"))

    x_max = w - op.width + 1
    @assert x_max > 0
    y_max = h - op.height + 1
    @assert y_max > 0

    x = rand(1:x_max)
    y = rand(1:y_max)

    result = crop(img, x:(x+op.width-1), y:(y+op.height-1))
    _log_operation!(result, op)
end

