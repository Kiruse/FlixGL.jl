######################################################################
# Provides wrapper classes for the LowLevel counterpieces in order to
# integrate them with the higher level Image classes.

export AbstractTexture, Texture2D
export texture

abstract type AbstractTexture end

struct Texture2D <: AbstractTexture
    internal::LowLevel.Texture2D
end
Base.size(tex::AbstractTexture) = size(tex.internal)

function texture(img::Image2D)
    width, height = size(img)
    Texture2D(LowLevel.texture(LowLevel.Texture2D, LowLevel.bytes(img), width, height, TextureInternal.componentlayout(img), TextureInternal.componenttype(img), generate_mipmaps=true))
end

# TODO: DepthTexture and DepthStencilTexture structs


module TextureInternal
using ..FlixGL
import ..LowLevel

extract_color_type(img::AbstractImage) = extract_color_type(typeof(pixels(img)))
extract_color_type(::Type{<:AbstractArray{T}}) where {T<:AbstractColor} = T

componentlayout(img::AbstractImage)    = componentlayout(extract_color_type(img))
componentlayout(::Type{<:OpaqueColor}) = LowLevel.RGBLayout
componentlayout(::Type{<:Color})       = LowLevel.RGBALayout

componenttype(img::AbstractImage) = componenttype(extract_color_type(img))
componenttype(::Type{<:AbstractColor{T}}) where T = T
end
