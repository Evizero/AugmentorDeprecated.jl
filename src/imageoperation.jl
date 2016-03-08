
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

