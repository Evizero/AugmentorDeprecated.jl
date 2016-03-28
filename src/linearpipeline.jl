"""
`LinearPipeline(operations)` → `Pipeline`

Description
============

Concrete implementation of `Pipeline` for purely linear sequences
of image operations.

The contained `ImageOperation`s are stored as a vector, in which
the first element will be the first operation applied to an image
passed to `transform`.
The outcome of the first operation will then be fed as input to
the second one, and so on, until all operations were applied. The
outcome of the last operation will then be returned as the result.

Usage
======

    LinearPipeline(operations)

    LinearPipeline(operations...)

Methods
========

- **`length`** : Returns the number of `ImageOperation`s that the
pipeline contains.

- **`push!`** : Adds the given `ImageOperation` to the end of the
pipeline. Returns itself.

- **`append!`** : Adds the elements of the second parameter, which
can either be another `LinearPipeline` or some other collection of
`ImageOperation`s, to the end of the current pipeline.
Returns itself.

- **`insert!`** : Adds the given `ImageOperation` to the pipeline
at the given position (index). Returns itself.

- **`deleteat!`** : Removes the `ImageOperation` at the specified
position from the pipeline. Returns itself.

- **`fit!`** : Fits all the image operations of the pipeline,
which have learnable parameters, to the given trainingset.

- **`transform`** : Applies the `ImageOperation`s of the pipeline
one after another to the given image, or set of images, and returns
the transformed image(s).

- **`summary`** : Computes and prints a verbose description of the
image processing pipeline. The computation for this function is a
little more involved than for `show`.

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
=========

    using TestImages
    using Augmentor

    # load an example image
    img = testimage("lena")

    # create empty pipeline
    pl = LinearPipeline()

    # add operations to pipeline
    push!(pl, FlipX(0.5))
    push!(pl, FlipY(0.1))
    push!(pl, Resize(64,64))

    # transform example image
    img_new = transform(pl, img)

see also
=========

`length`, `push!`, `append!`, `insert!`, `deleteat!`, `fit!`, `transform`

`Pipeline`, `ImageOperation`
"""
type LinearPipeline <: Pipeline
    operations::Vector{ImageOperation}

    function LinearPipeline(ops::Vector{ImageOperation} = Array{ImageOperation,1}())
        new(ops)
    end
end

function LinearPipeline(ops::ImageOperation...)
    LinearPipeline(Vector{ImageOperation}(collect(ops)))
end

Base.endof(pl::LinearPipeline) = length(pl)
Base.start(::LinearPipeline) = 1
Base.next(pl::LinearPipeline, state) = (pl[state], state+1)
Base.done(pl::LinearPipeline, state) = state > length(pl)

Base.getindex(pl::LinearPipeline, idx) = pl.operations[idx]
Base.length(pl::LinearPipeline) = length(pl.operations)

Base.append!(pl::LinearPipeline, other::LinearPipeline) = append!(pl, other.operations)

function Base.append!(pl::LinearPipeline, ops::Vector{ImageOperation})
    append!(pl.operations, ops)
    pl
end

function Base.push!(pl::LinearPipeline, op::ImageOperation)
    push!(pl.operations, op)
    pl
end

function Base.insert!(pl::LinearPipeline, idx, op::ImageOperation)
    insert!(pl.operations, idx, op)
    pl
end

function Base.deleteat!(pl::LinearPipeline, idx)
    deleteat!(pl.operations, idx)
    pl
end

function Base.show(io::IO, pl::LinearPipeline)
    println(io, "LinearPipeline")
    println(io, "- $(length(pl.operations)) operation(s): ")
    maxfactor = 1
    for op in pl.operations
        println(io, "    - $op (factor: $(multiplier(op))x)")
        maxfactor = maxfactor * multiplier(op)
    end
    print(io, "- total factor: $(maxfactor)x")
end

function _transform(ops, N, types, img)
    ex = :(img_0 = img)
    for i in 1:N
        types[i] <: Any || throw(ArgumentError("Pipline must consist of ImageOperation objects"))
        vin  = symbol("img_$(i-1)")
        vout = symbol("img_$i")
        ex = quote
            $ex
            $vout = transform(ops[$i], $vin)
        end
    end
    vlast = symbol("img_$N")
    ex = :($ex; $vlast)
    ex
end

@generated function transform{N,T}(ops::NTuple{N}, img::T)
    @inbounds res = _transform(ops, N, ops.parameters, img)
    res
end

function transform{I<:AbstractImage}(pl::LinearPipeline, imgs::AbstractArray{I})
    imgs_out = similar(imgs)
    pl_tuple = (pl.operations...)
    for iter in eachindex(imgs)
        img = imgs[iter]
        T = typeof(img)
        imgs_out[iter] = transform(pl_tuple, img)::T
    end
    imgs_out
end

function transform{T}(pl::LinearPipeline, img::T)
    transform((pl.operations...), img)::T
end

