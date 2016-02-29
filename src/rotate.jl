
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
    height_new = floor(Int, h1 + h2)

    w1 = cos(θ) * width
    w2 = cos(half_pi - θ) * height
    width_new = floor(Int, w1 + w2)
    height_new, width_new
end

function _ta_rotate{T}(A::AbstractMatrix{T}, ϕ)
    itp = interpolate(A, BSpline(Linear()), OnGrid())
    etp = extrapolate(itp, zero(T))

    tfm = tformrotate(ϕ)
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
        B = similar(A, h, w)
        transform!(B, A_tfm)
    end
end

function rotate_expand(img::AbstractImage, angle)
    assert2d(img)
    shareproperties(img, rotate_expand(data(img), isxfirst(img) ? angle : -angle))
end
