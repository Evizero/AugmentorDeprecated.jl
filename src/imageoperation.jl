
abstract ImageOperation

# ========================================

@defstruct FlipX <: ImageOperation (
    (chance::Float64 = .5, 0 < chance <= 1),
)

@inline perform(op::FlipX, img) = hit_chance(op.chance) ? flipdim(img, 1) : img

# ========================================

@defstruct FlipY <: ImageOperation (
    (chance::Float64 = .5, 0 < chance <= 1),
)

@inline perform(op::FlipY, img) = hit_chance(op.chance) ? flipdim(img, 2) : img


