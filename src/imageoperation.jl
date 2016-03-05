
abstract ImageOperation

# ========================================

@defstruct FlipX <: ImageOperation (
    (chance::Float64 = .5, 0 < chance <= 1),
)

@inline function perform{T}(op::FlipX, img::T)
    if hit_chance(op.chance)
        flipdim(img, 1)
    else
        img
    end::T
end

# ========================================

@defstruct FlipY <: ImageOperation (
    (chance::Float64 = .5, 0 < chance <= 1),
)

@inline function perform{T}(op::FlipY, img::T)
    if hit_chance(op.chance)
        flipdim(img, 2)
    else
        img
    end::T
end


