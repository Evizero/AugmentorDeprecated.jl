module Augmentor

using Images
using AffineTransforms
using Interpolations

export

    rotate_expand,
    rotate_crop

include("rotate.jl")

end # module
