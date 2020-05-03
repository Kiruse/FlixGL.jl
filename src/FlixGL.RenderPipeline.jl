export AbstractRenderPipeline, ForwardRenderPipeline, DeferredRenderPipeline
export render, setbgcolor, getbgcolor

abstract type AbstractRenderPipeline end
struct ForwardRenderPipeline <: AbstractRenderPipeline end
struct DeferredRenderPipeline <: AbstractRenderPipeline end


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
