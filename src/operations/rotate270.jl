"""
`Rotate270 <: ImageOperation`

Description
============

Rotates the image upwards 270 degrees, which can also be described
as rotating the image downwards 90 degrees. This is a special case
rotation, because it can be performed very efficiently by simply
rearranging the existing pixels. However, it is generally not the
case that the output image will have the same size as the input
image, which is something to be aware of.

If created using the parameter `chance`, the operation will be
lifted into a `ProbableOperation`. See the documentation of
`ProbableOperation` for more information.

Usage
======

    Rotate270()

    Rotate270(chance)

Arguments
==========

- **`chance`** : The probability of the operation to be applied to
the image if the operation is used in `transform`. Must be within
the set [0, 1].

Methods
========

- **`transform`** : Applies the transformation to the given Image
or set of images

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
========

    using Images
    using Augmentor

    # Create a test image with 4 pixel.
    img = grayim(UInt8[200 150; 50 1])

    # Apply the image operation to the image
    img_new = transform(Rotate270(), img)

    # Check manually if the result is as expected
    @assert img_new == grayim(UInt8[150 1; 200 50])

see also
=========

`ImageOperation`, `ProbableOperation`, `transform`
"""
immutable Rotate270 <: ImageOperation
end

Rotate270(chance) = ProbableOperation(Rotate270(); chance = chance)

Base.showcompact(io::IO, op::Rotate270) = print(io, "Rotate 270 degrees.")
multiplier(::Rotate270) = 1

function transform{T<:AbstractImage}(op::Rotate270, img::T)
    result = copyproperties(img, rotate_expand(img, -π/2))::T
    _log_operation!(result, op)
end

