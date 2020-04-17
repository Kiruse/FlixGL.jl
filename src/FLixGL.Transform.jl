export AbstractTransform, Transform2D
export translate!, rotate!, scale!, asmatrix

abstract type AbstractTransform{T<:Number} end

mutable struct Transform2D{T} <: AbstractTransform{T}
    location::Vector2{T}
    rotation::T
    scale::Vector2{T}
end
Transform2D{T}() where T = Transform2D{T}(Vector2{T}(zeros(T, 2)...), zero(T), Vector2{T}(ones(T, 2)...))
Transform2D() = Transform2D{Float64}()

translate!(transform::Transform2D{T}, off::Vector2{T}) where T = (transform.location += off)
rotate!(   transform::Transform2D{T}, rot::T)          where T = (transform.rotation += rot)
scale!(    transform::Transform2D{T}, sca::Vector2{T}) where T = (transform.scale   .*= sca)

function asmatrix(transform::Transform2D{T}) where T
    l = transform.location
    s = transform.scale
    
    cosr = cos(transform.rotation)
    sinr = sin(transform.rotation)
    
    Matrix3{T}([s[1]*cosr    -sinr   l[1] ;
                  sinr    s[2]*cosr  l[2] ;
                   0          0       1   ])
end
