export AbstractRenderPipeline, ForwardRenderPipeline, DeferredRenderPipeline
export AbstractRenderSpace, WorldRenderSpace, ScreenRenderSpace
export render, render_background, getrenderables, getrenderables!, setbgcolor, getbgcolor

abstract type AbstractRenderPipeline end
struct ForwardRenderPipeline <: AbstractRenderPipeline end
struct DeferredRenderPipeline <: AbstractRenderPipeline end

abstract type AbstractRenderSpace end
struct WorldRenderSpace <: AbstractRenderSpace end
struct ScreenRenderSpace <: AbstractRenderSpace end


function setbgcolor(color::NormColor3)
    global _bgcolor
    global _bgsprite
    
    if _bgsprite == nothing
        # BGSprite enjoys special treatment. It's always rendered first and its screen transform is the identity matrix.
        texcol = White+Alpha
        _bgsprite = Sprite2D(2, 2, texture(Image2D([texcol texcol; texcol texcol])), taint=color+Alpha)
    else
        update!(_bgsprite, taint=color+Alpha)
    end
    
    _bgcolor = color
end
getbgcolor() = _bgcolor
getbgsprite() = _bgsprite
_bgcolor = NormColor3(0, 0, 0)
_bgsprite = nothing


function getrenderables(T::Type{<:AbstractEntity}, world::World, cls::Type{<:EntityClass})
    results = T[]
    getrenderables!(results, world, cls)
    results
end
function getrenderables!(results::Vector{T}, world::World, cls::Type{<:EntityClass}) where {T<:AbstractEntity}
    collectentities!(results, world, cls)
    filter!(ntt->wantsrender(ntt), results)
end
