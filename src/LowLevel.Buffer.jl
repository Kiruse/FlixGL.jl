import ModernGL
using StaticArrays

export AbstractBuffer, ArrayBuffer, ElementArrayBuffer, TextureBuffer, UniformBuffer, PrimitiveArrayBuffer
export buffer, buffer_upload, buffer_download

abstract type AbstractBuffer <: AbstractGLResource end

module BufferUsage
    export AbstractFrequency, AbstractNature
    export Stream, Static, Dynamic, Draw, Read, Copy
    
    abstract type AbstractFrequency end
    abstract type AbstractNature end
    
    struct Stream  <: AbstractFrequency end
    struct Static  <: AbstractFrequency end
    struct Dynamic <: AbstractFrequency end
    struct Draw <: AbstractNature end
    struct Read <: AbstractNature end
    struct Copy <: AbstractNature end
end
import .BufferUsage
glbufferusage(::Type{<:BufferUsage.AbstractFrequency}, ::Type{<:BufferUsage.AbstractNature}) = error("Unknown buffer usage")
glbufferusage(::Type{BufferUsage.Stream},  ::Type{BufferUsage.Draw}) = ModernGL.GL_STREAM_DRAW
glbufferusage(::Type{BufferUsage.Stream},  ::Type{BufferUsage.Read}) = ModernGL.GL_STREAM_READ
glbufferusage(::Type{BufferUsage.Stream},  ::Type{BufferUsage.Copy}) = ModernGL.GL_STREAM_COPY
glbufferusage(::Type{BufferUsage.Static},  ::Type{BufferUsage.Draw}) = ModernGL.GL_STATIC_DRAW
glbufferusage(::Type{BufferUsage.Static},  ::Type{BufferUsage.Read}) = ModernGL.GL_STATIC_READ
glbufferusage(::Type{BufferUsage.Static},  ::Type{BufferUsage.Copy}) = ModernGL.GL_STATIC_COPY
glbufferusage(::Type{BufferUsage.Dynamic}, ::Type{BufferUsage.Draw}) = ModernGL.GL_DYNAMIC_DRAW
glbufferusage(::Type{BufferUsage.Dynamic}, ::Type{BufferUsage.Read}) = ModernGL.GL_DYNAMIC_READ
glbufferusage(::Type{BufferUsage.Dynamic}, ::Type{BufferUsage.Copy}) = ModernGL.GL_DYNAMIC_COPY

struct VertexArrayObject <: AbstractGLResource glid::Integer end

# OpenGL supports halves, floats, doubles, bytes, shorts, ints, but no longs.
# Some additional RGB(A) related integers + fixed point decimals are supported, but not natively implemented in Julia.
const GL_PRIMITIVE_INTEGERS = Union{Int8, UInt8, Int16, UInt16, Int32, UInt32}
const GL_PRIMITIVE_DECIMALS = Union{Float16, Float32, Float64}
const GL_PRIMITIVE_NUMERICS = Union{GL_PRIMITIVE_DECIMALS, GL_PRIMITIVE_INTEGERS}
gltype(::Type{Float16}) = ModernGL.GL_HALF_FLOAT
gltype(::Type{Float32}) = ModernGL.GL_FLOAT
gltype(::Type{Float64}) = ModernGL.GL_DOUBLE
#gltype(::Type{Fixed}) = ModernGL.GL_FIXED
gltype(::Type{Int8})   = ModernGL.GL_BYTE
gltype(::Type{UInt8})  = ModernGL.GL_UNSIGNED_BYTE
gltype(::Type{Int16})  = ModernGL.GL_SHORT
gltype(::Type{UInt16}) = ModernGL.GL_UNSIGNED_SHORT
gltype(::Type{Int32})  = ModernGL.GL_INT
gltype(::Type{UInt32}) = ModernGL.GL_UNSIGNED_INT

struct ArrayBuffer        <: AbstractBuffer glid::Integer end
struct ElementArrayBuffer <: AbstractBuffer glid::Integer end
struct TextureBuffer      <: AbstractBuffer glid::Integer end
struct UniformBuffer      <: AbstractBuffer glid::Integer end
struct PrimitiveArrayBuffer{T<:GL_PRIMITIVE_NUMERICS} <: AbstractBuffer glid::Integer end # TODO: Support fixed point numbers & RGB(A) formats
gltype(buffer_t::Type{<:AbstractBuffer}) = error("Unknown buffer type $(buffer_t)")
gltype(::Type{ArrayBuffer})        = ModernGL.GL_ARRAY_BUFFER
gltype(::Type{ElementArrayBuffer}) = ModernGL.GL_ELEMENT_ARRAY_BUFFER
gltype(::Type{TextureBuffer})      = ModernGL.GL_TEXTURE_BUFFER
gltype(::Type{UniformBuffer})      = ModernGL.GL_UNIFORM_BUFFER
gltype(::Type{PrimitiveArrayBuffer{T}}) where T = ModernGL.GL_ARRAY_BUFFER


function buffer(buffer_t::Type{<:AbstractBuffer}, data::AbstractArray, freq::Type{<:BufferUsage.AbstractFrequency}, nature::Type{<:BufferUsage.AbstractNature}; mapper = identity)
    buff = buffer(buffer_t)
    use(buff)
    buffer_upload(buff, data, freq, nature, mapper=mapper)
    return buff
end

function buffer(buffer_t::Type{<:AbstractBuffer}, n::Integer = 1)
    @assert n > 0
    ids = zeros(UInt32, n)
    ModernGL.glGenBuffers(n, pointer(ids))
    checkglerror()
    if n == 1
        return buffer_t(ids[1])
    else
        return [buffer_t(id) for id in ids]
    end
end

function buffer_upload(buff::AbstractBuffer, data::AbstractArray, freq::Type{<:BufferUsage.AbstractFrequency}, nature::Type{<:BufferUsage.AbstractNature}; mapper = identity)
    buffer_upload_internal(buff, data, freq, nature, mapper=mapper)
end

function buffer_upload_internal(buff::AbstractBuffer, data::AbstractArray, freq::Type{<:BufferUsage.AbstractFrequency}, nature::Type{<:BufferUsage.AbstractNature}; mapper)
    usage = glbufferusage(freq, nature)
    byts  = bytes(data, mapper=mapper)
    use(buff)
    ModernGL.glBufferData(gltype(typeof(buff)), sizeof(data), pointer(byts), usage)
    checkglerror()
end

function buffer_download(buff::AbstractBuffer)
    error("Not implemented")
end

function use(buff::AbstractBuffer)
    ModernGL.glBindBuffer(gltype(typeof(buff)), glid(buff))
    checkglerror()
end
