hit_chance(chance::Real) = rand() <= chance
hit_chance{T<:Real}(chance::Array{T}) = rand(size(chance)) .<= chance
