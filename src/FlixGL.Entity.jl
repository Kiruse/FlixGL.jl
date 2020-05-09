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

VPEWorlds.translate!(ntt::AbstractEntity, offset)   = translate!(transformof(ntt), offset)
VPEWorlds.rotate!(   ntt::AbstractEntity, rotation) = rotate!(   transformof(ntt), rotation)
VPEWorlds.scale!(    ntt::AbstractEntity, scale)    = scale!(    transformof(ntt), scale)
VPEWorlds.obj2world(ntt::AbstractEntity) = obj2world(transformof(ntt))
VPEWorlds.world2obj(ntt::AbstractEntity) = world2obj(transformof(ntt))

# Free OpenGL resources at will
function destroy(ntt::AbstractEntity)
    delete(vaoof(ntt))
end


VPEWorlds.parent!(child::AbstractEntity, parent::AbstractEntity) = parent!(transformof(child), transformof(parent))
VPEWorlds.deparent!(ntt::AbstractEntity) = deparent!(transformof(ntt))
parentof(child::AbstractEntity) = getcustomdata(AbstractEntity, transformof(ntt))
Base.push!(world::World, ntt::AbstractEntity) = push!(world, transformof(ntt))
Base.delete!(world::World, ntt::AbstractEntity) = delete!(world, transformof(ntt))

include("./FlixGL.Entity.Sprite.jl")
