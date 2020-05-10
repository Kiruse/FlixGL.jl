export AbstractEntity, AbstractEntity2D
export @proxyentity

macro proxyentity(type, prop)
    esc(quote
        FlixGL.vertsof(ntt::$type)     = FlixGL.vertsof(ntt.$prop)
        FlixGL.countverts(ntt::$type)  = FlixGL.countverts(ntt.$prop)
        FlixGL.vaoof(ntt::$type)       = FlixGL.vaoof(ntt.$prop)
        FlixGL.transformof(ntt::$type) = FlixGL.transformof(ntt.$prop)
        FlixGL.materialof(ntt::$type)  = FlixGL.materialof(ntt.$prop)
        FlixGL.drawmodeof(ntt::$type)  = FlixGL.drawmodeof(ntt.$prop)
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
