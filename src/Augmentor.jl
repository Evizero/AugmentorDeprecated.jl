module Augmentor

using Images
using AffineTransforms
using Interpolations
using SimpleStructs

export

    rotate_expand,
    rotate_crop,

    flipx,
    flipy,
    flipz,

    ImageOperation,
        FlipX,
        FlipY,
        Resize,

    multiplier,

    ImageSource,
        DirImageSource,

    Pipeline,
        LinearPipeline,

    transform

include("common.jl")
include("rotate.jl")
include("flipdim.jl")
include("imageoperation.jl")
include("imagesource.jl")
include("dirimagesource.jl")
include("pipeline.jl")

end

