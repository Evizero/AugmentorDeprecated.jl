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
        w, h = size(delta_X)
        X = [j for i=1:w, j=linspace(0,1,h)]
        Y = [i for i=linspace(0,1,w), j=1:h]
        DisplacementField(X, Y, delta_X, delta_Y)
    end
end

@recipe function plot(df::DisplacementField; strength = 1)
    w, h = size(df.delta_X)
    strengthf = Float64(strength)

    yflip := true
    seriestype := :quiver

    quiver := vec([(Float64(df.delta_X[i,j] * strengthf), Float64(df.delta_Y[i,j] * strengthf)) for i=1:w, j=1:h])

    vec([(df.X[i,j], df.Y[i,j]) for i=1:w, j=1:h])
end

# uniform displacement

function uniform_displacement(gridwidth::Int, gridheight::Int, static_border::Bool = true, normalize::Bool = true)
    delta_X = _1d_uniform_displacement(gridwidth, gridheight, static_border, normalize)
    delta_Y = _1d_uniform_displacement(gridwidth, gridheight, static_border, normalize)
    DisplacementField(delta_X, delta_Y)
end

function _1d_uniform_displacement(gridwidth::Int, gridheight::Int, static_border::Bool = true, normalize::Bool = true)
    A = if static_border
        @assert gridwidth > 2 && gridheight > 2
        A_inner = rand(gridwidth-2, gridheight-2)
        padarray(A_inner, [1, 1], [1, 1], "value", 0.5)
    else
        @assert gridwidth > 0 && gridheight > 0
        rand(gridwidth, gridheight)
    end::Matrix{Float64}
    broadcast!(*, A, A, 2.)
    broadcast!(-, A, A, 1.)
    if normalize
        broadcast!(/, A, A, norm(A))
    end
    A
end

# gaussian displacement fields

function gaussian_displacement(gridwidth::Int, gridheight::Int, sigma::Vector{Float64}, static_border::Bool = true, normalize::Bool = true)
    delta_X = _1d_gaussian_displacement(gridwidth, gridheight, sigma, static_border, normalize)
    delta_Y = _1d_gaussian_displacement(gridwidth, gridheight, sigma, static_border, normalize)
    DisplacementField(delta_X, delta_Y)
end

function gaussian_displacement(gridwidth::Int, gridheight::Int, sigma::Real = 2, static_border::Bool = true, normalize::Bool = true)
    gaussian_displacement(gridwidth, gridheight, [Float64(sigma), Float64(sigma)], static_border, normalize)
end

function _1d_gaussian_displacement(gridwidth::Int, gridheight::Int, sigma::Vector{Float64}, static_border::Bool, normalize::Bool)
    @assert length(sigma) == 2
    @assert all(sigma .> 0)
    A = if static_border
        A_inner = _1d_uniform_displacement(gridwidth-2, gridheight-2, false, false)
        Images.imfilter_gaussian_no_nans!(A_inner, sigma)
        padarray(A_inner, [1, 1], [1, 1], "value", 0.)
    else
        A_t = _1d_uniform_displacement(gridwidth, gridheight, false, false)
        Images.imfilter_gaussian_no_nans!(A_t, sigma)
    end::Matrix{Float64}
    if normalize
        broadcast!(/, A, A, norm(A))
    end
    A
end

