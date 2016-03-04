
abstract Pipeline

type LinearPipeline <: Pipeline
    transforms::Vector{ImageOperation}
end

function _perform(ops, N, types, img)
    ex = :(img_0 = img)
    for i in 1:N
        types[i] <: Any || throw(ArgumentError("Pipline must consist of ImageOperation objects"))
        vin  = symbol("img_$(i-1)")
        vout = symbol("img_$i")
        ex = quote
            $ex
            $vout = perform(ops[$i], $vin)
        end
    end
    vlast = symbol("img_$N")
    ex = :($ex; $vlast)
    ex
end

@generated function perform{N}(ops::NTuple{N}, img)
    _perform(ops, N, ops.parameters, img)
end

function perform{T}(pl::LinearPipeline, img::T)
    perform((pl.transforms...), img)::T
end

