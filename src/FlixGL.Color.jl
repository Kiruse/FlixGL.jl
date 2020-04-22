using StaticArrays

export AbstractColor, Color, OpaqueColor, NormColor, NormColor3, ByteColor, ByteColor3
export mix
export Red, Green, Blue, Yellow, Cyan, Magenta, White, Black, Alpha

abstract type AbstractColor{T<:Number} end

struct Color{T<:Number} <: AbstractColor{T}
    r::T
    g::T
    b::T
    a::T
end
Color{T}(r, g, b, a = 0) where T = Color{T}(r, g, b, a)
Color(r::Number, g::Number, b::Number, a::Number = 0) = Color(promote(r, g, b, a)...)
Color(hex::UInt32) = Color{UInt8}(UInt8(hex >> 24 & 0xFF), UInt8(hex >> 16 & 0xFF), UInt8(hex >> 8 & 0xFF), UInt8(hex & 0xFF))

struct OpaqueColor{T<:Number} <: AbstractColor{T}
    r::T
    g::T
    b::T
end
OpaqueColor(r::Number, g::Number, b::Number) = OpaqueColor(promote(r, g, b)...)
OpaqueColor(hex::UInt32) = OpaqueColor{UInt8}(UInt8(hex >> 16 & 0xFF), UInt8(hex >> 8 & 0xFF), UInt8(hex & 0xFF))

const NormColor  = Color{Float32}
const NormColor3 = OpaqueColor{Float32}
const ByteColor  = Color{UInt8}
const ByteColor3 = OpaqueColor{UInt8}


# Array Conversions
Base.convert(::Type{SVector{4, T}}, color::Color{T})       where T = SVector(color.r, color.g, color.b, color.a)
Base.convert(::Type{SVector{3, T}}, color::OpaqueColor{T}) where T = SVector(color.r, color.g, color.b)
Base.collect(color::Color) = [color.r, color.g, color.b, color.a]
Base.collect(color::OpaqueColor) = [color.r, color.g, color.b]
tosvector(color::Color{T})       where T = convert(SVector{4, T}, color)
tosvector(color::OpaqueColor{T}) where T = convert(SVector{3, T}, color)


# Internal Underlying Numeric Type Conversions
Base.convert(::Type{T}, color::AbstractColor{<:Integer}) where {I<:Integer, T<:AbstractColor{I}} = T(I.(tosvector(color))...)
Base.convert(::Type{T}, color::AbstractColor{<:AbstractFloat}) where {F<:AbstractFloat, T<:AbstractColor{F}} = T(F.(tosvector(color))...)

# Mixed Underlying Numeric Type Conversions
Base.convert(::Type{T}, color::AbstractColor{I}) where {F<:AbstractFloat, T<:AbstractColor{F}, I<:Integer} = (max = typemax(I); T((F.(tosvector(color)) ./ max)...))
Base.convert(::Type{T}, color::AbstractColor{F}) where {I<:Integer, T<:AbstractColor{I}, F<:AbstractFloat} = (max = typemax(I); T((floor.(I, tosvector(color) .* max))...))

# Cross-Type Conversions w/ Internal Underlying Numeric Type
Base.convert(::Type{OpaqueColor{I}}, color::Color{<:Integer}) where {I<:Integer} = OpaqueColor{I}(color.r, color.g, color.b)
Base.convert(::Type{Color{I}}, color::OpaqueColor{<:Integer}) where {I<:Integer} = Color{I}(color.r, color.g, color.b, 0)
Base.convert(::Type{OpaqueColor{F}}, color::Color{<:AbstractFloat}) where {F<:AbstractFloat} = OpaqueColor{F}(color.r, color.g, color.b)
Base.convert(::Type{Color{F}}, color::OpaqueColor{<:AbstractFloat}) where {F<:AbstractFloat} = Color{F}(color.r, color.g, color.b, 0)

# Cross-Type Conversions w/ Mixed Underlying Numeric Type
# requires one less computation if int-float conversion is done on opaque color
Base.convert(T::Type{OpaqueColor{I}}, color::Color{F}) where {I<:Integer, F<:AbstractFloat} = convert(T, convert(OpaqueColor{F}, color))
Base.convert(T::Type{OpaqueColor{F}}, color::Color{I}) where {I<:Integer, F<:AbstractFloat} = convert(T, convert(OpaqueColor{I}, color))
Base.convert(T::Type{Color{I}}, color::OpaqueColor{F}) where {I<:Integer, F<:AbstractFloat} = convert(T, convert(OpaqueColor{I}, color))
Base.convert(T::Type{Color{F}}, color::OpaqueColor{I}) where {I<:Integer, F<:AbstractFloat} = convert(T, convert(OpaqueColor{F}, color))


# Promotion Rules
Base.promote_rule(::Type{Color{T}}, ::Type{OpaqueColor{T}}) where T = Color{T}
Base.promote_rule(::Type{Color{T}}, ::Type{Color{U}}) where {T<:AbstractFloat, U<:Integer} = Color{T}
Base.promote_rule(::Type{OpaqueColor{T}}, ::Type{OpaqueColor{<:Integer}}) where {T<:AbstractFloat} = OpaqueColor{T}


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

# Write color to buffer
Base.write(io::IO, color::AbstractColor) = Base.write(io, collect(color))

# Transposing color has no effect
Base.transpose(color::AbstractColor) = color

# zero & one functions
Base.zero(color_t::Type{Color{F}}) where F = color_t(zeros(F, 4)...)
Base.zero(color_t::Type{OpaqueColor{F}}) where F = color_t(zeros(F, 3)...)
Base.one(color_t::Type{Color{F}}) where {F<:AbstractFloat} = color_t(ones(F, 4)...)
Base.one(color_t::Type{Color{I}}) where {I<:Integer} = color_t([typemax(I) for i ∈ 1:4]...)
Base.one(color_t::Type{OpaqueColor{F}}) where {F<:AbstractFloat} = color_t(ones(F, 3)...)
Base.one(color_t::Type{OpaqueColor{I}}) where {I<:Integer} = color_t([typemax(I) for i ∈ 1:3]...)


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
