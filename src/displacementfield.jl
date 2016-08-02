immutable DisplacementField
    X::Matrix{Float64}
    Y::Matrix{Float64}
    delta_X::Matrix{Float64}
    delta_Y::Matrix{Float64}

    function DisplacementField(X::Matrix{Float64}, Y::Matrix{Float64}, delta_X::Matrix{Float64}, delta_Y::Matrix{Float64})
        @assert size(X) == size(Y) == size(delta_X) == size(delta_Y)
        @assert minimum(Y) >= 0 && maximum(X) <= 1
        @assert minimum(Y) >= 0 && maximum(Y) <= 1
        new(X, Y, delta_X, delta_Y)
    end

    function DisplacementField(delta_X::Matrix{Float64}, delta_Y::Matrix{Float64})
        h, w = size(delta_X)
        X = [j for i=1:h, j=linspace(0,1,w)]
        Y = [i for i=linspace(0,1,h), j=1:w]
        DisplacementField(X, Y, delta_X, delta_Y)
    end
end

@recipe function plot(df::DisplacementField)
    h, w = size(df.delta_X)

    yflip := true
    seriestype := :quiver

    quiver := vec([(Float64(df.delta_X[i,j]), Float64(df.delta_Y[i,j])) for i=1:h, j=1:w])

    vec([(df.X[i,j], df.Y[i,j]) for i=1:h, j=1:w])
end

# uniform displacement

function uniform_displacement(gridwidth::Int, gridheight::Int, scale::Real, static_border::Bool = true, normalize::Bool = true)
    delta_X = _1d_uniform_displacement(gridwidth, gridheight, Float64(scale), static_border, normalize)
    delta_Y = _1d_uniform_displacement(gridwidth, gridheight, Float64(scale), static_border, normalize)
    DisplacementField(delta_X, delta_Y)
end

function uniform_displacement(gridwidth::Int, gridheight::Int; scale = .2, static_border = true, normalize = true)
    uniform_displacement(gridwidth, gridheight, scale, static_border, normalize)
end

function _1d_uniform_displacement(gridwidth::Int, gridheight::Int, scale::Float64, static_border::Bool, normalize::Bool)
    A = if static_border
        @assert gridwidth > 2 && gridheight > 2
        A_inner = rand(gridheight-2, gridwidth-2)
        padarray(A_inner, [1, 1], [1, 1], "value", 0.5)
    else
        @assert gridwidth > 0 && gridheight > 0
        rand(gridheight, gridwidth)
    end::Matrix{Float64}
    broadcast!(*, A, A, 2.)
    broadcast!(-, A, A, 1.)
    if normalize
        broadcast!(*, A, A, scale / norm(A))
    end
    A
end

# gaussian displacement fields

function gaussian_displacement(gridwidth::Int, gridheight::Int, scale::Real, sigma::Vector{Float64}, static_border::Bool = true, normalize::Bool = true)
    delta_X = _1d_gaussian_displacement(gridwidth, gridheight, Float64(scale), sigma, static_border, normalize)
    delta_Y = _1d_gaussian_displacement(gridwidth, gridheight, Float64(scale), sigma, static_border, normalize)
    DisplacementField(delta_X, delta_Y)
end

function gaussian_displacement(gridwidth::Int, gridheight::Int, scale::Real, sigma::Real, static_border::Bool = true, normalize::Bool = true)
    gaussian_displacement(gridwidth, gridheight, Float64(scale), [Float64(sigma), Float64(sigma)], static_border, normalize)
end

function gaussian_displacement(gridwidth::Int, gridheight::Int; scale = .2, sigma = 2, static_border = true, normalize = true)
    gaussian_displacement(gridwidth, gridheight, scale, sigma, static_border, normalize)
end

function _1d_gaussian_displacement(gridwidth::Int, gridheight::Int, scale::Float64, sigma::Vector{Float64}, static_border::Bool, normalize::Bool)
    @assert length(sigma) == 2
    @assert all(sigma .> 0)
    A = if static_border
        A_inner = _1d_uniform_displacement(gridwidth-2, gridheight-2, 1., false, false)
        Images.imfilter_gaussian_no_nans!(A_inner, sigma)
        padarray(A_inner, [1, 1], [1, 1], "value", 0.)
    else
        A_t = _1d_uniform_displacement(gridwidth, gridheight, 1., false, false)
        Images.imfilter_gaussian_no_nans!(A_t, sigma)
    end::Matrix{Float64}
    if normalize
        broadcast!(*, A, A, scale / norm(A))
    end
    A
end

