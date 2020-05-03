module LowLevel
export AbstractGLResource
export glid, gltype, use, destroy

abstract type AbstractGLResource end
glid(res::AbstractGLResource) = res.glid

include("./LowLevel.Shader.jl")
include("./LowLevel.Buffer.jl")
include("./LowLevel.VertexArray.jl")
include("./LowLevel.Uniform.jl")
include("./LowLevel.Texture.jl")
include("./LowLevel.Draw.jl")
include("./LowLevel.ShaderUtil.jl")
include("./LowLevel.BufferUtil.jl")


gltype(::Type{Int8})    = ModernGL.GL_BYTE
gltype(::Type{UInt8})   = ModernGL.GL_UNSIGNED_BYTE
gltype(::Type{Int16})   = ModernGL.GL_SHORT
gltype(::Type{UInt16})  = ModernGL.GL_UNSIGNED_SHORT
gltype(::Type{Int32})   = ModernGL.GL_INT
gltype(::Type{UInt32})  = ModernGL.GL_UNSIGNED_INT
gltype(::Type{Float16}) = ModernGL.GL_HALF_FLOAT
gltype(::Type{Float32}) = ModernGL.GL_FLOAT


function struct2bytes(data; fields = String[])
    error("Not implemented")
end

function bytes(data...; mapper = identity)
    buff = IOBuffer()
    for elem ∈ data
        write(buff, mapper(elem))
    end
    seekstart(buff)
    take!(buff)
end

function bytes(data::AbstractArray; mapper = identity)
    buff = IOBuffer()
    for elem ∈ data
        write(buff, mapper(elem))
    end
    seekstart(buff)
    return take!(buff)
end

function bytes(data::AbstractVector{UInt8})
    return data
end

function bytes(data::AbstractArray{UInt8})
    return data[:]
end


function checkglerror()
    err = ModernGL.glGetError()
    if err == ModernGL.GL_INVALID_ENUM
        error("OpenGL Error: Invalid enum")
    elseif err == ModernGL.GL_INVALID_VALUE
        error("OpenGL Error: Invalid value")
    elseif err == ModernGL.GL_INVALID_OPERATION
        error("OpenGL Error: Invalid operation")
    elseif err == ModernGL.GL_INVALID_FRAMEBUFFER_OPERATION
        error("OpenGL Error: Invalid framebuffer operation")
    elseif err == ModernGL.GL_OUT_OF_MEMORY
        error("OpenGL Error: Out of memory")
    elseif err == ModernGL.GL_STACK_OVERFLOW
        error("OpenGL Error: Stack overflow")
    elseif err == ModernGL.GL_STACK_UNDERFLOW
        error("OpenGL Error: Stack underflow")
    end
end

end # module
