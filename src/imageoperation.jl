abstract ImageOperation

function _log_operation!(op::ImageOperation, img::Image)
    history = get!(properties(img), "operations", Array{ImageOperation,1}())
    push!(history, op)
    img
end

multiplier(::ImageOperation) = throw(ArgumentError("Every ImageOperation needs to specify a multiplication factor"))

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

# ==========================================================

immutable FlipX <: ImageOperation
end

FlipX(chance) = ProbableOperation(FlipX(); chance = chance)

Base.show(io::IO, op::FlipX) = print(io, "Flip x-axis.")
multiplier(::FlipX) = 2

@inline function transform{T<:AbstractImage}(op::FlipX, img::T)
    result = copyproperties(img, flipx(img))::T
    _log_operation!(op, result)
end

# ==========================================================

immutable FlipY <: ImageOperation
end

FlipY(chance) = ProbableOperation(FlipY(); chance = chance)

Base.show(io::IO, op::FlipY) = print(io, "Flip y-axis.")
multiplier(::FlipY) = 2

@inline function transform{T<:AbstractImage}(op::FlipY, img::T)
    result = copyproperties(img, flipy(img))::T
    _log_operation!(op, result)
end

# ==========================================================

@defstruct Resize <: ImageOperation (
    (width::Int  = 64, 1 <= width),
    (height::Int = 64, 1 <= height),
)

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

