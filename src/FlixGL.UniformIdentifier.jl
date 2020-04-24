export UniformIdentifier
export resolve!

mutable struct UniformIdentifier
    name::String
    id::Union{Nothing, Int32}
end
UniformIdentifier(name::String) = UniformIdentifier(name, nothing)

function resolve!(ident::UniformIdentifier, mat::AbstractMaterial)
    if ident.id == nothing
        ident.id = LowLevel.finduniform(programof(mat), ident.name)
    end
    ident.id
end
