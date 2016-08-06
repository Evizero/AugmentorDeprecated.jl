"""
`DisplacementField <: ImageOperation`

Description
============

A displacement field is an image-size agnostic specification of a
elastic deformation for images with two spatial dimensions and one
color channel. The term "image-size agnostic" means that once
defined, the deformation can be applied to arbitrarily sized images.

As a programmer one can think of a displacement field as a 2d grid
of small 2d vectors placed on each position of said grid.
The positions themself need not be equally spaced. However, both
(x and y) coordinates for each of these positions must be within
the interval [0, 1]. This way the positions are on a relative scale
and can be streched to any image width and height.
The positions are meant to denote reference points of the input image.
Each position has a vector placed on it to specify where the pixel
located on the reference point of the input image should end up on
the output image (so a translation vector basically).

The grid usually has a lot less of these reference points than the
image has pixels. The two reason for this are performance on the
one hand, and also that grids are intended to be used with arbitrary
sized images.
As a consequence of this all the pixel inbetween reference points
need to be interpolated in some form. On way to do that is using
piecewise affine transformations, which is how a DisplacementMesh
does it. See the documentation of DisplacementMesh for more
information.

Usage
======

    DisplacementField(x, y, delta_X, delta_Y)

    DisplacementField(delta_X, delta_Y)

Arguments
==========

- **`x`** : The horizontal component of the position for the
displacement vectors in the field. If not specified then
a uniformly spaced grid will be generated automatically.
Note that this must be a one dimensional array (a vector).

- **`y`** : The vertical component of the position for the
displacement vectors in the field. If not specified then
a uniformly spaced grid will be generated automatically.
Note that this must be a one dimensional array (a vector).

- **`delta_X`** : The horizontal components of each of the
displacement vectors themselves. They essentially specify how
much each of the references point should be translated along the
horizontal axis.
Note that this must be a two dimensional array (a matrix).

- **`delta_Y`** : The vertical components of each of the
displacement vectors themselves. They essentially specify how
much each of the references point should be translated along the
vertical axis.
Note that this must be a two dimensional array (a matrix).

Methods
========

- **`transform`** : Applies the transformation to the given Image
or set of images

Details
========

Another way that a displacement field can be thought about is
in terms of a discrete two-dimensional vector field of a domain
D ⊂ U × V, where U = {i ∈ R | 0 ≤ i ≤ 1}, and V = {j ∈ R | 0 ≤ j ≤ 1}.
Note that U and V are distinct sets, and that vectors along the
first the dimension share the second dimension and vice versa.
This way later triangulation is trivial, because the position
points will allways be layed out in terms of rectangles.

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
========

    using Augmentor
    using TestImages

    # load an example image
    img = testimage("lena")

    # Randomly distort the image using a 10x15 smoothed displacement field
    field = gaussian_displacement(10, 15)
    @assert typeof(field) <: DisplacementField
    img_new = transform(field, img)

see also
=========

`uniform_displacement`, `gaussian_displacement`

`RandomDisplacement`, `SmoothedRandomDisplacement`

`ImageOperation`, `transform`
"""
immutable DisplacementField <: ImageOperation
    x::Vector{Float64}
    y::Vector{Float64}
    delta_X::Matrix{Float64}
    delta_Y::Matrix{Float64}

    function DisplacementField(x::AbstractVector{Float64}, y::AbstractVector{Float64}, delta_X::Matrix{Float64}, delta_Y::Matrix{Float64})
        @assert length(x) == size(delta_X, 2) == size(delta_Y, 2)
        @assert length(y) == size(delta_X, 1) == size(delta_Y, 1)
        @assert issorted(x) && issorted(y)
        @assert minimum(x) >= 0 && maximum(x) <= 1
        @assert minimum(y) >= 0 && maximum(y) <= 1
        new(convert(Vector{Float64}, x), convert(Vector{Float64},y), delta_X, delta_Y)
    end

    function DisplacementField(delta_X::Matrix{Float64}, delta_Y::Matrix{Float64})
        x = linspace(0, 1, size(delta_X,2))
        y = linspace(0, 1, size(delta_X,1))
        DisplacementField(x, y, delta_X, delta_Y)
    end
end

function Base.show(io::IO, df::DisplacementField)
    print(io, "DisplacementField (width: $(length(df.x)), height: $(length(df.y)))")
end

Base.showcompact(io::IO, df::DisplacementField) = print(io, "Displace with $(length(df.x))x$(length(df.y)) displacement field.")
multiplier(::DisplacementField) = 1 # not true, basically infinity...

@recipe function plot(df::DisplacementField, img::Image)
    @series begin
        seriestype := :image
        img
    end
    df, size(img, "x"), size(img, "y")
end

@recipe function plot(df::DisplacementField, width = 1, height = 2)
    h, w = size(df.delta_X)

    yflip := true
    seriestype := :quiver

    quiver := vec([(Float64(df.delta_X[i,j] * width), Float64(df.delta_Y[i,j] * height)) for i=1:h, j=1:w])

    vec([(df.x[j] * width, df.y[i] * height) for i=1:h, j=1:w])
