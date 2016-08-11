typealias LinearPipeline{T<:ImageTransformation} Vector{T}

function _transform(ops, N, types, img)
    ex = :(img_0 = img)
    for i in 1:N
        types[i] <: Any || throw(ArgumentError("Pipline must consist of ImageTransformation objects"))
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
    pl_tuple = (pl...)
    for iter in eachindex(imgs)
        img = imgs[iter]
        T = typeof(img)
        imgs_out[iter] = transform(pl_tuple, img)::T
    end
    imgs_out
end

function transform{T}(pl::LinearPipeline, img::T)
    transform((pl...), img)::T
end

