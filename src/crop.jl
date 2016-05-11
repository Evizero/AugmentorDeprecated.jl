function crop(img::AbstractImage, x::Range, y::Range)
    @assert ndims(img) == 2
    xidx = dimindex(img, "x")
    ndata = if xidx == 1
        w, h = size(img)
        Base.getindex(img, x, y)
    else
        h, w = size(img)
        Base.getindex(img, y, x)
    end
    copyproperties(img, ndata)
end
