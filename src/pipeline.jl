
abstract Pipeline

type LinearPipeline <: Pipeline
    operations::Vector{ImageOperation}

    function LinearPipeline(ops::Vector{ImageOperation} = Array{ImageOperation,1}())
        new(ops)
    end
end

function Base.push!(pl::LinearPipeline, op::ImageOperation)
    push!(pl.operations, op)
    pl
end

function Base.show(io::IO, pl::LinearPipeline)
    println(io, "LinearPipeline")
    println(io, "- $(length(pl.operations)) operation(s): ", )
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

@generated function transform{N,T<:AbstractImage}(ops::NTuple{N}, img::T)
    @inbounds res = _transform(ops, N, ops.parameters, img)
    res
end

function transform(pl::LinearPipeline, imgs::AbstractArray)
    imgs_out = similar(imgs)
    pl_tuple = (pl.operations...)
    for iter in eachindex(imgs)
        img = imgs[iter]
        T = typeof(img)
        imgs_out[iter] = transform(pl_tuple, img)::T
    end
    imgs_out
end

function transform{T<:AbstractImage}(pl::LinearPipeline, img::T)
    transform((pl.operations...), img)::T
end

