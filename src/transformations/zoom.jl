"""
`Zoom <: ImageTransformation`

Description
============

Multiplies the image height and image width equally by some
constant factor. This means that the size of the output image
depends on the size of the input image. If one wants to resize
each dimension by a different factor, use :class:`Scale` instead.

Usage
======

    Zoom()

    Zoom(factor = 2)

Arguments
==========

- **`factor`** : The constant factor that should be used to scale
both width and height of the output image

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

    # Zoom the image to twice its size
    img_new = transform(Zoom(2), img)

see also
=========

`ImageTransformation`, `ProbableOperation`, `transform`
"""
immutable Zoom <: ImageTransformation
    factor::Float64

    function Zoom(factor::Real)
        factor > 0 || throw(ArgumentError("factor has to be greater than 0"))
        new(Float64(factor))
    end
end

Zoom(; factor = 2) = Zoom(factor)

Base.showcompact(io::IO, op::Zoom) = print(io, "Zoom by $(op.factor)x.")
multiplier(::Zoom) = 1

function transform{T<:AbstractImage}(op::Zoom, img::T)
    x, y = size(img)
    xn = ceil(Int, x * op.factor)
    yn = ceil(Int, y * op.factor)
    result = copyproperties(img, Images.imresize(img, (xn, yn)))
    _log_operation!(result, op)
end