end

function transform{T<:AbstractImage}(df::DisplacementField, img::T)
    dm = DisplacementMesh(df, img)
    result = _transform(dm, img)::T
    _log_operation!(result, df)::T
end

# uniform displacement

"""
`uniform_displacement(gridwidth, gridheight[, scale=0.2, static_border=true, normalize=true])` → `DisplacementField`

Generates a `DisplacementField` by placing uniformly random
generated displacement vectors on an equally space grid of size
`gridheight × gridwidth`.

Note that the resulting `DisplacementField` will remain static,
which means that it will always perform the same displacement.
If one wants to apply a different random displacement on every use
then `RandomDisplacement` should be used instead.

see `RandomDisplacement` for more information on the parameters.
"""
function uniform_displacement(gridwidth::Int, gridheight::Int, scale::Real, static_border::Bool = true, normalize::Bool = true)
    delta_X = _1d_uniform_displacement(gridwidth, gridheight, Float64(scale), static_border, normalize)
    delta_Y = _1d_uniform_displacement(gridwidth, gridheight, Float64(scale), static_border, normalize)
    DisplacementField(delta_X, delta_Y)
end

function uniform_displacement(gridwidth::Int, gridheight::Int; scale = .2, static_border = true, normalize = true)
    uniform_displacement(gridwidth, gridheight, scale, static_border, normalize)
end

function _1d_uniform_displacement(gridwidth::Int, gridheight::Int, scale::Float64, static_border::Bool, normalize::Bool)
    A = if static_border
        @assert gridwidth > 2 && gridheight > 2
        A_t = rand(gridheight, gridwidth)
        _set_border!(A_t, .5)
    else
        @assert gridwidth > 0 && gridheight > 0
        rand(gridheight, gridwidth)
    end::Matrix{Float64}
    broadcast!(*, A, A, 2.)
    broadcast!(-, A, A, 1.)
    if normalize
        broadcast!(*, A, A, scale / norm(A))
    end
    A
end

# gaussian displacement fields

"""
`gaussian_displacement(gridwidth, gridheight[, scale=0.2, sigma=2, iterations=1, static_border=true, normalize=true])` → `DisplacementField`

Generates a `DisplacementField` by placing uniformly random
generated displacement vectors on an equally space grid of size
`gridheight × gridwidth`. In addition, this vectorfield is smoothed
using a gaussian kernel of size `sigma × sigma`. This will result
in a less chaotic displacement field and be much more similar to
an elastic distortion.

Note that the resulting `DisplacementField` will remain static,
which means that it will always perform the same displacement.
If one wants to apply a different random displacement on every use
then `SmoothedRandomDisplacement` should be used instead.

see `SmoothedRandomDisplacement` for more information on the parameters.
"""
function gaussian_displacement(gridwidth::Int, gridheight::Int, scale::Real, sigma::Vector{Float64}, iterations::Int = 1, static_border::Bool = true, normalize::Bool = true)
    delta_X = _1d_gaussian_displacement(gridwidth, gridheight, Float64(scale), sigma, iterations, static_border, normalize)
    delta_Y = _1d_gaussian_displacement(gridwidth, gridheight, Float64(scale), sigma, iterations, static_border, normalize)
    DisplacementField(delta_X, delta_Y)
end

function gaussian_displacement(gridwidth::Int, gridheight::Int, scale::Real, sigma::Real, iterations::Int = 1, static_border::Bool = true, normalize::Bool = true)
    gaussian_displacement(gridwidth, gridheight, Float64(scale), [Float64(sigma), Float64(sigma)], iterations, static_border, normalize)
end

function gaussian_displacement(gridwidth::Int, gridheight::Int; scale = .2, sigma = 2, iterations = 1, static_border = true, normalize = true)
    gaussian_displacement(gridwidth, gridheight, scale, sigma, iterations, static_border, normalize)
end

function _1d_gaussian_displacement(gridwidth::Int, gridheight::Int, scale::Float64, sigma::Vector{Float64}, iterations::Int, static_border::Bool, normalize::Bool)
    @assert length(sigma) == 2
    @assert all(sigma .> 0)
    @assert iterations > 0
    A = if static_border
        A_t = _1d_uniform_displacement(gridwidth, gridheight, 1., false, false)
        _set_border!(A_t, 0.)
        for iter = 1:iterations
            Images.imfilter_gaussian_no_nans!(A_t, sigma)
            _set_border!(A_t, 0.)
        end
        A_t
    else
        A_t = _1d_uniform_displacement(gridwidth, gridheight, 1., false, false)
        for iter = 1:iterations
            Images.imfilter_gaussian_no_nans!(A_t, sigma)
        end
        A_t
    end::Matrix{Float64}
    if normalize
        broadcast!(*, A, A, scale / norm(A))
    end
    A
end

function _set_border!{T}(A::Matrix{T}, val::T)
    h, w = size(A)
    @inbounds for i = 1:h, j = [1,w]
        A[i,j] = val
    end
    @inbounds for i = [1,h], j = 1:w
        A[i,j] = val
    end
    A
end

