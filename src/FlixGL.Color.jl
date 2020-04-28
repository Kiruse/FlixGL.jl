######################################################################
# Provides various color structs and color related methods and operators.
# -----
# While technically only a single struct to represent them all would be necessary, providing various structs allows for
# smaller footprint storage. These varying types are used especially for data up- and download to and from the GPU.

using StaticArrays
using Printf

export AbstractColor, Color, OpaqueColor, GrayscaleColor, OpaqueGrayscaleColor
export NormColor, NormColor3, ByteColor, ByteColor3, NormGrayscaleA, NormGrayscale, ByteGrayscaleA, ByteGrayscale
export mix
export Red, Green, Blue, Yellow, Cyan, Magenta, White, Black, Alpha

abstract type AbstractColor{T<:Number} end

struct Color{T} <: AbstractColor{T}
    r::T
    g::T
    b::T
    a::T
end
Color{T}(r, g, b) where T = Color{T}(r, g, b, 0)
Color(r::Number, g::Number, b::Number, a::Number = 0) = ((r, g, b, a) = promote(r, g, b, a); Color{typeof(r)}(r, g, b, a))
Color{UInt8}(hex::UInt32) = Color{UInt8}(UInt8(hex >> 24 & 0xFF), UInt8(hex >> 16 & 0xFF), UInt8(hex >> 8 & 0xFF), UInt8(hex & 0xFF))
Color(hex::UInt32) = Color{UInt8}(hex)

struct OpaqueColor{T} <: AbstractColor{T}
    r::T
    g::T
    b::T
end
OpaqueColor(r::Number, g::Number, b::Number) = ((r, g, b) = promote(r, g, b); OpaqueColor{typeof(r)}(r, g, b))
OpaqueColor{UInt8}(hex::UInt32) = OpaqueColor{UInt8}(UInt8(hex >> 16 & 0xFF), UInt8(hex >> 8 & 0xFF), UInt8(hex & 0xFF))
OpaqueColor(hex::UInt32) = OpaqueColor{UInt8}(hex)

struct GrayscaleColor{T} <: AbstractColor{T}
    v::T
    a::T
end
GrayscaleColor{T}(v) where T = GrayscaleColor{T}(v, 0)
GrayscaleColor(v::Number, a::Number = 0) = GrayscaleColor(promote(v, a)...)

struct OpaqueGrayscaleColor{T} <: AbstractColor{T}
    v::T
end

const NormColor  = Color{Float32}
const NormColor3 = OpaqueColor{Float32}
const ByteColor  = Color{UInt8}
const ByteColor3 = OpaqueColor{UInt8}
const NormGrayscaleA = GrayscaleColor{Float32}
const NormGrayscale  = OpaqueGrayscaleColor{Float32}
const ByteGrayscaleA = GrayscaleColor{UInt8}
const ByteGrayscale  = OpaqueGrayscaleColor{UInt8}


# Array Conversions
Base.convert(::Type{SVector{4, T}}, color::Color{T})       where T = SVector(color.r, color.g, color.b, color.a)
Base.convert(::Type{SVector{3, T}}, color::OpaqueColor{T}) where T = SVector(color.r, color.g, color.b)
Base.convert(::Type{SVector{2, T}}, color::GrayscaleColor{T})       where T = SVector(color.v, color.a)
Base.convert(::Type{SVector{1, T}}, color::OpaqueGrayscaleColor{T}) where T = SVector(color.v)
Base.collect(color::Color) = [color.r, color.g, color.b, color.a]
Base.collect(color::OpaqueColor) = [color.r, color.g, color.b]
Base.collect(color::GrayscaleColor) = [color.v, color.a]
Base.collect(color::OpaqueGrayscaleColor) = [color.v]
tosvector(color::Color{T})       where T = convert(SVector{4, T}, color)
tosvector(color::OpaqueColor{T}) where T = convert(SVector{3, T}, color)
tosvector(color::GrayscaleColor{T})       where T = convert(SVector{2, T}, color)
tosvector(color::OpaqueGrayscaleColor{T}) where T = convert(SVector{1, T}, color)

colortypefamily(::Type{<:Color}) = Color
colortypefamily(::Type{<:OpaqueColor}) = OpaqueColor
colortypefamily(::Type{<:GrayscaleColor}) = GrayscaleColor
colortypefamily(::Type{<:OpaqueGrayscaleColor}) = OpaqueGrayscaleColor
colortypeparam(::Type{<:AbstractColor{T}}) where T = T

