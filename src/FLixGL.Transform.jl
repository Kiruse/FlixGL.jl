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
scale!(    transform::Transform2D{T}, sca::Vector2{T}) where T = (transform.scale    .*= sca)

function asmatrix(transform::Transform2D{T}) where T
    if !transform.dirty
        return transform.mat
    end
    
    l = transform.location
    s = transform.scale
    
    cosr = cos(transform.rotation)
    sinr = sin(transform.rotation)
    
    transform.mat = Matrix3{T}([s.x*cosr    -sinr   l.x ;
                                  sinr    s.y*cosr  l.y ;
                                   0          0      1  ])
end
