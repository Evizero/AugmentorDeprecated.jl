"""
`SmoothedDisplacement <: ImageTransformation`

Description
============

Distorts the given image using a randomly (uniform) generated
`DisplacementField` of the given grid size. This field will be
streched over the given image and converted into a `DisplacementMesh`.
which in turn will morph the original image into a new image using
piecewise affine transformations.

In contrast to `RandomDisplacement`, the resulting vector field is
also smoothed using a gaussian filter with of parameter `sigma`.
This will result in a less chaotic displacement field and be much
more similar to an elastic distortion.

Usage
======

    SmoothedDisplacement(gridwidth, gridheight[, scale=0.2, sigma=2, iterations=1, static_border=true, normalize=true])

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

- **`sigma`** : Sigma parameter of the gaussian filter.
This parameter effectively controls the strength of the smoothing.

- **`iterations`** : The number of times the smoothing operation
is applied to the `DisplacementField`. This is especially useful
if `static_border == true` because the border will be reset to
zero after each pass. Thus the displacement is a little less
aggressive towards the borders of the image than it is towards
its center.

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

    # Randomly distort the image using a smoothed 10x15 displacement field
    img_new = transform(SmoothedDisplacement(10, 15; scale = .1, sigma = 3), img)

see also
=========

`RandomDisplacement`

`uniform_displacement`, `ImageTransformation`, `transform`
"""
immutable SmoothedDisplacement <: ImageTransformation
    gridwidth::Int
    gridheight::Int
    scale::Float64
    sigma::Float64
    iterations::Int
    static_border::Bool
    normalize::Bool
end

function SmoothedDisplacement(gridwidth::Real, gridheight::Real; scale = .2, sigma = 2, iterations = 1, static_border::Bool = true, normalize::Bool = true)
    (gridwidth > 2 && gridheight > 2) || throw(ArgumentError("gridwidth and gridheight need to be greater than 2"))
    sigma > 0 || throw(ArgumentError("sigma needs to be greater than 0"))
    iterations > 0 || throw(ArgumentError("iterations needs to be greater than 0"))
    SmoothedDisplacement(Int(gridwidth), Int(gridheight), Float64(scale), Float64(sigma), Int(iterations), static_border, normalize)
end

Base.showcompact(io::IO, op::SmoothedDisplacement) = print(io, "Displace randomly with smoothed $(op.gridwidth)x$(op.gridheight) displacement field (σ = $(op.sigma)).")
multiplier(::SmoothedDisplacement) = 1 # not true, basically infinity...

function transform{T<:AbstractImage}(op::SmoothedDisplacement, img::T)
    df = gaussian_displacement(op.gridwidth, op.gridheight, op.scale, op.sigma, op.iterations, op.static_border, op.normalize)
    transform(df, img)::T
end

