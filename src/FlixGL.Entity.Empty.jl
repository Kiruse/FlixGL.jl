export Empty2D

struct Empty2D <: AbstractEntity2D end
entityclass(::Type{Empty2D}) = EmptyEntity()
