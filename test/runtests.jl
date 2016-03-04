using Augmentor
using FactCheck

tests = [
    ("tst_common.jl", "Utility methods"),
]

for (fn, desc) in tests
    facts("$desc ($fn)") do
        include(fn)
    end
end

FactCheck.exitstatus()
