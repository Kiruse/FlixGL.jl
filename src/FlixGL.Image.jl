using CodecZlib

export AbstractImage, AbstractImageFormat
export decode, load_image, pixels

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


function load_image(format::Type{<:AbstractImageFormat}, path::AbstractString)
    open(path, "r+") do file
        contents = read(file)
        decode(format, contents)
    end
end
