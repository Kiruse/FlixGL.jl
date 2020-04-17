module LowLevel

abstract type AbstractGLResource end
glid(res::AbstractGLResource) = res.glid
gltype(_...) = error("Not implemented")
destroy(_...) = error("Not implemented")
use(_...) = error("Not implemented")

include("./LowLevel.Shader.jl")
include("./LowLevel.Buffer.jl")
include("./LowLevel.VertexArray.jl")
include("./LowLevel.Uniform.jl")
include("./LowLevel.Draw.jl")
include("./LowLevel.ShaderUtil.jl")


function struct2bytes(data; fields = String[])
    error("Not implemented")
end

function bytes(data...)
    values = Any[]
    for val in data
        push!(values, val)
    end
    bytes(values)
end

function bytes(data::AbstractArray; mapper = identity)
    buff = IOBuffer()
    for elem ∈ data
        write(buff, mapper(elem))
    end
    seekstart(buff)
    return take!(buff)
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
