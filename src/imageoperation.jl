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


