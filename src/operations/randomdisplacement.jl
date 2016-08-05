immutable RandomDisplacement <: ImageOperation
    gridwidth::Int
    gridheight::Int
    scale::Float64
    static_border::Bool
    normalize::Bool
end

function RandomDisplacement(gridwidth::Real, gridheight::Real; scale = .2, static_border::Bool = true, normalize::Bool = true)
    (gridwidth > 2 && gridheight > 2) || throw(ArgumentError("gridwidth and gridheight need to be greater than 2"))
    RandomDisplacement(Int(gridwidth), Int(gridheight), Float64(scale), static_border, normalize)
end

Base.showcompact(io::IO, op::RandomDisplacement) = print(io, "Displace with random $(op.gridwidth)x$(op.gridheight) displacement field.")
multiplier(::RandomDisplacement) = 1 # not true, basically infinity...

function transform{T<:AbstractImage}(op::RandomDisplacement, img::T)
    df = uniform_displacement(op.gridwidth, op.gridheight, op.scale, op.static_border, op.normalize)
    transform(df, img)::T
end

