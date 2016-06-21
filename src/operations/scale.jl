"""
`Scale <: ImageOperation`

Description
============

Multiplies the image height and image width by individually specified
constant factors. This means that the size of the output image
depends on the size of the input image. If one wants to resize
each dimension by the same factor, use :class:`Zoom` instead.

Usage
======

    Scale()

    Scale(width = 1, height = 1)

Arguments
==========

- **`width`** : The constant factor that should be used to scale the
width of the output image

- **`height`** : The constant factor that should be used to scale the
height of the output image

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

    # Scale the image to half its width and twice its height
    img_new = transform(Scale(0.5, 2), img)

see also
=========

`ImageOperation`, `ProbableOperation`, `transform`
"""
immutable Scale <: ImageOperation
    width::Float64
    height::Float64

    function Scale(width::Real, height::Real)
        width > 0 || throw(ArgumentError("width has to be greater than 0"))
        height > 0 || throw(ArgumentError("height has to be greater than 0"))
        new(Float64(width), Float64(height))
    end
end

Scale(; width = 1, height = 1) = Scale(width, height)

Base.showcompact(io::IO, op::Scale) = print(io, "Scale by $(op.width) x $(op.height).")
multiplier(::Scale) = 1

function transform{T<:AbstractImage}(op::Scale, img::T)
    s1, s2 = size(img)
    if isxfirst(img)
        x = ceil(Int, s1 * op.width)
        y = ceil(Int, s2 * op.height)
        result = copyproperties(img, Images.imresize(img, (x, y)))
        _log_operation!(result, op)
    else
        x = ceil(Int, s2 * op.width)
        y = ceil(Int, s1 * op.height)
        result = copyproperties(img, Images.imresize(img, (y, x)))
        _log_operation!(result, op)
    end
end

