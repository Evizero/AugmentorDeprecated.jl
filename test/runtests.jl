using Augmentor
using Images
using TestImages
using FactCheck

type FaultyOp <: Augmentor.ImageOperation end

tests = [
    ("tst_common.jl", "Utility methods"),
    ("tst_rotate.jl", "Low-level functionality for image rotation"),
    ("tst_flipdim.jl", "Low-level functionality for image mirroring"),
    ("tst_imageoperation.jl", "High-level abstractions for imager operations"),
]

for (fn, desc) in tests
    facts("$desc ($fn)") do
        include(fn)
    end
end

FactCheck.exitstatus()
