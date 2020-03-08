module LowLevel

abstract type AbstractGLResource end
glid(res::AbstractGLResource) = res.glid
gltype(_...) = error("Not implemented")
destroy(_...) = error("Not implemented")
use(_...) = error("Not implemented")

include("./LowLevel.Shader.jl")
include("./LowLevel.Buffer.jl")


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

function bytes(data::AbstractArray{Any}; mapper = Nothing)
    buff = IOBuffer()
    for elem ∈ data
        val = elem
        if mapper val = mapper(val) end
        write(buff, val)
    end
    seekstart(buff)
    return take!(buff)
end

end # module
