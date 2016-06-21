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

multiplier(::ImageOperation) = throw(ArgumentError("Every ImageOperation needs to specify a multiplication factor"))

# TODO: make this cleaner for dispatch
@inline function transform(op::ImageOperation, imgs) #::Tuple)
    transform(op, imgs[1]), transform(op, imgs[2])
end

function _log_operation!(img::Image, op::ImageOperation)
    history = get!(properties(img), "operations", Array{ImageOperation,1}())
    push!(history, op)
    img
end

# ==========================================================

"""
`NoOp <: ImageOperation`

Identity operation that does not do anything with the given image
but instead passes it through unchanged and uncopied.

Mainly used is in combination with `Either`
"""
immutable NoOp <: ImageOperation
end

Base.showcompact(io::IO, op::NoOp) = print(io, "No operation.")
multiplier(po::NoOp) = 1
transform{T}(po::NoOp, img::T) = img

# ==========================================================

"""
`Either <: ImageOperation`

Description
============

    Allows for choosing between different ImageOperations at random.
    This is particularly useful if one for example wants to first
    either rotate the image 90 degree clockwise or anticlockwise
    (but never both) and then apply some other operation(s)
    afterwards.

    By default each specified image operation has the same probability
    of occurance. This default behaviour can be overwritten by
    specifying the parameter `chance` manually

Usage
======

    Either(operations; chance = ones(length(operations))/length(operations))

    Either(operations...; chance = ones(length(operations))/length(operations))

Arguments
==========

- **`operations`** : Vector of `ImageOperation`. Defines all distinct
image operations to choose from.

- **`chance`** : Vector of `Float64`. Probabilities or ratio for each
individual image operations in `operations` to occur. Has to be the
same length as `operations`.

Methods
========

- **`transform`** : When called, applies one of the image operations
in `operations` at random according to the specified probabilities
in `chance`.

- **`multiplier`** : Specifies how many unique output variations
the operation can result in. In this case this is the sum of the
multiplier for each image operation specified in `operations`

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
========

    using Augmentor
    using TestImages

    # load an example image
    img = testimage("lena")

    # Specify operation to either apply FlipX, FlipY, or do nothing
    # Each operation as equal probability to occur
    op = Either(FlipX(), FlipY(), NoOp())

    # Apply random operation
    img_new = transform(op, img)

    # Same as before but with a 80% chance to do nothing
    op = Either(FlipX(), FlipY(), NoOp(); chance = [.1, .1, .8])
    img_new = transform(op, img)

see also
=========

`transform`, `ImageOperation`, `NoOp`
"""
immutable Either <: ImageOperation
    operations::Vector{ImageOperation}
    chance::Vector{Float64}
    cum_chance::Vector{Float64}

    function Either(operations::Vector{ImageOperation}; chance::Vector{Float64} = ones(length(operations))/length(operations))
        length(operations) > 0 || throw(ArgumentError("number of specified image operations need to be greater than 0"))
        length(operations) == length(chance) || throw(ArgumentError("length of chance has to be equal the number of specified image operations"))
        sum_chance = sum(chance)
        @assert sum_chance > 0.
        chance = chance ./ sum_chance
        cum_chance = cumsum(chance)
        new(operations, chance, cum_chance)
    end
end

Either(args::ImageOperation...; nargs...) = Either(collect(ImageOperation, args); nargs...)

function ProbableOperation{T<:ImageOperation}(op::T; chance::Real = .5)
    0 <= chance <= 1. || throw(ArgumentError("chance has to be between 0 and 1"))
    p1 = Float64(chance)
    p2 = 1 - p1
    Either(op, NoOp(), chance = [p1, p2])
end

function Base.show(io::IO, op::Either)
    print(io, "Either (1 out of ", length(op.operations), " operation(s))")
    for (op_i, p_i) in zip(op.operations, op.chance)
        println(io)
        print(io, "  - ", round(p_i*100, 1), "% chance to: ")
        Base.showcompact(io, op_i)
    end
end

function Base.showcompact(io::IO, op::Either)
    print(io, "Either:")
    for (op_i, p_i) in zip(op.operations, op.chance)
        print(io, " (", round(Int, p_i*100), "%) ")
        Base.showcompact(io, op_i)
    end
end

function multiplier(op::Either)
    m = 0
    for (op_i, p_i) in zip(op.operations, op.chance)
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
            return transform(op.operations[i], img)
        end
    end
    img
end

