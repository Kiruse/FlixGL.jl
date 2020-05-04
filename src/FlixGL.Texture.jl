######################################################################
# Provides wrapper classes for the LowLevel counterpieces in order to
# integrate them with the higher level Image classes.
import .LowLevel: AbstractTextureWrap, RepeatWrap, RepeatMirroredWrap, ClampToEdgeWrap, ClampToBorderWrap

export AbstractTexture, Texture2D
export AbstractTextureWrap, RepeatWrap, RepeatMirroredWrap, ClampToEdgeWrap, ClampToBorderWrap
export texture, wrapping!

abstract type AbstractTexture end

struct Texture2D <: AbstractTexture
    internal::LowLevel.Texture2D
end
Base.size(tex::AbstractTexture) = size(tex.internal)

function texture(img::Image2D)
    width, height = size(img)
    Texture2D(LowLevel.texture(LowLevel.Texture2D, LowLevel.bytes(img), width, height, TextureInternal.componentlayout(img), TextureInternal.componenttype(img), generate_mipmaps=true))
end

function wrapping!(tex::Texture2D, uwrap::Type{<:AbstractTextureWrap}, vwrap::Type{<:AbstractTextureWrap}; border::NormColor = Black+Alpha)
    LowLevel.wrapping!(tex.internal, uwrap, vwrap, border=collect(border))
    tex
end

# TODO: DepthTexture and DepthStencilTexture structs


module TextureInternal
using ..FlixGL
import ..LowLevel

componentlayout(img::AbstractImage)    = componentlayout(extract_color_type(img))
componentlayout(::Type{<:OpaqueColor}) = LowLevel.RGBLayout
componentlayout(::Type{<:Color})       = LowLevel.RGBALayout
componentlayout(::Type{<:GrayscaleColor}) = LowLevel.RGLayout
componentlayout(::Type{<:OpaqueGrayscaleColor}) = LowLevel.RLayout

componenttype(img::AbstractImage) = componenttype(extract_color_type(img))
componenttype(::Type{<:AbstractColor{T}}) where T = T
end
