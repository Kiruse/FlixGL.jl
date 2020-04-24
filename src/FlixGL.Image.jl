using CodecZlib

export AbstractImage, AbstractImageFormat
export decode, load_image, pixels, extract_color_type

abstract type AbstractImage end
abstract type AbstractImageFormat end

struct Image2D <: AbstractImage
    data::AbstractArray{<:AbstractColor, 2}
end

Base.size(img::AbstractImage) = ((rows, cols) = size(img.data); (cols, rows))
LowLevel.bytes(img::AbstractImage) = LowLevel.bytes(transpose(pixels(img)))
pixels(img::AbstractImage) = img.data

vflip!(img::AbstractImage) = (vflip!(pixels(img)); img)
hflip!(img::AbstractImage) = (hflip!(pixels(img)); img)

include("./FlixGL.Image.PNG.jl")


function load_image(format::Type{<:AbstractImageFormat}, path::AbstractString; flip_vertically::Bool = false, flip_horizontally::Bool = false)
    res = open(path, "r+") do file
        contents = read(file)
        decode(format, contents)
    end
    
    # Standard image formats define Y axis to start at the top and to continue downwards.
    # OpenGL defines Y axis to start at bottom and continue upwards.
    # Hence, by default, image is vertically flipped, but for consistency of arguments, flip_vertically is negated here.
    if !flip_vertically
        vflip!(res)
    end
    if flip_horizontally
        hflip!(res)
    end
    res
end

extract_color_type(img::AbstractImage) = extract_color_type(typeof(pixels(img)))
extract_color_type(::Type{<:AbstractArray{T}}) where {T<:AbstractColor} = T
