export EntityClass, RegularEntity, EmptyEntity, entityclass
export AbstractEntity, AbstractEntity2D
export parentof, childrenof, isrenderable

abstract type EntityClass end
struct WorldEntity <: EntityClass end
entityclass(::Type) = WorldEntity()

abstract type AbstractEntity end
abstract type AbstractEntity2D <: AbstractEntity end

# Entity Characteristics
isrenderable(::Type{<:AbstractEntity}) = false
vertsof(    ntt::AbstractEntity) = error("Not implemented")
countverts( ntt::AbstractEntity) = length(vertsof(ntt))
vaoof(      ntt::AbstractEntity) = ntt.vao
transformof(ntt::AbstractEntity) = ntt.transform
materialof( ntt::AbstractEntity) = ntt.material
drawmodeof( ntt::AbstractEntity) = LowLevel.TrianglesDrawMode

VPECore.translate!(ntt::AbstractEntity, offset)   = translate!(transformof(ntt), offset)
VPECore.rotate!(   ntt::AbstractEntity, rotation) = rotate!(   transformof(ntt), rotation)
VPECore.scale!(    ntt::AbstractEntity, scale)    = scale!(    transformof(ntt), scale)
VPECore.obj2world(ntt::AbstractEntity) = obj2world(transformof(ntt))
VPECore.world2obj(ntt::AbstractEntity) = world2obj(transformof(ntt))

# Free OpenGL resources at will
function destroy(ntt::AbstractEntity)
    delete(vaoof(ntt))
end


VPECore.parent!(child::AbstractEntity, parent::AbstractEntity) = parent!(transformof(child), transformof(parent))
VPECore.deparent!(ntt::AbstractEntity) = deparent!(transformof(ntt))
parentof(child::AbstractEntity) = getcustomdata(AbstractEntity, transformof(child))
childrenof(T::Type{<:AbstractEntity}, ntt::AbstractEntity) = filter!(child -> child !== nothing, [getcustomdata(T, child) for child ∈ transformof(ntt).children])
childrenof(ntt::AbstractEntity) = childrenof(AbstractEntity, ntt)
Base.push!(world::World, ntt::AbstractEntity) = push!(world, transformof(ntt))
Base.delete!(world::World, ntt::AbstractEntity) = delete!(world, transformof(ntt))


function getrectcoords(width, height, originoffset)
    halfwidth  = width  / 2
    halfheight = height / 2
    offx, offy = originoffset .* (halfwidth, halfheight)
    Float32[
        -halfwidth + offx, -halfheight + offy,
         halfwidth + offx, -halfheight + offy,
         halfwidth + offx,  halfheight + offy,
        -halfwidth + offx,  halfheight + offy
    ]
end


include("./FlixGL.Entity.Sprite.jl")
include("./FlixGL.Entity.Empty.jl")
