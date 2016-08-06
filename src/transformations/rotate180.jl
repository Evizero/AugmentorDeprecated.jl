"""
`Rotate180 <: ImageTransformation`

Description
============

Rotates the image 180 degrees. This is a special case rotation
because it can be performed very efficiently by simply rearranging
the existing pixels. Furthermore, the output images is guaranteed
to have the same dimensions as the input image.

If created using the parameter `chance`, the operation will be
lifted into a `Either`. See the documentation of `Either` for more
information.

Usage
======

    Rotate180()

    Rotate180(chance)

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
    img_new = transform(Rotate180(), img)

    # Check manually if the result is as expected
    @assert img_new == grayim(UInt8[1 50; 150 200])

see also
=========

`ImageTransformation`, `Either`, `transform`
"""
immutable Rotate180 <: ImageTransformation
end

Rotate180(chance) = ProbableOperation(Rotate180(); chance = chance)

Base.showcompact(io::IO, op::Rotate180) = print(io, "Rotate 180 degrees.")
multiplier(::Rotate180) = 1

function transform{T<:AbstractImage}(op::Rotate180, img::T)
    result = copyproperties(img, rotate_expand(img, 1π))::T
    _log_operation!(result, op)
end

