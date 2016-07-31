using Augmentor
using Images
using TestImages
using VisualRegressionTests
using Plots

ENV["MPLBACKEND"] = "Agg"
try
    @eval import PyPlot
    info("Matplotlib version: $(PyPlot.matplotlib[:__version__])")
end
pyplot(size=(200,150), reuse=true)

if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

refdir = Pkg.dir("Augmentor", "test", "refimg")
testimg = load(joinpath(refdir, "testimage.png"))

function imagetest_impl(testname, testfun)
    srand(1)
    refimgpath = joinpath(refdir, "$testname.png")
    result = test_images(VisualTest(testfun, refimgpath))
    @test success(result)
end

macro plottest(testname, expr)
    esc(quote
        imagetest_impl(string($testname), fn -> begin
            $expr
            png(fn)
        end)
    end)
end

macro imagetest(testname, expr)
    esc(quote
        imagetest_impl(string($testname), path -> begin
            save(path, $expr)
        end)
    end)
end

type FaultyOp <: Augmentor.ImageOperation end

tests = [
    ("tst_displacementfield.jl", "Low-level functionality for image displacement"),
    ("tst_common.jl", "Utility methods"),
    ("tst_rotate.jl", "Low-level functionality for image rotation"),
    ("tst_crop.jl", "Low-level functionality for image cropping"),
    ("tst_imageoperation.jl", "High-level abstractions for image operations"),
    ("tst_imagesource.jl", "High-level abstractions for image sources"),
    ("tst_pipeline.jl", "Pipeline implementations"),
    ("tst_MLDataUtils.jl", "Data Access Pattern integration"),
]

for (fn, desc) in tests
    @testset "$desc ($fn)" begin
        include(fn)
    end
end

