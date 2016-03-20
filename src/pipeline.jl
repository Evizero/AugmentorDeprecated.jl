"""
`abstract Pipeline`

Description
============

Abstract supertype for all image processing pipelines.
Every subtype of `Pipeline` has to implement the methods
oulined below.

Methods
========

- **`fit!`** : Fits those image operations of the pipeline, which
have learnable parameters, to the given trainingset.

- **`transform`** : Applies the image operations of the pipline
to the given image or set of images and returns those.

- **`summary`** : Computes and prints a verbose description of the
image processing pipeline. The computation for this function is a
little more involed than for `show`.

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

see also
=========

`fit!`, `transform`, `summary`

`LinearPipeline`
"""
abstract Pipeline

Base.eltype{T<:Pipeline}(::Type{T}) = ImageOperation