numchannels(::Type{<:Color}) = 4
numchannels(::Type{<:OpaqueColor}) = 3
numchannels(::Type{<:GrayscaleColor}) = 2
numchannels(::Type{<:OpaqueGrayscaleColor}) = 1

function getintermediateconversiontype(fam1, fam2, ch1, ch2)
    if numchannels(fam1) < numchannels(fam2)
        fam1{ch2}
    else
        fam2{ch1}
    end
end


# Same Channel Type Conversions
# Converts intx<->inty and floatx<->floaty using color with less channels.
function Base.convert(T1::Type{<:AbstractColor{I1}}, color::AbstractColor{I2}) where {I1<:Integer, I2<:Integer}
    T2 = typeof(color)
    fam1 = colortypefamily(T1)
    fam2 = colortypefamily(T2)
    
    if fam1 == fam2
        if I1 == I2 return color end
        conv = typemax(I1) / typemax(I2)
        T1(floor.(I1, tosvector(color) .* conv)...)
    else
        convert(T1, convert(getintermediateconversiontype(fam1, fam2, I1, I2), color))
    end
end
function Base.convert(T1::Type{<:AbstractColor{F1}}, color::AbstractColor{F2}) where {F1<:AbstractFloat, F2<:AbstractFloat}
    T2 = typeof(color)
    fam1 = colortypefamily(T1)
    fam2 = colortypefamily(T2)
    
    if fam1 == fam2
        if F1 == F2 return color end
        T1(F1.(tosvector(color))...)
    else
        convert(T1, convert(getintermediateconversiontype(fam1, fam2, F1, F2), color))
    end
end

# Cross-Type Conversions w/ Mixed Channel Type
# Converts float<->int using color with less channels.
function Base.convert(T1::Type{<:AbstractColor{I}}, color::AbstractColor{F}) where {I<:Integer, F<:AbstractFloat}
    T2 = typeof(color)
    fam1 = colortypefamily(T1)
    fam2 = colortypefamily(T2)
    if fam1 == fam2
        conv = typemax(I)
        T1(floor.(I, tosvector(color) .* conv)...)
    else
        convert(T1, convert(getintermediateconversiontype(fam1, fam2, I, F), color))
    end
end
function Base.convert(T1::Type{<:AbstractColor{F}}, color::AbstractColor{I}) where {I<:Integer, F<:AbstractFloat}
    T2 = typeof(color)
    fam1 = colortypefamily(T1)
    fam2 = colortypefamily(T2)
    if fam1 == fam2
        conv = 1/typemax(I)
        T1(F.(tosvector(color) .* conv)...)
    else
        convert(T1, convert(getintermediateconversiontype(fam1, fam2, F, I), color))
    end
end

# Cross-Type Conversions w/ Same Channel Type
# Mixed channel types are handled using above methods.
Base.convert(::Type{OpaqueColor{T}}, color::Color{T}) where T = OpaqueColor{T}(color.r, color.g, color.b)
Base.convert(::Type{Color{T}}, color::OpaqueColor{T}) where T = Color{T}(color.r, color.g, color.b, 0)

Base.convert(::Type{OpaqueGrayscaleColor{T}}, color::GrayscaleColor{T}) where T = OpaqueGrayscaleColor{T}(color.v)
Base.convert(::Type{GrayscaleColor{T}}, color::OpaqueGrayscaleColor{T}) where T = GrayscaleColor{T}(color.v, 0)

Base.convert(::Type{OpaqueColor{T}}, color::Union{GrayscaleColor{T}, OpaqueGrayscaleColor{T}}) where T = OpaqueColor{T}(color.v, color.v, color.v)
Base.convert(::Type{Color{T}}, color::GrayscaleColor{T})       where T = Color{T}(color.v, color.v, color.v, color.a)
Base.convert(::Type{Color{T}}, color::OpaqueGrayscaleColor{T}) where T = Color{T}(color.v, color.v, color.v, 0)

# Cross-Channel Promotion Rules
Base.promote_rule(::Type{Color{T1}}, ::Type{Color{T2}}) where {T1, T2} = Color{promote_type(T1, T2)}
Base.promote_rule(::Type{OpaqueColor{T1}}, ::Type{OpaqueColor{T2}}) where {T1, T2} = OpaqueColor{promote_type(T1, T2)}
Base.promote_rule(::Type{GrayscaleColor{T1}}, ::Type{GrayscaleColor{T2}}) where {T1, T2} = GrayscaleColor{promote_type(T1, T2)}
Base.promote_rule(::Type{OpaqueGrayscaleColor{T1}}, ::Type{OpaqueGrayscaleColor{T2}}) where {T1, T2} = OpaqueGrayscaleColor{promote_type(T1, T2)}

