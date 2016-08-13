"""
`RandomDisplacement <: ImageTransformation`

Description
============

Distorts the given image using a randomly (uniform) generated
`DisplacementField` of the given grid size. This field will be
streched over the given image and converted into a `DisplacementMesh`.
which in turn will morph the original image into a new image using
piecewise affine transformations.

Usage
======

    RandomDisplacement(gridwidth, gridheight[, scale=0.2, static_border=true, normalize=true])

Arguments
==========

- **`gridwidth`** : The width of the displacment field. Effectively
specifies the number of vertices along the X dimension used as
landmarks during the deformation process

- **`gridheight`** : The height of the displacment field. Effectively
specifies the number of vertices along the Y dimension used as
landmarks during the deformation process

- **`scale`** : The scaling factor applied to all displacement
vectors in the field. This effectively defines the "strength" of the
deformation. There is no theoretical upper limit to this factor, but
a value somewhere between `0.01` and `1.0` seem to be the most reasonable
choices. Default to `0.2`.

- **`static_border`** : If true, the borders of the image will be
preserved. This effectively pins the outermost verticies on their
original position and the operation thus only deforms the inner
content of the image.

- **`normalize`** : If true, the field will be normalized its norm.
This will have the effect that the `scale` factor should be more or
less independent of the grid size.

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

    # Randomly distort the image using a 10x15 displacement field
    img_new = transform(RandomDisplacement(10, 15; scale = .1), img)

see also
=========

`SmoothedDisplacement`

`uniform_displacement`, `ImageTransformation`, `transform`
"""
immutable RandomDisplacement <: ImageTransformation
    gridwidth::Int
    gridheight::Int
    scale::Float64
    static_border::Bool
    normalize::Bool
end

function RandomDisplacement(gridwidth::Real, gridheight::Real; scale = .2, static_border::Bool = true, normalize::Bool = true)
    (gridwidth > 2 && gridheight > 2) || throw(ArgumentError("gridwidth and gridheight need to be greater than 2"))
    RandomDisplacement(Int(gridwidth), Int(gridheight), Float64(scale), static_border, normalize)
end

Base.showcompact(io::IO, op::RandomDisplacement) = print(io, "Displace with random $(op.gridwidth)x$(op.gridheight) displacement field.")
multiplier(::RandomDisplacement) = 1 # not true, basically infinity...

function transform{T<:AbstractImage}(op::RandomDisplacement, img::T)
    df = uniform_displacement(op.gridwidth, op.gridheight, op.scale, op.static_border, op.normalize)
    transform(df, img)::T
end

