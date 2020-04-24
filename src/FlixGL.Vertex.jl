export AbstractVertex, AbstractVertexArrayData


abstract type AbstractVertex end

"""
The interface between the high level and low level APIs, the abstract vertex array data stores the VAO and VBO objects
as well as some extra metadata (`static::Bool` and `readable::Bool`). This data must be destroyed when the object is
destroyed.
"""
abstract type AbstractVertexArrayData end
destroy(vao::AbstractVertexArrayData) = error("`destroy` must be implemented for custom AbstractVertexArrayData '$(typeof(vao))'!")
internalvao(vao::AbstractVertexArrayData) = vao.internal

upload(verts::AbstractArray{<:AbstractVertex}; static::Bool = true, readable::Bool = false) = error("Not implemented")
upload(vao::AbstractVertexArrayData, verts::AbstractArray{<:AbstractVertex}) = error("Not implemented")


function getbufferusage(static::Bool, readable::Bool)
    if static
        frequency = LowLevel.BufferUsage.Static
    else
        frequency = LowLevel.BufferUsage.Dynamic
    end
    
    if readable
        nature = LowLevel.BufferUsage.Read
    else
        nature = LowLevel.BufferUsage.Draw
    end
    
    return (frequency, nature)
end
