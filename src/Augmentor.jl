module Augmentor

using Images
using AffineTransforms
using Interpolations
using SimpleStructs

export

    rotate_expand,
    rotate_crop,

    ImageOperation,
        FlipX,
        FlipY,

    Pipeline,
        LinearPipeline,

    perform

include("common.jl")
include("rotate.jl")
include("imageoperation.jl")
include("pipeline.jl")

end # module
