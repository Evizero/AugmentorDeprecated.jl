"""
`Resize <: ImageOperation`

Description
============

Transforms the image intoto a fixed specified pixel size. This
operation does not take any measures to preserve aspect ratio
of the source image.  Instead, the original image will simply be
resized to the given dimensions. This is useful when one needs a
set of images to all be of the exact same size.

Usage
======

    Resize()

    Resize(width = 64, height = 64)

Arguments
==========

- **`width`** : The width in pixel of the output image

- **`height`** : The height in pixel of the output image

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

    # Resize the image to exactly 32x32 pixel
    img_new = transform(Resize(32, 32), img)

see also
=========

`ImageOperation`, `ProbableOperation`, `transform`
"""
immutable Resize <: ImageOperation
    width::Int
    height::Int

    function Resize(width::Int, height::Int)
        width >= 1 || throw(ArgumentError("width has to be greater than 0"))
        height >= 1 || throw(ArgumentError("height has to be greater than 0"))
        new(width, height)
    end
end

Resize(;width::Int = 64, height::Int = 64) = Resize(width, height)

Base.show(io::IO, op::Resize) = print(io, "Resize to $(op.width)x$(op.height).")
multiplier(::Resize) = 1

function transform{T<:AbstractImage}(op::Resize, img::T)
    result = if isxfirst(img)
        copyproperties(img, Images.imresize(img, (op.width, op.height)))
    else
        copyproperties(img, Images.imresize(img, (op.height, op.width)))
    end::T
    _log_operation!(result, op)
end

