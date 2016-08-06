immutable SmoothedRandomDisplacement <: ImageTransformation
    gridwidth::Int
    gridheight::Int
    scale::Float64
    sigma::Float64
    iterations::Int
    static_border::Bool
    normalize::Bool
end

function SmoothedRandomDisplacement(gridwidth::Real, gridheight::Real; scale = .2, sigma = 2, iterations = 1, static_border::Bool = true, normalize::Bool = true)
    (gridwidth > 2 && gridheight > 2) || throw(ArgumentError("gridwidth and gridheight need to be greater than 2"))
    sigma > 0 || throw(ArgumentError("sigma needs to be greater than 0"))
    iterations > 0 || throw(ArgumentError("iterations needs to be greater than 0"))
    SmoothedRandomDisplacement(Int(gridwidth), Int(gridheight), Float64(scale), Float64(sigma), Int(iterations), static_border, normalize)
end

Base.showcompact(io::IO, op::SmoothedRandomDisplacement) = print(io, "Displace randomly with smoothed $(op.gridwidth)x$(op.gridheight) displacement field (σ = $(op.sigma)).")
multiplier(::SmoothedRandomDisplacement) = 1 # not true, basically infinity...

function transform{T<:AbstractImage}(op::SmoothedRandomDisplacement, img::T)
    df = gaussian_displacement(op.gridwidth, op.gridheight, op.scale, op.sigma, op.iterations, op.static_border, op.normalize)
    transform(df, img)::T
end

