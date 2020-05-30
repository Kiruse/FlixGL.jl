using ModernGL

export AbstractTexture, Texture2D
export AbstractComponentLayout, RLayout, RGLayout, RGBLayout, BGRLayout, RGBALayout, BGRALayout, DepthLayout, DepthStencilLayout
export texture, texture_upload, texture_download, texture_gen_mipmaps

const GL_TEX_INTEGERS = Union{Int8, UInt8, Int16, UInt16, Int32, UInt32}
const GL_TEX_DECIMALS = Union{Float16, Float32}
const GL_TEX_NUMERICS = Union{GL_TEX_INTEGERS, GL_TEX_DECIMALS}

abstract type AbstractTexture end
abstract type AbstractComponentLayout end
abstract type AbstractTextureOGLFormat end

# Texture data layouts
struct RLayout     <: AbstractComponentLayout end
struct RGLayout    <: AbstractComponentLayout end
struct RGBLayout   <: AbstractComponentLayout end
struct BGRLayout   <: AbstractComponentLayout end
struct RGBALayout  <: AbstractComponentLayout end
struct BGRALayout  <: AbstractComponentLayout end
struct DepthLayout <: AbstractComponentLayout end
struct DepthStencilLayout <: AbstractComponentLayout end
gltype(::Type{RLayout})     = ModernGL.GL_RED
gltype(::Type{RGLayout})    = ModernGL.GL_RG
gltype(::Type{RGBLayout})   = ModernGL.GL_RGB
gltype(::Type{BGRLayout})   = ModernGL.GL_BGR
gltype(::Type{RGBALayout})  = ModernGL.GL_RGBA
gltype(::Type{BGRALayout})  = ModernGL.GL_BGRA
gltype(::Type{DepthLayout}) = ModernGL.GL_DEPTH_COMPONENT
gltype(::Type{DepthStencilLayout}) = ModernGL.GL_DEPTH_STENCIL
gltexformat(layout_t::Type{<:AbstractComponentLayout}) = gltype(layout_t)
gltexformat(::Type{BGRLayout})  = gltype(RGBLayout)
gltexformat(::Type{BGRALayout}) = gltype(RGBALayout)


struct Texture2D <: AbstractTexture
    glid::Integer
end

gltype(::Type{Texture2D}) = ModernGL.GL_TEXTURE_2D


function texture(tex_t::Type{<:AbstractTexture}, data::AbstractVector{UInt8}, width::Integer, height::Integer, complayout::Type{<:AbstractComponentLayout}, comptype::Type{<:Number}; level::Integer = 1, generate_mipmaps::Bool = false)
    tex = texture(tex_t)
    texture_upload(tex, data, width, height, complayout, comptype, level=level)
    if generate_mipmaps
        texture_gen_mipmaps(tex)
    end
    tex
end

function texture(tex_t::Type{<:AbstractTexture}, n::Integer = 1)
    ids = zeros(UInt32, n)
    ModernGL.glGenTextures(n, pointer(ids))
    
    texes = tex_t[]
    for id ∈ ids
        tex = tex_t(id)
        push!(texes, tex)
    end
    
    if n == 1
        return texes[1]
    else
        return texes
    end
end

function texture_upload(tex::Texture2D, img::AbstractVector{UInt8}, width::Integer, height::Integer, complayout::Type{<:AbstractComponentLayout}, comptype::Type{<:Number}; level::Integer = 1)
    texture_upload_internal(tex, img, width, height, level-1, complayout, gltexformat(complayout), comptype)
end

# TODO: Currently only supports float and half decimals. Support integers as well.
function texture_upload_internal(tex::Texture2D, data::AbstractVector{UInt8}, width::Integer, height::Integer, level::Integer, complayout::Type{<:AbstractComponentLayout}, glformat, comptype::Type{<:AbstractFloat})
    LowLevel.use(tex)
    ModernGL.glTexImage2D(gltype(typeof(tex)), level, glformat, width, height, 0, gltype(complayout), gltype(comptype), pointer(data))
    checkglerror()
end

function texture_download(tex::Texture2D)
    # TODO: use glCopyTexImage2D
    error("Not implemented")
end

function texture_gen_mipmaps(tex::AbstractTexture)
    use(tex)
    ModernGL.glGenerateMipmap(gltype(typeof(tex)))
    checkglerror()
end

function use(tex::AbstractTexture; unit::Integer = 1)
    @assert unit ∈ 1:maxtexturecount()
    ModernGL.glActiveTexture(ModernGL.GL_TEXTURE0 + unit-1)
    ModernGL.glBindTexture(gltype(typeof(tex)), tex.glid)
    checkglerror()
end

function Base.close(tex::AbstractTexture)
    ModernGL.glDeleteTextures(1, pointer([tex.glid]))
    checkglerror()
end


function maxtexturecount()
    global _maxtexturecount
    if _maxtexturecount == nothing
        ref = Ref{Int32}(0)
        ModernGL.glGetIntegerv(ModernGL.GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, ref)
        checkglerror()
        _maxtexturecount = ref[]
    end
    _maxtexturecount
end
_maxtexturecount = nothing
