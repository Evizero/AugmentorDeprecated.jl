module Augmentor

using Requires
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
        Rotate90,
        Rotate180,
        Rotate270,
        Resize,

    multiplier,

    ImageSource,
        DirImageSource,

    Pipeline,
        LinearPipeline,

    transform

include("common.jl")
include("rotate.jl")
include("imageoperation.jl")
include("imagesource.jl")
include("dirimagesource.jl")
include("pipeline.jl")
include("linearpipeline.jl")

# Lazy loading for package integrations
@require MLDataUtils include("integrations/MLDataUtils.jl")

end

