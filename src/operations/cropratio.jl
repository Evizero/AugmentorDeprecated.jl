"""
`CropRatio <: ImageOperation`

Description
============

Crops out the biggest area around the center of the given image
such that said sub-image satisfies the specified aspect ratio
(i.e. width divided by height).

Usage
======

    CropRatio()

    CropRatio(ratio = 1)

Arguments
==========

- **`ratio`** : The ratio of image height to image width that
the output image should satisfy

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

    # Crop to image to a 2:1 aspect ratio
    img_new = transform(CropRatio(2), img)

see also
=========

`ImageOperation`, `ProbableOperation`, `transform`
"""
immutable CropRatio <: ImageOperation
    ratio::Float64

    function CropRatio(ratio::Real)
        ratio > 0 || throw(ArgumentError("ratio has to be greater than 0"))
        new(Float64(ratio))
    end
end

CropRatio(; ratio = 1.) = CropRatio(ratio)

Base.show(io::IO, op::CropRatio) = print(io, "Crop to $(op.ratio) aspect ratio.")
multiplier(::CropRatio) = 1

function transform{T<:AbstractImage}(op::CropRatio, img::T)
    w = width(img)
    h = height(img)

    nw = floor(Int, h * op.ratio)
    nh = floor(Int, w / op.ratio)
    nw = nw > 1 ? nw : 1
    nh = nh > 1 ? nh : 1

    result = if nw == w || nh == h
        img
    elseif nw < w
        i = floor(Int, (w - nw) / 2)
        @assert i > 0
        crop(img, i:(i+nw-1), 1:h)
    elseif nh < h
        i = floor(Int, (h - nh) / 2)
        @assert i > 0
        crop(img, 1:w, i:(i+nh-1))
    end::T
    _log_operation!(result, op)
end

