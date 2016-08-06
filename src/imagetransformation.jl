"""
`abstract ImageTransformation`

Description
============

Abstract supertype for all image transformation. Every subtype of
`ImageTransformation` must implement the `transform` and the `multiplier`
methods.

Methods
========

- **`transform`** : Applies the transformation to the given Image
or set of images. This effectifely specifies the exact effect the
transformation has on the input it receives

- **`multiplier`** : Specifies how many unique output variations
the transformation can result in (counting the case of not being applied
to the input).

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

see also
=========

`transform`, `Either`
"""
abstract ImageTransformation

multiplier(::ImageTransformation) = throw(ArgumentError("Every ImageTransformation needs to specify a multiplication factor"))

# TODO: make this cleaner for dispatch
@inline function transform(op::ImageTransformation, imgs) #::Tuple)
    transform(op, imgs[1]), transform(op, imgs[2])
end

function _log_operation!(img::Image, op::ImageTransformation)
    history = get!(properties(img), "transformations", Array{ImageTransformation,1}())
    push!(history, op)
    img
end

# ==========================================================

"""
`NoOp <: ImageTransformation`

Identity transformation that does not do anything with the given image
but instead passes it through unchanged and uncopied.

Mainly used is in combination with `Either`
"""
immutable NoOp <: ImageTransformation
end

Base.showcompact(io::IO, op::NoOp) = print(io, "No transformation.")
multiplier(po::NoOp) = 1
transform{T}(po::NoOp, img::T) = img

# ==========================================================

"""
`Either <: ImageTransformation`

Description
============

    Allows for choosing between different `ImageTransformation` at random.
    This is particularly useful if one for example wants to first
    either rotate the image 90 degree clockwise or anticlockwise
    (but never both) and then apply some other transformation(s)
    afterwards.

    By default each specified image transformation has the same probability
    of occurance. This default behaviour can be overwritten by
    specifying the parameter `chance` manually

Usage
======

    Either(transformations; chance = ones(length(transformations))/length(transformations))

    Either(transformations...; chance = ones(length(transformations))/length(transformations))

Arguments
==========

- **`transformations`** : Vector of `ImageTransformation`. Defines all
distinct image transformations to choose from.

- **`chance`** : Vector of `Float64`. Probabilities or ratio for each
individual image transformations in `transformations` to occur.
Has to be the same length as `transformations`.

Methods
========

- **`transform`** : When called, applies one of the image transformations
in `transformations` at random according to the specified probabilities
in `chance`.

- **`multiplier`** : Specifies how many unique output variations
the transformation can result in. In this case this is the sum of the
multiplier for each image transformation specified in `transformations`

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
========

    using Augmentor
    using TestImages

    # load an example image
    img = testimage("lena")

    # Specify transformation to either apply FlipX, FlipY, or do nothing
    # Each transformation as equal probability to occur
    op = Either(FlipX(), FlipY(), NoOp())

    # Apply random transformation
    img_new = transform(op, img)

    # Same as before but with a 80% chance to do nothing
    op = Either(FlipX(), FlipY(), NoOp(); chance = [.1, .1, .8])
    img_new = transform(op, img)

see also
=========

`transform`, `ImageTransformation`, `NoOp`
"""
immutable Either <: ImageTransformation
    transformations::Vector{ImageTransformation}
    chance::Vector{Float64}
    cum_chance::Vector{Float64}

    function Either(transformations::Vector{ImageTransformation}; chance::Vector{Float64} = ones(length(transformations))/length(transformations))
        length(transformations) > 0 || throw(ArgumentError("number of specified image transformations need to be greater than 0"))
        length(transformations) == length(chance) || throw(ArgumentError("length of chance has to be equal the number of specified image transformations"))
        sum_chance = sum(chance)
        @assert sum_chance > 0.
        chance = chance ./ sum_chance
        cum_chance = cumsum(chance)
        new(transformations, chance, cum_chance)
    end
end

Either(args::ImageTransformation...; nargs...) = Either(collect(ImageTransformation, args); nargs...)

function ProbableOperation{T<:ImageTransformation}(op::T; chance::Real = .5)
    0 <= chance <= 1. || throw(ArgumentError("chance has to be between 0 and 1"))
    p1 = Float64(chance)
    p2 = 1 - p1
    Either(op, NoOp(), chance = [p1, p2])
end

function Base.show(io::IO, op::Either)
    print(io, "Either (1 out of ", length(op.transformations), " transformation(s))")
    for (op_i, p_i) in zip(op.transformations, op.chance)
        println(io)
        print(io, "  - ", round(p_i*100, 1), "% chance to: ")
        Base.showcompact(io, op_i)
    end
end

function Base.showcompact(io::IO, op::Either)
    print(io, "Either:")
    for (op_i, p_i) in zip(op.transformations, op.chance)
        print(io, " (", round(Int, p_i*100), "%) ")
        Base.showcompact(io, op_i)
    end
end

function multiplier(op::Either)
    m = 0
    for (op_i, p_i) in zip(op.transformations, op.chance)
        if p_i > 0
            m += multiplier(op_i)
        end
    end
    m
end

function transform(op::Either, img)
    p = rand()
    for (i, p_i) in enumerate(op.cum_chance)
        if p <= p_i
            return transform(op.transformations[i], img)
        end
    end
    img
end

