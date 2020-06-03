export Empty2D

struct Empty2D{T<:Real} <: AbstractEntity2D
    transform::Transform2D{T}
end
Empty2D(transform::SomeTransform2D{T} = defaulttransform()) where T = Empty2D{T}(transform)
