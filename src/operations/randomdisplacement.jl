"""
`RandomDisplacement <: ImageOperation`

Description
============

Distorts the given image using a randomly generated (uniform)
`DisplacementField` of the given grid size. This field will be
streched over the given image and converted into a `DisplacementMesh`,
which in turn will morph the original image into a new image using
piecewise affine transformations.

Usage
======

    RandomDisplacement(gridwidth, gridheight; scale = 0.2, static_border = true, normalize = true)

Arguments
==========

- **`gridwidth`** :

- **`gridheight`** :

- **`scale`** :

- **`static_border`** :

- **`normalize`** :

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

`uniform_displacement`, `ImageOperation`, `transform`
"""
immutable RandomDisplacement <: ImageOperation
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

