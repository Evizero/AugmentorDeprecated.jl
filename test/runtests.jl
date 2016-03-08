using Augmentor
using Images
using TestImages
using FactCheck

tests = [
    ("tst_common.jl", "Utility methods"),
    ("tst_rotate.jl", "Low-level functionality for image rotation"),
    ("tst_flipdim.jl", "Low-level functionality for image mirroring"),
]

for (fn, desc) in tests
    facts("$desc ($fn)") do
        include(fn)
    end
end

FactCheck.exitstatus()
