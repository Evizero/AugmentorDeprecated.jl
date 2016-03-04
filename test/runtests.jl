using Augmentor
using FactCheck

tests = [
    ("tst_common.jl", "Utility methods"),
    ("tst_rotate.jl", "Low-level functionality for image rotation"),
]

for (fn, desc) in tests
    facts("$desc ($fn)") do
        include(fn)
    end
end

FactCheck.exitstatus()
