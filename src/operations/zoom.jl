
immutable Zoom <: ImageOperation
    ratio::Float64
end

Base.show(io::IO, op::Zoom) = print(io, "Zoom to a $(op.ratio) aspect ratio.")
multiplier(::Zoom) = 1

function transform{T<:AbstractImage}(op::Zoom, img::T)
    w = width(img)
    h = height(img)

    nw = floor(Int, h * op.ratio)
    nh = floor(Int, w / op.ratio)

    if nw == w || nh == h
        return img
    elseif nw < w
        i = floor(Int, (w - nw) / 2)
        @assert nw > 0 && i > 0
        crop(img, i:(i+nw-1), 1:h)
    elseif nh < h
        i = floor(Int, (h - nh) / 2)
        @assert nh > 0 && i > 0
        crop(img, 1:w, i:(i+nh-1))
    end
end

