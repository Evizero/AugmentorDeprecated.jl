# Augmentor

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)
[![Documentation Status](https://readthedocs.org/projects/augmentorjl/badge/?version=latest)](http://augmentorjl.readthedocs.io/en/latest/?badge=latest)

Augmentor is an image-augmentation library designed to render the
process of artificial dataset enlargement more convenient, less
error prone, and easier to reproduce.
This is achieved using probabilistic transformation pipelines.

The following code snipped shows how such a pipeline can be
specified using simple building blocks. To show the effect we
compiled a few resulting output images into a gif while using
the famous lena image as input.

```julia
LinearPipeline(Rotate90(.5), Rotate270(.5), FlipX(.5), FlipY(.5), RCropSize(128, 128), Resize(64, 64))
```

Input                               | Output
:----------------------------------:|:------------------------------:
![lena](https://cloud.githubusercontent.com/assets/10854026/16039252/03ce762e-3229-11e6-8670-a25cf9a149ca.png) | ![pipeline](https://cloud.githubusercontent.com/assets/10854026/16039237/f252481c-3228-11e6-84b0-c20f796270d9.gif)

**Augmentor.jl** is the [Julia](http://julialang.org) package
for *Augmentor*. You can find the Python version
[here](https://github.com/mdbloice/Augmentor).

## Installation

To install Augmentor.jl, start up Julia and type the following code
snipped into the REPL. It makes use of the native Julia package
manager.

```julia
Pkg.clone("git@github.com:Evizero/Augmentor.jl.git")
```

Additionally, for example if you encounter any sudden issues,
you can manually choose to be on the latest (untagged)
development version.

[![Build Status](https://travis-ci.org/Evizero/Augmentor.jl.svg?branch=master)](https://travis-ci.org/Evizero/Augmentor.jl)
[![Coverage Status](https://coveralls.io/repos/github/Evizero/Augmentor.jl/badge.svg?branch=master)](https://coveralls.io/github/Evizero/Augmentor.jl?branch=master)

```julia
Pkg.checkout("Augmentor")
```

## Usage

Once installed the Augmentor package can be imported just as any
other Julia package.

```julia
using Augmentor
```

## Documentation


Check out the **[latest documentation](http://augmentorjl.readthedocs.io/en/latest/index.html)**

Additionally, you can make use of Julia's native docsystem.
The following example shows how to get additional information
on `DirImageSource` within Julia's REPL:

```julia
?DirImageSource
```

## Overview

There are three basic building-blocks to create a system for image
augmentation, namely an *image source*, *image transformations*, and
an *image operation pipeline*.

- `ImageSouce`: Functionality to access images from some data source,
such as a directory.

- `Pipeline` (*DEPRECATED*): A chain or tree of (probabilistic) transformations that
should be applied to a given image, or set of images.

- `ImageTransformation`: As the name suggests concrete subclasses define
a specific transformation that can be applied to an image, or a set
of images. Operations can also be lifted into a `Either`,
which have a random probability of occuring, depending on the
hyperparameter `chance`.

### Examples

The following code shows how to create a simple probabilistic
pipeline, which can be sampled on the fly:

```julia
# load an example image
using TestImages
img = testimage("toucan")

# create empty pipeline
pl = LinearPipeline()

# add transformations to pipeline
push!(pl, FlipX(0.5))     # lifted to Either(FlipX(), NoOp()). 50% chance of occuring
push!(pl, FlipY())        # not lifted. will always occur
push!(pl, CropRatio(1.5)) # crop out biggest area that satisfies aspect ration
push!(pl, Resize(64,64))

# transform example image
img_new = transform(pl, img)
```

```
RGBA Images.Image with:
  data: 64x64 Array{ColorTypes.RGBA{FixedPointNumbers.UFixed{UInt8,8}},2}
  properties:
    transformations:  Flip x-axis. Flip y-axis. Crop to 1.5 aspect ratio. Resize to 64x64.
    imagedescription: <suppressed>
    spatialorder:  x y
    pixelspacing:  1 1
```

Input (`img`)                       | Output (`img_new`)
:----------------------------------:|:------------------------------:
![input](test/refimg/testimage.png) | ![output](test/refimg/LinearPipeline.png)

You can also use an `ImageSource` to sample input data from

```julia
# define directory as an image source
src = DirImageSource("path/to/images/")

# randomly sample a few images from the source
imgs = rand(src, 5) # Vector{Image}

# transform each image independently
imgs_new = transform(pl, imgs)
```

```julia
# create the image source by indexing the directory's content.
# Note: this command won't actually load any images.
src = DirImageSource("mydatadir/")

# number of available images
n = length(src)

# images can be indexed like an array
img1 = src[1]

# loop through all images in the source
for img in src
    println(img)
end
```

It is also possible to create a pipeline in a more concise way

```julia
pl = LinearPipeline(FlipX(.5), FlipY(.5), Resize(32,32))
```

```
LinearPipeline
- 3 operation(s):
    - 50% chance to: Flip x-axis. (factor: 2x)
    - 50% chance to: Flip y-axis. (factor: 2x)
    - Resize to 32x32. (factor: 1x)
- total factor: 4x
```

## License

This code is free to use under the terms of the MIT license.

## Acknowledgment

This package makes heavy use of the following packages in order
to provide it's main functionality.
To see at full list of utilized packages, please take a look at
the REQUIRE file.

- [Images.jl](https://github.com/timholy/Images.jl)
- [Interpolations.jl](https://github.com/tlycken/Interpolations.jl)
- [AffineTransforms.jl](https://github.com/timholy/AffineTransforms.jl)
- [PiecewiseAffineTransforms.jl](https://github.com/dfdx/PiecewiseAffineTransforms.jl)

