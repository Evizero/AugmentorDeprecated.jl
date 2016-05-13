
immutable Zoom <: ImageOperation
    factor::Float64

    function Zoom(factor::Real)
        factor > 0 || throw(ArgumentError("factor has to be greater than 0"))
        new(Float64(factor))
    end
end

Zoom(; factor = 2) = Zoom(factor)

Base.show(io::IO, op::Zoom) = print(io, "Zoom by $(op.factor)x.")
multiplier(::Zoom) = 1

function transform{T<:AbstractImage}(op::Zoom, img::T)
    x, y = size(img)
    xn = ceil(Int, x * op.factor)
    yn = ceil(Int, y * op.factor)
    result = copyproperties(img, Images.imresize(img, (xn, yn)))
    _log_operation!(op, result)
end

