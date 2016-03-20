"""
`abstract ImageSource`

Description
============

Abstract supertype for all image sources. Every subtype of
`ImageSource` must implement the read-only functions of the array
interface. Additionally, they must fully implement the iterator
interface.

Methods
========

- **`rand`** : Loads and returns a random image, or an array of
images (depending on the parameters).

- **`length`** : Returns the total number of images that are
available in the image source.

- **`getindex`** : Loads and returns the image of the given index.

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

see also
=========

`rand`, `length`

`DirImageSource`
"""
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

