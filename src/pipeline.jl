
abstract Pipeline

type LinearPipeline <: Pipeline
    transforms::Vector{ImageOperation}
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
    _transform(ops, N, ops.parameters, img)
end

function transform{T}(pl::LinearPipeline, img::T)
    transform((pl.transforms...), img)::T
end

