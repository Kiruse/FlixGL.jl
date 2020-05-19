using ModernGL

export AbstractTextureWrap, RepeatWrap, RepeatMirroredWrap, ClampToEdgeWrap, ClampToBorderWrap
export wrapping!

abstract type AbstractTextureWrap end
struct RepeatWrap         <: AbstractTextureWrap end
struct RepeatMirroredWrap <: AbstractTextureWrap end
struct ClampToEdgeWrap    <: AbstractTextureWrap end
struct ClampToBorderWrap  <: AbstractTextureWrap end
gltype(::Type{RepeatWrap})         = ModernGL.GL_REPEAT
gltype(::Type{RepeatMirroredWrap}) = ModernGL.GL_MIRRORED_REPEAT
gltype(::Type{ClampToEdgeWrap})    = ModernGL.GL_CLAMP_TO_EDGE
gltype(::Type{ClampToBorderWrap})  = ModernGL.GL_CLAMP_TO_BORDER

function wrapping!(tex::Texture2D, uwrap::Type{<:AbstractTextureWrap}, vwrap::Type{<:AbstractTextureWrap}; border::Union{Nothing, AbstractVector{Float32}} = nothing)
    gltex = gltype(typeof(tex))
    ModernGL.glTexParameteri( gltex, ModernGL.GL_TEXTURE_WRAP_S, gltype(uwrap))
    ModernGL.glTexParameteri( gltex, ModernGL.GL_TEXTURE_WRAP_T, gltype(vwrap))
    
    if border !== nothing
        @assert length(border) == 4
        ModernGL.glTexParameterfv(gltex, ModernGL.GL_TEXTURE_BORDER_COLOR, pointer(border))
    end
    
    tex
end
