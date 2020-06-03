export Empty2D

struct Empty2D{T<:Real} <: AbstractEntity2D
    transform::Entity2DTransform{T}
end
Empty2D(transform::Entity2DTransform{T} = defaulttransform()) where T = Empty2D{T}(transform)
