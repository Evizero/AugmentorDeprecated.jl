
immutable CropRatio <: ImageOperation
    ratio::Float64

    function CropRatio(ratio::Real)
        ratio > 0 || throw(ArgumentError("ratio has to be greater than 0"))
        new(Float64(ratio))
    end
end

CropRatio(; ratio = 1.) = CropRatio(ratio)

Base.show(io::IO, op::CropRatio) = print(io, "Crop to $(op.ratio) aspect ratio.")
multiplier(::CropRatio) = 1

function transform{T<:AbstractImage}(op::CropRatio, img::T)
    w = width(img)
    h = height(img)

    nw = floor(Int, h * op.ratio)
    nh = floor(Int, w / op.ratio)

    result = if nw == w || nh == h
        img
    elseif nw < w
        i = floor(Int, (w - nw) / 2)
        @assert nw > 0 && i > 0
        crop(img, i:(i+nw-1), 1:h)
    elseif nh < h
        i = floor(Int, (h - nh) / 2)
        @assert nh > 0 && i > 0
        crop(img, 1:w, i:(i+nh-1))
    end::T
    _log_operation!(op, result)
end

