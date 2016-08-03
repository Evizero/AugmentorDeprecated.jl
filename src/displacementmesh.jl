immutable DisplacementMesh <: ImageOperation
    input_vertices::Matrix{Float64}
    output_vertices::Matrix{Float64}
    indices::Matrix{Int}

    function DisplacementMesh(input_vertices::Matrix{Float64}, output_vertices::Matrix{Float64}, indices::Matrix{Int})
        @assert size(input_vertices) == size(output_vertices)
        new(input_vertices, output_vertices, indices)
    end
end

function DisplacementMesh(field::DisplacementField, img_width::Int, img_height::Int)
    input_vertices, output_vertices = _compute_vertices(field, Float64(img_width), Float64(img_height))
    indices = _compute_indices(field)
    DisplacementMesh(input_vertices, output_vertices, indices)
end

DisplacementMesh(field::DisplacementField, img_size::Tuple{Int,Int}) = DisplacementMesh(field, img_size[1], img_size[2])
DisplacementMesh(field::DisplacementField, img::AbstractImage) = DisplacementMesh(field, size(img, "x"), size(img, "y"))

function Base.show(io::IO, dm::DisplacementMesh)
    print(io, "DisplacementMesh (vertices: $(size(dm.input_vertices,1)), triangles: $(size(dm.indices,1)))")
end

@recipe function plot(dm::DisplacementMesh, img::Image)
    legend --> false
    yflip := true
    layout := 2

    @series begin
        title --> "Input"
        seriestype := :image
        subplot := 1
        img
    end

    @series begin
        title --> "Output"
        seriestype := :image
        subplot := 2
        transform(dm,img)
    end

    dm
end

@recipe function plot(dm::DisplacementMesh)
    fillcolor --> :transparent
    legend --> false
    yflip := true
    layout := 2

    for i = 1:size(dm.indices,1)
        x_in = [dm.input_vertices[dm.indices[i, j], 2] for j = 1:3]
        y_in = [dm.input_vertices[dm.indices[i, j], 1] for j = 1:3]
        x_out = [dm.output_vertices[dm.indices[i, j], 2] for j = 1:3]
        y_out = [dm.output_vertices[dm.indices[i, j], 1] for j = 1:3]
        @series begin
            title --> "Input"
            seriestype := :shape
            subplot := 1
            x_in, y_in
        end
        @series begin
            title --> "Output"
            seriestype := :shape
            subplot := 2
            x_out, y_out
        end
    end
end

function transform{T}(dm::DisplacementMesh, img::Image{T})
    rawdata = convert(Array{Float64, 3}, data(separate(img)))
    wrp = PiecewiseAffineTransforms.pa_warp(rawdata, dm.input_vertices, dm.output_vertices, dm.indices)
    if isxfirst(img)
        copyproperties(img, permutedims(convert(Image{T}, wrp), [2, 1]))
    else
        copyproperties(img, convert(Image{T}, wrp))
    end
end

function _compute_vertices(field::DisplacementField, img_width::Float64, img_height::Float64)
    height, width = size(field.X)
    input_vertices  = zeros(height*width, 2)
    output_vertices = zeros(height*width, 2)
    i = 1
    for x = 1:width, y = 1:height
        input_vertices[i,1] = clamp(clamp(field.Y[y,x], 0., 1.) * img_height, 1., img_height)
        input_vertices[i,2] = clamp(clamp(field.X[y,x], 0., 1.) * img_width,  1., img_width)
        output_vertices[i,1] = clamp(input_vertices[i,1] + field.delta_Y[y,x] * img_height, 1., img_height)
        output_vertices[i,2] = clamp(input_vertices[i,2] + field.delta_X[y,x] * img_width,  1., img_width)
        i = i + 1
    end
    input_vertices, output_vertices
end

function _compute_indices(field::DisplacementField)
    grid_size = size(field.X)
    height, width = grid_size
    w_half = floor(Int, width/2)
    h_half = floor(Int, height/2)
    indices = zeros(Int, (height-1)*(width-1)*2, 3)
    i = 1
    for x = 1:(width-1), y = 1:(height-1)
        if (x <= w_half && y <= h_half) || (x > w_half && y > h_half)
            # upper left or lower right
            # *--*
            # |\ |
            # | \|
            # *--*
            indices[i, 1] = sub2ind(grid_size, y,   x  )
            indices[i, 2] = sub2ind(grid_size, y+1, x+1)
            indices[i, 3] = sub2ind(grid_size, y+1, x  )
            i = i + 1

            indices[i, 1] = sub2ind(grid_size, y,   x  )
            indices[i, 2] = sub2ind(grid_size, y,   x+1)
            indices[i, 3] = sub2ind(grid_size, y+1, x+1)
            i = i + 1
        else
            # lower left or upper right
            # *--*
            # | /|
            # |/ |
            # *--*
            indices[i, 1] = sub2ind(grid_size, y,   x  )
            indices[i, 2] = sub2ind(grid_size, y,   x+1)
            indices[i, 3] = sub2ind(grid_size, y+1, x  )
            i = i + 1

            indices[i, 1] = sub2ind(grid_size, y+1,   x)
            indices[i, 2] = sub2ind(grid_size, y,   x+1)
            indices[i, 3] = sub2ind(grid_size, y+1, x+1)
            i = i + 1
        end
    end
    indices
end

