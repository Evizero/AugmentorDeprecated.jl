module Augmentor

using Images
using AffineTransforms
using Interpolations
using SimpleStructs

export

    rotate_expand,
    rotate_crop,

include("common.jl")
include("rotate.jl")

end # module
