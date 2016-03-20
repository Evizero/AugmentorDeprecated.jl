using Augmentor
using Images
using TestImages

if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

type FaultyOp <: Augmentor.ImageOperation end

tests = [
    ("tst_common.jl", "Utility methods"),
    ("tst_rotate.jl", "Low-level functionality for image rotation"),
    ("tst_flipdim.jl", "Low-level functionality for image mirroring"),
    ("tst_imageoperation.jl", "High-level abstractions for image operations"),
    ("tst_imagesource.jl", "High-level abstractions for image sources"),
    ("tst_pipeline.jl", "Pipeline implementations"),
]

for (fn, desc) in tests
    @testset "$desc ($fn)" begin
        include(fn)
    end
end

