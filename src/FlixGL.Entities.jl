export EntityClass, WorldEntity, entityclass
export AbstractEntity, AbstractEntity2D
export Entity2DTransform
export vertsof
export setvisibility, isvisible, setvisible, sethidden, collectentities, collectentities!, isentityclass

abstract type EntityClass end
struct WorldEntity <: EntityClass end
entityclass(::Type) = WorldEntity()

abstract type AbstractEntity end
abstract type AbstractEntity2D <: AbstractEntity end

const Entity2DTransform{T} = Transform2D{AbstractEntity2D, T}

# Entity Characteristics
wantsrender(ntt::AbstractEntity) = false
vertsof(    ntt::AbstractEntity) = error("Not implemented")
countverts( ntt::AbstractEntity) = length(vertsof(ntt))
vaoof(      ntt::AbstractEntity) = ntt.vao
materialof( ntt::AbstractEntity) = ntt.material
drawmodeof( ntt::AbstractEntity) = LowLevel.TrianglesDrawMode
VPECore.transformof(ntt::AbstractEntity) = ntt.transform

# Generic Entity Getters/Setters
isvisible(ntt::AbstractEntity) = ntt.visible
setvisibility!(ntt::AbstractEntity, visible::Bool) = ntt.visible = visible
setvisible!(ntt::AbstractEntity) = setvisibility!(ntt, true)
sethidden!( ntt::AbstractEntity) = setvisibility!(ntt, false)

function setvisibility!(ntt::AbstractEntity, visible::Bool, propagate_to_children::Bool)
    setvisibility!(ntt, visible)
    if propagate_to_children
        foreach(childrenof(ntt)) do child
            setvisibility!(ntt, visible, true)
        end
    end
end

# Transformations
VPECore.translate!(ntt::AbstractEntity, offset)   = translate!(transformof(ntt), offset)
VPECore.rotate!(   ntt::AbstractEntity, rotation) = rotate!(   transformof(ntt), rotation)
VPECore.scale!(    ntt::AbstractEntity, scale)    = scale!(    transformof(ntt), scale)
VPECore.obj2world(ntt::AbstractEntity) = obj2world(transformof(ntt))
VPECore.world2obj(ntt::AbstractEntity) = world2obj(transformof(ntt))

# Free OpenGL resources at will
function Base.close(ntt::AbstractEntity)
    delete(vaoof(ntt))
end


# Helper method to get rectangular vertex coordinates
function getrectcoords(width, height, originoffset)
    halfwidth  = width  / 2
    halfheight = height / 2
    offx, offy = originoffset .* (halfwidth, halfheight)
    Float32[
        -halfwidth - offx, -halfheight - offy,
         halfwidth - offx, -halfheight - offy,
         halfwidth - offx,  halfheight - offy,
        -halfwidth - offx,  halfheight - offy
    ]
end


# Entity Filter
function collectentities(T::Type{<:AbstractEntity}, world::World, cls::Type{<:EntityClass})
    results = T[]
    collectentities!(results, world, cls)
    results
end
function collectentities!(results::Vector{T}, world::World, cls::Type{<:EntityClass}) where {T<:AbstractEntity}
    for root ∈ world.roots
        collectentities!(results, root, cls)
    end
    results
end
function collectentities!(results::Vector{T}, ntt::AbstractEntity, cls::Type{<:EntityClass}) where {T<:AbstractEntity}
    if isa(ntt, T)
        if isentityclass(ntt, cls)
            push!(results, ntt)
        end
        for child ∈ childrenof(T, ntt)
            collectentities!(results, child, cls)
        end
    end
    results
end

isentityclass(ntt::AbstractEntity, cls::Type{<:EntityClass}) = isa(entityclass(typeof(ntt)), cls)


include("./FlixGL.Entity.Sprite.jl")
include("./FlixGL.Entity.Empty.jl")
