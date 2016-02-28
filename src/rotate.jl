
function _simplify_angle{R}(angle::R)
    two_pi = R(2) * π
    ϕ = angle % two_pi
    ϕ < zero(R) ? two_pi + ϕ : ϕ
end

function _expand_size{R}(height, width, ϕ::R)
    two_pi = R(2) * π
    half_pi = π / R(2)

    θ = if ϕ > R(3) * half_pi
        two_pi - ϕ
    elseif ϕ > π
        ϕ - π
    elseif ϕ > half_pi
        π - ϕ
    else
        convert(typeof(two_pi), ϕ)
    end

    h1 = sin(θ) * width
    h2 = sin(half_pi - θ) * height
    height_new = h1 + h2

    w1 = cos(θ) * width
    w2 = cos(half_pi - θ) * height
    width_new = w1 + w2
    height_new, width_new
end

function _ta_rotate{T}(A::AbstractMatrix{T}, ϕ)
    height, width = size(A)

    itp = interpolate(A, BSpline(Linear()), OnGrid())
    etp = extrapolate(itp, zero(T))

    tfm = tformrigid([ϕ, height/2, width/2])::AffineTransform{Float64,2}
    TransformedArray(etp, tfm)
end

function rotate_expand{T}(A::AbstractMatrix{T}, angle)
    ϕ = _simplify_angle(angle)

    if ϕ == 0
        A
    elseif ϕ == π/2
        rotr90(A)
    elseif ϕ == 3π/2
        rotl90(A)
    elseif ϕ == 1π
        Images.reflect(A)
    else
        A_tfm = _ta_rotate(A, ϕ)
        h, w = _expand_size(size(A,1), size(A,2), ϕ)
        h_half = floor(Int, h/2)
        w_half = floor(Int, w/2)
        B_float = Base.unsafe_getindex(A_tfm, -(h_half-1):h_half, -(w_half-1):w_half)
        convert(typeof(A), B_float)
    end
end

function rotate_expand{T}(img::AbstractImage{T}, angle)
    assert2d(img)
    shareproperties(img, rotate_expand(data(img), isxfirst(img) ? angle : -angle))
end
