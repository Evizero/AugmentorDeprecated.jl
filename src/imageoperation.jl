abstract ImageOperation

multiplier(::ImageOperation) = throw(ArgumentError("Every ImageOperation needs to specify a multiplication factor"))

# ========================================

@defstruct FlipX <: ImageOperation (
    (chance::Float64 = .5, 0 <= chance <= 1),
)

Base.show(io::IO, op::FlipX) = print(io, "FlipX with $(op.chance*100) % chance")
multiplier(::FlipX) = 2

@inline function transform{T}(op::FlipX, img::T)
    if hit_chance(op.chance)
        flipx(img)
    else
        img
    end::T
end

# ========================================

@defstruct FlipY <: ImageOperation (
    (chance::Float64 = .5, 0 <= chance <= 1),
)

Base.show(io::IO, op::FlipY) = print(io, "FlipY with $(op.chance*100) % chance")
multiplier(::FlipY) = 2

@inline function transform{T}(op::FlipY, img::T)
    if hit_chance(op.chance)
        flipy(img)
    else
        img
    end::T
end

# ========================================

@defstruct Resize <: ImageOperation (
    (width::Int  = 64, 1 <= width),
    (height::Int = 64, 1 <= height),
)

Base.show(io::IO, op::Resize) = print(io, "Resize to $(op.width)x$(op.height)")
multiplier(::Resize) = 1

@inline function transform{T}(op::Resize, img::T)
    if isxfirst(img)
        Images.imresize(img, (op.width, op.height))
    else
        Images.imresize(img, (op.height, op.width))
    end::T
end

