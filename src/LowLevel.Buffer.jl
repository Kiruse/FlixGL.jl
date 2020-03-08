import ModernGL
using StaticArrays

export AbstractBuffer

abstract type AbstractBuffer <: AbstractGLResource end
abstract type AbstractBufferUsageFrequency end
abstract type AbstractBufferUsageNature end

struct StreamUsageFrequency  <: AbstractBufferUsageFrequency end
struct StaticUsageFrequency  <: AbstractBufferUsageFrequency end
struct DynamicUsageFrequency <: AbstractBufferUsageFrequency end
struct DrawUsageNature <: AbstractBufferUsageNature end
struct ReadUsageNature <: AbstractBufferUsageNature end
struct CopyUsageNature <: AbstractBufferUsageNature end

struct VertexArrayObject <: AbstractGLResource glid::Integer end

struct ArrayBuffer        <: AbstractBuffer glid::Integer end
struct ElementArrayBuffer <: AbstractBuffer glid::Integer end
struct TextureBuffer      <: AbstractBuffer glid::Integer end
struct UniformBuffer      <: AbstractBuffer glid::Integer end
gltype(buffer_t::Type{<:AbstractBuffer}) = error("Unknown buffer type $(buffer_t)")
gltype(::Type{ArrayBuffer})        = ModernGL.GL_ARRAY_BUFFER
gltype(::Type{ElementArrayBuffer}) = ModernGL.GL_ELEMENT_ARRAY_BUFFER
gltype(::Type{TextureBuffer})      = ModernGL.GL_TEXTURE_BUFFER
gltype(::Type{UniformBuffer})      = ModernGL.GL_UNIFORM_BUFFER


function vao(n::Integer = 1)
    @assert n > 0
    ids = zeros(n)
    ModernGL.glGenVertexArrays(n, pointer(ids))
    @assert ModernGL.glGetError() == 0
    if n == 1
        return VertexArrayObject(ids[1])
    else
        return [VertexArrayObject(id) for id in ids]
    end
end

function buffer(::Type{ArrayBuffer}, data::AbstractArray; mapper = Nothing)
    buff = buffer(ArrayBuffer)
    use(buff)
    buffer_upload(buff, data, mapper=mapper)
    return buff
end

function buffer(buffer_t::Type{<:AbstractBuffer}, n::Integer = 1)
    @assert n > 0
    ids = zeros(n)
    ModernGL.glGenBuffers(n, pointer(ids))
    @assert ModernGL.glGetError() == 0
    if n == 1
        return buffer_t(ids[1])
    else
        return [buffer_t(id) for id in ids]
    end
end

function buffer_upload(buff::AbstractBuffer, data::AbstractArray, freq::Type{AbstractBufferUsageFrequency}, nature::Type{AbstractBufferUsageNature}; mapper = Nothing)
    usage = glbufferusage(freq, nature)
    bytes = bytes(data, mapper=mapper)
    use(buff)
    ModernGL.glBufferData(gltype(typeof(buff)), sizeof(data), pointer(bytes), usage)
    @assert ModernGL.glGetError() == 0
end

function buffer_download(buff::AbstractBuffer)
    error("Not implemented")
end

function use(buff::AbstractBuffer)
    ModernGL.glBindBuffer(gltype(typeof(buff)), glid(buff))
    @assert ModernGL.glGetError() == 0
end


glbufferusage(::Type{<:AbstractBufferUsageFrequency}, ::Type{<:AbstractBufferUsageNature}) = error("Unknown buffer usage")
glbufferusage(::Type{StreamUsageFrequency},  ::Type{DrawUsageNature}) = ModernGL.GL_STREAM_DRAW
glbufferusage(::Type{StreamUsageFrequency},  ::Type{ReadUsageNature}) = ModernGL.GL_STREAM_READ
glbufferusage(::Type{StreamUsageFrequency},  ::Type{CopyUsageNature}) = ModernGL.GL_STREAM_COPY
glbufferusage(::Type{StaticUsageFrequency},  ::Type{DrawUsageNature}) = ModernGL.GL_STATIC_DRAW
glbufferusage(::Type{StaticUsageFrequency},  ::Type{ReadUsageNature}) = ModernGL.GL_STATIC_READ
glbufferusage(::Type{StaticUsageFrequency},  ::Type{CopyUsageNature}) = ModernGL.GL_STATIC_COPY
glbufferusage(::Type{DynamicUsageFrequency}, ::Type{DrawUsageNature}) = ModernGL.GL_DYNAMIC_DRAW
glbufferusage(::Type{DynamicUsageFrequency}, ::Type{ReadUsageNature}) = ModernGL.GL_DYNAMIC_READ
glbufferusage(::Type{DynamicUsageFrequency}, ::Type{CopyUsageNature}) = ModernGL.GL_DYNAMIC_COPY
