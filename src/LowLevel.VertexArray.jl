import ModernGL

export VertexArray
export vertexarray, findattribute, bind

struct VertexArray <: AbstractGLResource
    glid::Integer
end

function vertexarray()
    ids = UInt32[0]
    ModernGL.glGenVertexArrays(1, pointer(ids))
    checkglerror()
    return VertexArray(ids[1])
end

function Base.bind(va::VertexArray, buff::PrimitiveArrayBuffer{T}, location::Integer, ncomps::Integer; offset::Integer = 0x0, stride::Integer = 0x0, normalized::Bool = false, force_integer::Bool = false) where T
    @assert ncomps ∈ 1:4
    @assert location >= 0
    
    use(va)
    use(buff)
    
    ModernGL.glEnableVertexAttribArray(location)
    checkglerror()
    
    if force_integer
        @assert T<:GL_PRIMITIVE_INTEGERS "Numeric type $(T) cannot be forced to integer"
        ModernGL.glVertexAttribIPointer(location, ncomps, gltype(T), stride, Ptr{Cvoid}(convert(UInt64, offset)))
    else
        ModernGL.glVertexAttribPointer(location, ncomps, gltype(T), normalized, stride, Ptr{Cvoid}(convert(UInt64, offset)))
    end
    checkglerror()
end

function Base.bind(va::VertexArray, buff::PrimitiveArrayBuffer{Float64}, location::Integer, size::Integer; offset::Integer = 0, stride::Integer = 0)
    @assert size ∈ 1:4
    @assert location >= 0
    
    use(buff)
    
    ModernGL.glEnableVertexAttribArray(location)
    checkglerror()
    
    ModernGL.glVertexAttribLPointer(location, size, gltype(T), stride, Ptr{Cvoid}(convert(UInt64, offset)))
    checkglerror()
end

function use(va::VertexArray)
    ModernGL.glBindVertexArray(glid(va))
    checkglerror()
end

function destroy(va::VertexArray)
    vas = [glid(va)]
    ModernGL.glDeleteVertexArrays(1, pointer[vas])
    checkglerror()
end

function findattribute(prog::Program, name::String)
    id = ModernGL.glGetAttribLocation(prog.glid, pointer(name))
    checkglerror()
    id
end
