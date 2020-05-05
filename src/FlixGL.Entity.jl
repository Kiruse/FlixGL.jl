export AbstractEntity, AbstractEntity2D
export @proxyentity

macro proxyentity(type, prop)
    esc(quote
        vertsof(ntt::$type)     = vertsof(ntt.$prop)
        countverts(ntt::$type)  = countverts(ntt.$prop)
        vaoof(ntt::$type)       = vaoof(ntt.$prop)
        transformof(ntt::$type) = transformof(ntt.$prop)
        materialof(ntt::$type)  = materialof(ntt.$prop)
        drawmodeof(ntt::$type)  = drawmodeof(ntt.$prop)
    end)
end

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
