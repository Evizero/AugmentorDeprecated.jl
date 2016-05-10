"""
`abstract ImageOperation`

Description
============

Abstract supertype for all image operation. Every subtype of
`ImageOperation` must implement the `transform` and the `multiplier`
methods.

Methods
========

- **`transform`** : Applies the transformation to the given Image
or set of images. This effectifely specifies the exact effect the
operation has on the input it receives

- **`multiplier`** : Specifies how many unique output variations
the operation can result in (counting the case of not being applied
to the input).

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

see also
=========

`transform`, `ProbableOperation`

"""
abstract ImageOperation

function _log_operation!(op::ImageOperation, img::Image)
    history = get!(properties(img), "operations", Array{ImageOperation,1}())
    push!(history, op)
    img
end

multiplier(::ImageOperation) = throw(ArgumentError("Every ImageOperation needs to specify a multiplication factor"))

# TODO: make this cleaner for dispatch
@inline function transform(op::ImageOperation, imgs) #::Tuple)
    transform(op, imgs[1]), transform(op, imgs[2])
end

# ==========================================================

type ProbableOperation{T<:ImageOperation} <: ImageOperation
    operation::T
    chance::Float64
end

function ProbableOperation{T<:ImageOperation}(op::T; chance::Real = .5)
    0 <= chance <= 1. || throw(ArgumentError("chance has to be between 0 and 1"))
    ProbableOperation{T}(op, Float64(chance))
end

multiplier(po::ProbableOperation) = multiplier(po.operation)

function Base.show(io::IO, po::ProbableOperation)
    print(io, round(Int, po.chance*100), "% chance to: ", po.operation)
end

function transform{T}(po::ProbableOperation, img::T)
    if hit_chance(po.chance)
        transform(po.operation, img)
    else
        img
    end::T
end

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

See also
=========

`ImageOperation`, `ProbableOperation`, `transform`
"""
immutable FlipX <: ImageOperation
end

FlipX(chance) = ProbableOperation(FlipX(); chance = chance)

Base.show(io::IO, op::FlipX) = print(io, "Flip x-axis.")
multiplier(::FlipX) = 2

function transform{T<:AbstractImage}(op::FlipX, img::T)
    result = copyproperties(img, flipx(img))::T
    _log_operation!(op, result)
end

"""
`FlipY <: ImageOperation`

Description
============

Reverses the pixel order along the y-axis. In other words it
mirrors the Image along the x-axis (i.e. vertically).

If created using the parameter `chance`, the operation will be
lifted into a `ProbableOperation`. See the documentation of
`ProbableOperation` for more information.

Usage
======

    FlipY()

    FlipY(chance)

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
    img_new = transform(FlipY(), img)

    # Check manually if the result is as expected
    @assert img_new == grayim(UInt8[150 200; 1 50])

See also
=========

`ImageOperation`, `ProbableOperation`, `transform`
"""
immutable FlipY <: ImageOperation
end

FlipY(chance) = ProbableOperation(FlipY(); chance = chance)

Base.show(io::IO, op::FlipY) = print(io, "Flip y-axis.")
multiplier(::FlipY) = 2

function transform{T<:AbstractImage}(op::FlipY, img::T)
    result = copyproperties(img, flipy(img))::T
    _log_operation!(op, result)
end


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

See also
=========

`ImageOperation`, `ProbableOperation`, `transform`
"""
immutable Rotate90 <: ImageOperation
end

Rotate90(chance) = ProbableOperation(Rotate90(); chance = chance)

Base.show(io::IO, op::Rotate90) = print(io, "Rotate 90 degrees.")
multiplier(::Rotate90) = 2

function transform{T<:AbstractImage}(op::Rotate90, img::T)
    result = copyproperties(img, rotate_expand(img, π/2))::T
    _log_operation!(op, result)
end

"""
`Rotate180 <: ImageOperation`

Description
============

Rotates the image 180 degrees. This is a special case rotation
because it can be performed very efficiently by simply rearranging
the existing pixels. Furthermore, the output images is guaranteed
to have the same dimensions as the input image.

If created using the parameter `chance`, the operation will be
lifted into a `ProbableOperation`. See the documentation of
`ProbableOperation` for more information.

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

See also
=========

`ImageOperation`, `ProbableOperation`, `transform`
"""
immutable Rotate180 <: ImageOperation
end

Rotate180(chance) = ProbableOperation(Rotate180(); chance = chance)

Base.show(io::IO, op::Rotate180) = print(io, "Rotate 180 degrees.")
multiplier(::Rotate180) = 2

function transform{T<:AbstractImage}(op::Rotate180, img::T)
    result = copyproperties(img, rotate_expand(img, 1π))::T
    _log_operation!(op, result)
end

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

See also
=========

`ImageOperation`, `ProbableOperation`, `transform`
"""
immutable Rotate270 <: ImageOperation
end

Rotate270(chance) = ProbableOperation(Rotate270(); chance = chance)

Base.show(io::IO, op::Rotate270) = print(io, "Rotate 270 degrees.")
multiplier(::Rotate270) = 2

function transform{T<:AbstractImage}(op::Rotate270, img::T)
    result = copyproperties(img, rotate_expand(img, -π/2))::T
    _log_operation!(op, result)
end

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

See also
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
    _log_operation!(op, result)
end

