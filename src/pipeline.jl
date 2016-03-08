
abstract Pipeline

type LinearPipeline <: Pipeline
    imagesource::ImageSource
    operations::Vector{ImageOperation}

    function LinearPipeline(src::ImageSource, ops::Vector{ImageOperation}
= Array{ImageOperation,1}())
        new(src, ops)
    end
end

function Base.rand(pl::LinearPipeline)
    transform(pl, rand(pl.imagesource)...)
end

function Base.push!(pl::LinearPipeline, op::ImageOperation)
    push!(pl.operations, op)
    pl
end

function Base.show(io::IO, pl::LinearPipeline)
    println(io, "LinearPipeline")
    println(io, "- source: $(pl.imagesource.path)")
    println(io, "- $(length(pl.operations)) operation(s): ", )

    maxfactor = 1

    for op in pl.operations
        println(io, "    - $op (factor: $(multiplier(op))x)")
        maxfactor = maxfactor * multiplier(op)
    end
    print(io, "- new dataset size: $(length(pl.imagesource) * maxfactor) (factor: $(maxfactor)x)")
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

@generated function transform{N}(ops::NTuple{N}, img)
    @inbounds res = _transform(ops, N, ops.parameters, img)
    res
end

function transform(pl::LinearPipeline, imgs::AbstractArray, labels::AbstractArray)
    @assert size(imgs) == size(labels)
    imgs_out = similar(imgs)
    labels_out = similar(labels)
    for iter in eachindex(imgs)
        img_out, label_out = transform(pl, imgs[iter], labels[iter])
        imgs_out[iter] = img_out
        labels_out[iter] = label_out
    end
    imgs_out, labels_out
end

function transform(pl::LinearPipeline, imgs::AbstractArray)
    imgs_out = similar(imgs)
    for iter in eachindex(imgs)
        imgs_out[iter] = transform(pl, imgs[iter])
    end
    imgs_out
end

function transform{T<:AbstractImage}(pl::Pipeline, img::T, label)
    transform(pl, img), label
end

function transform{T<:AbstractImage}(pl::LinearPipeline, img::T)
    transform((pl.operations...), img)::T
end

