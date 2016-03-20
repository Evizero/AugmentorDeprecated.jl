# Augmentor

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)
[![Build Status](https://travis-ci.org/Evizero/Augmentor.jl.svg?branch=master)](https://travis-ci.org/Evizero/Augmentor.jl)

An image augmentation library in for [Julia](julialang.org).

## Installation

Developed for Julia 0.4

```julia
Pkg.clone("git@github.com:Evizero/Augmentor.jl.git")
using Augmentor
```

For the latest developer version:

```julia
Pkg.checkout("Augmentor")
```

## Usage

There are three basic building-blocks to create a system for image
augmentation, namely an *image source* an *image operation pipeline*.

- `ImageSouce`: Functionality to access images from some data source,
such as a directory.

- `Pipeline`: A chain or tree of (probabilistic) operations that
should be applied to a given image, or set of images.

- `ImageOperation`: As the name suggests concrete subclasses define
a specific transformation that can be applied to an image, or a set
of images. Operations can also be lifted into a `ProbableOperation`,
which have a random probability of occuring, depending on the
hyperparameter `chance`.

### Hello World

Create a simple probabilistic pipeline which can be sampled on the fly

```julia
# load an example image
using TestImages
img = testimage("lena")

# create empty pipeline
pl = LinearPipeline()

# add operations to pipeline
push!(pl, FlipX(0.5)) # lifted to ProbableOperation{FlipX}. 50% chance of occuring
push!(pl, FlipY())    # not lifted. will always occur
push!(pl, Resize(64,64))

# transform example image
img_new = transform(pl, img)
```

```
RGBA Images.Image with:
  data: 64x64 Array{ColorTypes.RGBA{FixedPointNumbers.UFixed{UInt8,8}},2}
  properties:
    operations:  Flip y-axis. Resize to 64x64.
    imagedescription: <suppressed>
    spatialorder:  x y
    pixelspacing:  1 1
```

You can also use an `ImageSource` to sample input data from

```julia
# define directory as an image source
src = DirImageSource("path/to/images/")

# randomly sample a few images from the source
imgs = rand(src, 5) # Vector{Image}

# transform each image independently
imgs_new = transform(pl, imgs)
```

### Image sources

Abstract supertype for all image sources. Every subtype of
`ImageSource` must implement the read-only functions of the array
interface. Additionally, they must fully implement the iterator
interface so that they can be used as for-loops to iterate over
all the stored images.

Currently there is one type of `ImageSource` implemented.
It focuses on filesystem based image storage.

#### `DirImageSource`

Concrete implementation of `ImageSource` for (nested) directories
of a local filesystem. The purpose of `DirImageSource` is to
seamlessly load images from a directory and its subdirectories.
Note that subdirectories will be treated as categories and their
relative paths will be stored as metadata within the loaded image
object.

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

### Pipelines

Pipelines are container objects that define what kind of operations
are performed and in what order. They are designed for convenient
user interaction and provide some information on what is going on.

Currently there is one concrete implementation of `Pipeline`, which
is specialized for purely linear sequences of image operations.

#### `LinearPipeline`

Subtype of `Pipeline` for linear chains of operations, which may
or may not be probabilistic (i.e. have a random chance for occuring).
The contained `ImageOperation`s are stored as a vector, in which
the first element will be the first operation applied to an image
passed to `transform`.
The outcome of the first operation will then be fed as input to
the second one, and so on, until all operations were applied. The
outcome of the last operation will then be returned as the result.

```julia
# create complete pipeline in one line
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

### Image operations

- [ ] `ConvertGrayscale()`
- [x] `FlipX(chance = 1)`
- [x] `FlipY(chance = 1)`
- [ ] `Transpose(chance = 1)`
- [ ] `Rotate90(chance = 1)`
- [ ] `Rotate180(chance = 1)`
- [ ] `Rotate270(chance = 1)`
- [x] `Resize(height, width)`
- [ ] `Scale(height, width)`
- [ ] `Rotate(degree)`: arbirary rotations
- [ ] `Crop(height, width)`

## License

This code is free to use under the terms of the MIT license.

## Acknowledgment

This package makes heavy use of the following packages in order
to provide it's main functionality.
To see at full list of utilized packages, please take a look at
the REQUIRE file.

- [Images.jl](https://github.com/timholy/Images.jl)
- [AffineTransforms.jl](https://github.com/timholy/AffineTransforms.jl)
- [Interpolations.jl](https://github.com/tlycken/Interpolations.jl)

