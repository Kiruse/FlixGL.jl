using ModernGL
using StaticArrays

export uniform, finduniform

uniform(location::Integer, floats::Vararg{<:AbstractFloat}) = UniformInternal.uniform_vararg("f",  location, Float32.(floats))
uniform(location::Integer, ints::Vararg{<:Signed})          = UniformInternal.uniform_vararg("i",  location, Int32.(ints))
uniform(location::Integer, uints::Vararg{<:Unsigned})       = UniformInternal.uniform_vararg("ui", location, UInt32.(uints))

uniform(location::Integer, floats::AbstractVector{<:AbstractFloat}) = UniformInternal.uniform_array('f', location, Float32.(floats))
uniform(location::Integer, ints::AbstractVector{<:Signed})          = UniformInternal.uniform_array('i', location, Int32.(ints))
uniform(location::Integer, uints::AbstractVector{<:Unsigned})       = UniformInternal.uniform_array("ui", location, UInt32.(uints))

uniform(location::Integer, mat::SMatrix{N, M, Float32}; transpose::Bool = false) where {N, M} = UniformInternal.uniform_matrix(location, mat, transpose)
uniform(location::Integer, mat::SMatrix{N, M, <:AbstractFloat}; transpose::Bool = false) where {N, M} = uniform(location, SMatrix{N, M, Float32}(Float32.(mat)), transpose=transpose)

function finduniform(prog::Program, name::String)
    id = ModernGL.glGetUniformLocation(prog.glid, pointer(name))
    checkglerror()
    id
end

module UniformInternal
import ..LowLevel
using ModernGL
using StaticArrays

function uniform_vararg(typechars, location, values)
    @assert length(values) <= 4
    fn = getproperty(ModernGL, Symbol("glUniform$(length(values))$typechars"))
    fn(location, values...)
    LowLevel.checkglerror()
end

function uniform_array(typechars, location, array)
    @assert length(array) ∈ 1:4
    fn = getproperty(ModernGL, Symbol("glUniform$(length(array))$(typechars)v"))
    fn(location, length(array), pointer(array))
    LowLevel.checkglerror()
end

function uniform_matrix(location, mat::SMatrix{N, M}, transpose::Bool) where {N, M}
    @assert N ∈ 2:4 && M ∈ 2:4
    if N == M
        namepart = "$(N)"
    else
        namepart = "$(N)x$(M)"
    end
    fn = getproperty(ModernGL, Symbol("glUniformMatrix$(namepart)fv"))
    fn(location, 1, transpose, pointer(collect(mat)))
    LowLevel.checkglerror()
end
end # module UniformInternal
