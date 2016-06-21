"""
`FlipX <: ImageOperation`

Description
============

Reverses the pixel order along the x-axis. In other words it
mirrors the Image along the y-axis (i.e. horizontally).

If created using the parameter `chance`, the operation will be
lifted into a `ProbableOperation`. See the documentation of
`ProbableOperation` for more information.

Usage
======

    FlipX()

    FlipX(chance)

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
    img_new = transform(FlipX(), img)

    # Check manually if the result is as expected
    @assert img_new == grayim(UInt8[50 1; 200 150])

see also
=========

`ImageOperation`, `ProbableOperation`, `transform`
"""
immutable FlipX <: ImageOperation
end

FlipX(chance) = ProbableOperation(FlipX(); chance = chance)

Base.showcompact(io::IO, op::FlipX) = print(io, "Flip x-axis.")
multiplier(::FlipX) = 1

function transform{T<:AbstractImage}(op::FlipX, img::T)
    result = copyproperties(img, flipx(img))::T
    _log_operation!(result, op)
end

