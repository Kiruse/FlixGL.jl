export Empty2D

struct Empty2D <: AbstractEntity2D end
isrenderable(::Type{Empty2D}) = false
