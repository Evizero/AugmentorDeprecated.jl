"""
`Rotate90 <: ImageOperation`

Description
============

Rotates the image upwards 90 degrees. This is a special case
rotation because it can be performed very efficiently by simply
rearranging the existing pixels. However, it is generally not the
case that the output image will have the same size as the input
image, which is something to be aware of.

If created using the parameter `chance`, the operation will be
lifted into a `ProbableOperation`. See the documentation of
`ProbableOperation` for more information.

Usage
======

    Rotate90()

    Rotate90(chance)

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
    img_new = transform(Rotate90(), img)

    # Check manually if the result is as expected
    @assert img_new == grayim(UInt8[50 200; 1 150])

see also
=========

`ImageOperation`, `ProbableOperation`, `transform`
"""
immutable Rotate90 <: ImageOperation
end

Rotate90(chance) = ProbableOperation(Rotate90(); chance = chance)

Base.showcompact(io::IO, op::Rotate90) = print(io, "Rotate 90 degrees.")
multiplier(::Rotate90) = 1

function transform{T<:AbstractImage}(op::Rotate90, img::T)
    result = copyproperties(img, rotate_expand(img, π/2))::T
    _log_operation!(result, op)
end

