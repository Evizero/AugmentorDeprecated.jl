abstract ImageSource

function Base.rand(s::ImageSource)
    index = rand(1:length(s))
    s[index]
end

function Base.rand(s::ImageSource, n::Integer)
    [rand(s) for _ in 1:n]
end

Base.eltype{T<:ImageSource}(::Type{T}) = Image
Base.endof(s::ImageSource) = length(s)

function Base.show(io::IO, s::ImageSource)
    println(io, typeof(s))
    print(io, "- $(length(s)) images found")
end

