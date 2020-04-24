export AbstractEntity, AbstractEntity2D

abstract type AbstractEntity end
abstract type AbstractEntity2D <: AbstractEntity end

# Entity Traits
vertsof(    ntt::AbstractEntity) = error("Not implemented")
countverts( ntt::AbstractEntity) = length(vertsof(ntt))
vaoof(      ntt::AbstractEntity) = ntt.vao
transformof(ntt::AbstractEntity) = ntt.transform
materialof( ntt::AbstractEntity) = ntt.material
drawmodeof( ntt::AbstractEntity) = LowLevel.TrianglesDrawMode

# Free OpenGL resources at will
function destroy(ntt::AbstractEntity)
    delete(vaoof(ntt))
end


include("./FlixGL.Entity.Sprite.jl")
