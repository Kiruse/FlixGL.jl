export Vector2, Vector3, Vector4
export Matrix2, Matrix3, Matrix4
export xcoord, ycoord, zcoord, wcoord
export getelement

const Matrix2{T} = SMatrix{2, 2, T}
const Matrix3{T} = SMatrix{3, 3, T}
const Matrix4{T} = SMatrix{4, 4, T}

const Vector2{T} = SVector{2, T}
const Vector3{T} = SVector{3, T}
const Vector4{T} = SVector{4, T}

xcoord(vec) = vec[1]
ycoord(vec) = vec[2]
zcoord(vec) = vec[3]
wcoord(vec) = vec[4]


function Base.write(io::IO, vec::SVector{N}) where N
    for i ∈ 1:N
        write(io, vec[i])
    end
end

function Base.write(io::IO, mat::SMatrix{N, M}) where {N, M}
    for n ∈ 1:N
        for m ∈ 1:M
            write(io, getelement(mat, n, m))
        end
    end
end

function getelement(mat::SMatrix{N, M}, col::Integer, row::Integer) where {N, M}
    @assert col > 0 && row > 0 && col <= N && row <= M
    col * M + row
end


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
