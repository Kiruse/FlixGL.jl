export xcoord, ycoord, zcoord, wcoord
export curry, hflip!, vflip!
export mm2in, in2mm

xcoord(vec) = vec[1]
ycoord(vec) = vec[2]
zcoord(vec) = vec[3]
wcoord(vec) = vec[4]

curry(fn, curryargs...; kwcurryargs...) = (moreargs...; kwargs...) -> fn(curryargs..., moreargs...; kwcurryargs..., kwargs...)

function hflip!(arr::AbstractArray)
    rows, cols = size(arr)
    if cols < 2 return arr end
    
    for row ∈ 1:rows
        for col ∈ 1:(cols÷2)
            tmp = arr[row, col]
            arr[row, col] = arr[row, cols-(col-1)]
            arr[row, cols-(col-1)] = tmp
        end
    end
    arr
end

function vflip!(arr::AbstractArray)
    rows, cols = size(arr)
    if rows < 2 return arr end
    
    for col ∈ 1:cols
        for row ∈ 1:(rows÷2)
            tmp = arr[row, col]
            arr[row, col] = arr[rows-(row-1), col]
            arr[rows-(row-1), col] = tmp
        end
    end
    arr
end

mm2in(mm::Number) = 0.03937mm
in2mm(in::Number) = in / 0.03937

function Base.write(io::IO, vec::SVector{N}) where N
    for i ∈ 1:N
        write(io, vec[i])
    end
end

function Base.write(io::IO, mat::SMatrix{N, M}) where {N, M}
    for n ∈ 1:N
        for m ∈ 1:M
            write(io, mat[n, m])
        end
    end
end

translationmatrix(translation::Vector2{T}) where T = Matrix3{T}(1, 0, 0, 0, 1, 0, translation[1], translation[2], 1)
rotationmatrix(rotation::T) where T = (cosr = cos(rotation); sinr = sin(rotation); Matrix3{T}(cosr, sinr, 0, -sinr, cosr, 0, 0, 0, 1))
scalematrix(scale::Vector2{T}) where T = Matrix3{T}(scale[1], 0, 0, 0, scale[2], 0, 0, 0, 1)


"""
Simple data structure comprised of 2 `Vector2`s representing the bottom left and top right corners of a rectangle.
Used e.g. to address a subsection of a texture.
"""
struct Rect{T<:Number}
    min::Vector2{T}
    max::Vector2{T}
end
Rect{T}(minx, miny, maxx, maxy) where T = Rect{T}(Vector2{T}(T(minx), T(miny)), Vector2{T}(T(maxx), T(maxy)))
Rect(minx, miny, maxx, maxy) = ((minx, miny, maxx, maxy) = promote(minx, miny, maxx, maxy); Rect(Vector2(minx, miny), Vector2(maxx, maxy)))
