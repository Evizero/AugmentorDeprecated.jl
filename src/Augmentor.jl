module Augmentor

using RecipesBase
using Requires
using Images
using AffineTransforms
using ColorTypes
using PiecewiseAffineTransforms
using Interpolations

export

    rotate_expand,
    rotate_crop,

    DisplacementField,
        uniform_displacement,
        gaussian_displacement,

    DisplacementMesh,

    ImageTransformation,
        Either,
        NoOp,
        FlipX,
        FlipY,
        Rotate90,
        Rotate180,
        Rotate270,
        Resize,
        CropRatio,
        CropSize,
        RCropSize,
        RCropRatio,
        Crop,
        Zoom,
        Scale,
        RandomDisplacement,
        SmoothedDisplacement,

    multiplier,

    ImageSource,
        DirImageSource,

    Pipeline,

    transform

include("common.jl")

include("rotate.jl")
include("crop.jl")

include("imagetransformation.jl")

include("displacementfield.jl")
include("displacementmesh.jl")

include("transformations/flipx.jl")
include("transformations/flipy.jl")
include("transformations/resize.jl")
include("transformations/cropratio.jl")
include("transformations/cropsize.jl")
include("transformations/rcropsize.jl")
include("transformations/rcropratio.jl")
include("transformations/crop.jl")
include("transformations/zoom.jl")
include("transformations/scale.jl")
include("transformations/rotate90.jl")
include("transformations/rotate180.jl")
include("transformations/rotate270.jl")
include("transformations/randomdisplacement.jl")
include("transformations/smootheddisplacement.jl")

include("imagesource.jl")
include("dirimagesource.jl")

include("pipeline.jl")
include("linearpipeline.jl")

# Lazy loading for package integrations
@require MLDataUtils include("integrations/MLDataUtils.jl")

end