# Cross-Type Promotion Rules
Base.promote_rule(T::Type{<:Color}, ::Type{<:OpaqueColor}) = T
Base.promote_rule(::Type{<:GrayscaleColor}, ::Union{Type{<:Color{T}}, Type{<:OpaqueColor{T}}}) where T = Color{T}
Base.promote_rule(::Type{<:OpaqueGrayscaleColor}, T::Union{Type{<:Color}, Type{<:OpaqueColor}}) = T


# Same-Type Arithmetics
Base.:+(lhs::T, rhs::T) where {T<:AbstractColor} = T((tosvector(lhs) .+ tosvector(rhs))...)
Base.:-(lhs::T, rhs::T) where {T<:AbstractColor} = T((tosvector(lhs) .- tosvector(rhs))...)
Base.:*(lhs::T, rhs::T) where {T<:AbstractColor} = T((tosvector(lhs) .* tosvector(rhs))...)
Base.:/(lhs::T, rhs::T) where {T<:AbstractColor} = T((tosvector(lhs) ./ tosvector(rhs))...)

Base.:*(lhs::Number, rhs::T) where {T<:AbstractColor} = T((lhs * tosvector(rhs))...)
Base.:*(lhs::T, rhs::Number) where {T<:AbstractColor} = rhs * lhs
Base.:/(lhs::Number, rhs::T) where {T<:AbstractColor} = T([lhs/comp for comp ∈ tosvector(rhs)]...)
Base.:/(lhs::T, rhs::Number) where {T<:AbstractColor} = T((tosvector(lhs) / rhs)...)

# Cross-Type Arithmetics
Base.:+(lhs::AbstractColor, rhs::AbstractColor) = +(promote(lhs, rhs)...)
Base.:-(lhs::AbstractColor, rhs::AbstractColor) = -(promote(lhs, rhs)...)
Base.:*(lhs::AbstractColor, rhs::AbstractColor) = *(promote(lhs, rhs)...)
Base.:/(lhs::AbstractColor, rhs::AbstractColor) = /(promote(lhs, rhs)...)


# Color Mixing
mix(first::T, second::T, alpha::AbstractFloat) where {T<:AbstractColor} = (alpha = clamp(alpha, 0, 1); T((tosvector(first) .* (1-alpha) .+ tosvector(second) .* alpha)...))
mix(first::AbstractColor, second::AbstractColor, alpha::AbstractFloat)  = mix(promote(first, second)..., alpha)


# Show colors
Base.show(io::IO, color::ByteColor)   = write(io, "#$(bytes2hex([color.r, color.g, color.b, color.a]))")
Base.show(io::IO, color::ByteColor3)  = write(io, "#$(bytes2hex([color.r, color.g, color.b]))")
Base.show(io::IO, color::Color)       = show(io, convert(ByteColor, color))
Base.show(io::IO, color::OpaqueColor) = show(io, convert(ByteColor3, color))
Base.show(io::IO, color::NormGrayscaleA)       = @printf(io, "V%.2f%%, A%.2f%%", 100color.v, 100color.a)
Base.show(io::IO, color::NormGrayscale)        = @printf(io, "V%.2f%%", 100color.v)
Base.show(io::IO, color::GrayscaleColor)       = show(io, convert(NormGrayscaleA, color))
Base.show(io::IO, color::OpaqueGrayscaleColor) = show(io, convert(NormGrayscale,  color))

# Write color to buffer
Base.write(io::IO, color::AbstractColor) = Base.write(io, collect(color))

# Transposing color has no effect
Base.transpose(color::AbstractColor) = color

# zero & one functions
Base.zero(color_t::Type{<:AbstractColor{T}}) where T = color_t(zeros(T, numchannels(color_t))...)
Base.one(color_t::Type{<:AbstractColor{F}}) where {F<:AbstractFloat} = color_t(ones(F, numchannels(color_t))...)
Base.one(color_t::Type{<:AbstractColor{I}}) where {I<:Integer} = color_t((typemax(I) for _ ∈ 1:numchannels(color_t))...)


# Constant colors
const Red     = NormColor(1, 0, 0)
const Green   = NormColor(0, 1, 0)
const Blue    = NormColor(0, 0, 1)
const Yellow  = NormColor(1, 1, 0)
const Cyan    = NormColor(0, 1, 1)
const Magenta = NormColor(1, 0, 1)
const Black   = NormColor(0, 0, 0)
const White   = NormColor(1, 1, 1)
const Alpha   = NormColor(0, 0, 0, 1)
