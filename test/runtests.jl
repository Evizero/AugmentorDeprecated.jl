using Augmentor
using Images
using TestImages
using VisualRegressionTests

if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

refdir = Pkg.dir("Augmentor", "test", "refimg")
testimg = load(joinpath(refdir, "testimage.png"))

function imagetest_impl(testname, testfun)
    refimgpath = joinpath(refdir, "$testname.png")
    result = test_images(VisualTest(testfun, refimgpath))
    @test success(result)
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

