export AbstractEntity, AbstractEntity2D

abstract type AbstractEntity end
abstract type AbstractEntity2D <: AbstractEntity end

# Entity Traits
vaoof(      ntt::AbstractEntity) = ntt.vao
transformof(ntt::AbstractEntity) = ntt.transform
materialof( ntt::AbstractEntity) = ntt.material
texturesof( ntt::AbstractEntity) = ntt.textures
drawmodeof( ntt::AbstractEntity) = LowLevel.TrianglesDrawMode

# Free OpenGL resources at will
function destroy(ntt::AbstractEntity)
    delete(vaoof(ntt))
end


# struct Polygon <: AbstractEntity2D
#     vao::VertexInternal.AbstractVAOWrapper
#     transform::Transform2D
#     material::AbstractMaterial
#     # textures::Dict{<:AbstractString, <:AbstractTexture}
# end

# struct Sprite <: AbstractEntity2D
#     vao::VertexInternal.TexturedVertexVAO
#     transform::Transform2D
#     material::AbstractMaterial
#     textures::Dict{<:AbstractString, <:AbstractTexture}
# end
